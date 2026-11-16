import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:imaan/classes/app_log.dart';
import 'package:shared_preferences/shared_preferences.dart';

typedef LatLng = ({double latitude, double longitude});

/// A readable error that can be shown to the user.
class LocationException implements Exception {
  final String message;
  final bool canOpenSettings;
  final bool locationServiceOff;

  const LocationException(
    this.message, {
    this.canOpenSettings = false,
    this.locationServiceOff = false,
  });

  /// Opens the screen that can fix this problem, if there is one.
  Future<void> openFixSettings() async {
    if (locationServiceOff) {
      await Geolocator.openLocationSettings();
    } else if (canOpenSettings) {
      await Geolocator.openAppSettings();
    }
  }

  bool get hasFix => locationServiceOff || canOpenSettings;

  @override
  String toString() => message;
}

/// Gets the device position quickly and shares it between all screens.
///
/// Waiting for a fresh GPS fix can take 5-15 s, so instead:
///   1. return the position already found in this session (instant)
///   2. else return Android's last known / our saved position (instant)
///      and refresh GPS in the background
///   3. only if nothing is known at all, wait for a fresh fix
///
/// When the background refresh finds the user has moved, [position]
/// is updated and listening screens reload.
class LocationHelper {
  static const _tag = 'Location';
  static const _latKey = 'lastLatitude';
  static const _lngKey = 'lastLongitude';

  /// Latest known position for the whole app (null until first found).
  static final ValueNotifier<LatLng?> position = ValueNotifier(null);

  static Future<LatLng>? _inFlight;
  static bool _refreshing = false;

  static Future<LatLng> getPosition() {
    final cached = position.value;
    if (cached != null) {
      AppLog.i(_tag, 'Using position already found this session');
      return Future.value(cached);
    }
    // If two screens ask at the same time, share one request.
    return _inFlight ??= _load().whenComplete(() => _inFlight = null);
  }

  static Future<LatLng> _load() async {
    await AppLog.timed(_tag, 'Permission check', _ensurePermission);

    // Fast path: something we already know.
    LatLng? quick;
    try {
      final last = await Geolocator.getLastKnownPosition().timeout(
        const Duration(seconds: 3),
      );
      if (last != null) {
        quick = (latitude: last.latitude, longitude: last.longitude);
        AppLog.i(_tag, 'Got Android last-known position');
      }
    } catch (e) {
      AppLog.w(_tag, 'Last-known position unavailable: $e');
    }

    if (quick == null) {
      final prefs = await SharedPreferences.getInstance();
      final lat = prefs.getDouble(_latKey);
      final lng = prefs.getDouble(_lngKey);
      if (lat != null && lng != null) {
        quick = (latitude: lat, longitude: lng);
        AppLog.i(_tag, 'Got position saved by the app');
      }
    }

    if (quick != null) {
      _set(quick);
      unawaited(_refreshInBackground());
      return quick;
    }

    // Slow path: first run ever, nothing known yet.
    AppLog.i(_tag, 'No saved position, waiting for GPS fix...');
    final fresh = await _freshFix();
    if (fresh != null) {
      _set(fresh);
      return fresh;
    }

    throw const LocationException(
      'Could not get your location.\nMake sure location (GPS) is on and try again.',
    );
  }

  static Future<void> _refreshInBackground() async {
    if (_refreshing) return;
    _refreshing = true;
    try {
      final fresh = await _freshFix();
      if (fresh == null) return;
      final old = position.value;
      final moved = old == null ? double.infinity : distanceKm(old, fresh);
      if (moved > 2) {
        AppLog.i(_tag, 'Moved ${moved.toStringAsFixed(1)} km, updating screens');
        _set(fresh);
      } else {
        AppLog.i(_tag, 'GPS confirms position (moved ${moved.toStringAsFixed(2)} km)');
        unawaited(_save(fresh));
      }
    } finally {
      _refreshing = false;
    }
  }

  static Future<LatLng?> _freshFix() async {
    try {
      final p = await AppLog.timed(
        _tag,
        'GPS fix',
        () => Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.low,
            timeLimit: Duration(seconds: 15),
          ),
        ).timeout(const Duration(seconds: 17)),
      );
      return (latitude: p.latitude, longitude: p.longitude);
    } catch (_) {
      return null;
    }
  }

  static void _set(LatLng value) {
    position.value = value;
    unawaited(_save(value));
  }

  static Future<void> _save(LatLng value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_latKey, value.latitude);
    await prefs.setDouble(_lngKey, value.longitude);
  }

  static Future<void> _ensurePermission() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      AppLog.w(_tag, 'Location service is OFF');
      throw const LocationException(
        'Location is turned off.\nPlease turn on your location to continue.',
        locationServiceOff: true,
      );
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      AppLog.i(_tag, 'Asking user for location permission');
      permission = await Geolocator.requestPermission();
    }
    AppLog.i(_tag, 'Permission: ${permission.name}');

    if (permission == LocationPermission.deniedForever) {
      throw const LocationException(
        'Location permission is permanently denied.\nPlease allow it in the app settings.',
        canOpenSettings: true,
      );
    }
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.unableToDetermine) {
      throw const LocationException(
        'Location permission is required to continue.',
      );
    }
  }

  /// Straight-line distance between two points in km.
  static double distanceKm(LatLng a, LatLng b) =>
      Geolocator.distanceBetween(
        a.latitude,
        a.longitude,
        b.latitude,
        b.longitude,
      ) /
      1000;

  /// Bearing from north (0-360 degrees, clockwise) towards the Kaaba.
  static double qiblaBearing(double latitude, double longitude) {
    const kaabaLat = 21.422487;
    const kaabaLng = 39.826206;

    final lat1 = latitude * pi / 180;
    final lat2 = kaabaLat * pi / 180;
    final dLng = (kaabaLng - longitude) * pi / 180;

    final y = sin(dLng);
    final x = cos(lat1) * tan(lat2) - sin(lat1) * cos(dLng);
    final bearing = atan2(y, x) * 180 / pi;
    return (bearing + 360) % 360;
  }
}
