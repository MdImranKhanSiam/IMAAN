import 'dart:async';
import 'dart:convert';

import 'package:geocoding/geocoding.dart';
import 'package:http/http.dart' as http;
import 'package:imaan/classes/app_log.dart';
import 'package:imaan/classes/country_method_map.dart';
import 'package:imaan/classes/location_helper.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Everything the prayer time page shows.
class PrayerData {
  final Map<String, String> timings;
  final String city;
  final String country;
  final int method;
  final String date; // yyyy-MM-dd the timings belong to
  final double latitude;
  final double longitude;

  const PrayerData({
    required this.timings,
    required this.city,
    required this.country,
    required this.method,
    required this.date,
    required this.latitude,
    required this.longitude,
  });

  LatLng get position => (latitude: latitude, longitude: longitude);

  Map<String, dynamic> toJson() => {
    'timings': timings,
    'city': city,
    'country': country,
    'method': method,
    'date': date,
    'latitude': latitude,
    'longitude': longitude,
  };

  static PrayerData? fromJson(String? source) {
    if (source == null) return null;
    try {
      final j = json.decode(source) as Map<String, dynamic>;
      return PrayerData(
        timings: Map<String, String>.from(j['timings'] as Map),
        city: j['city'] as String,
        country: j['country'] as String,
        method: j['method'] as int,
        date: j['date'] as String,
        latitude: (j['latitude'] as num).toDouble(),
        longitude: (j['longitude'] as num).toDouble(),
      );
    } catch (_) {
      return null;
    }
  }
}

class PrayerTimeService {
  static const _tag = 'PrayerService';
  static const _cacheKey = 'prayerDataV2';

  /// Distance the user can move before we ask the API again.
  static const _reuseKm = 2.0;

  static String get today => DateFormat('yyyy-MM-dd').format(DateTime.now());

  /// Last saved data, returned instantly (may be from another day).
  Future<PrayerData?> loadCached() async {
    final prefs = await SharedPreferences.getInstance();
    final data = PrayerData.fromJson(prefs.getString(_cacheKey));
    AppLog.i(
      _tag,
      data == null ? 'No cached prayer times' : 'Cached prayer times from ${data.date}',
    );
    return data;
  }

  /// Returns prayer times for [pos], using the cache when it still fits.
  Future<PrayerData> fetch(LatLng pos) async {
    final cached = await loadCached();
    final nearCached =
        cached != null && LocationHelper.distanceKm(cached.position, pos) < _reuseKm;

    if (nearCached && cached.date == today) {
      AppLog.i(_tag, 'Cache is for today and this location, no download needed');
      return cached;
    }

    // City / country: reuse cached names when we are in the same place.
    String city = 'Unknown';
    String country = 'Unknown';
    if (nearCached && cached.country != 'Unknown') {
      city = cached.city;
      country = cached.country;
      AppLog.i(_tag, 'Reusing cached place name: $city, $country');
    } else {
      try {
        final placemarks = await AppLog.timed(
          _tag,
          'Geocoding',
          () => Geocoding()
              .placemarkFromCoordinates(pos.latitude, pos.longitude)
              .timeout(const Duration(seconds: 8)),
        );
        if (placemarks.isNotEmpty) {
          final p = placemarks.first;
          if (p.country?.isNotEmpty ?? false) country = p.country!;
          if (p.locality?.isNotEmpty ?? false) {
            city = p.locality!;
          } else if (p.subAdministrativeArea?.isNotEmpty ?? false) {
            city = p.subAdministrativeArea!;
          }
        }
        AppLog.i(_tag, 'Place: $city, $country');
      } catch (_) {
        // Already logged by AppLog.timed; names are optional.
      }
    }

    final method = countryMethodMap[country] ?? 2;
    final url = Uri.parse(
      'https://api.aladhan.com/v1/timings'
      '?latitude=${pos.latitude}&longitude=${pos.longitude}&method=$method&madhab=1',
    );

    try {
      final response = await AppLog.timed(
        _tag,
        'Download prayer times (method $method)',
        () => http.get(url).timeout(const Duration(seconds: 15)),
      );
      if (response.statusCode != 200) {
        throw Exception('Server returned ${response.statusCode}');
      }
      final body = json.decode(response.body);
      final timings = <String, String>{};
      (body['data']['timings'] as Map).forEach((key, value) {
        // Some responses include a timezone suffix like "05:12 (+06)".
        timings[key.toString()] = value.toString().split(' ').first;
      });

      final data = PrayerData(
        timings: timings,
        city: city,
        country: country,
        method: method,
        date: today,
        latitude: pos.latitude,
        longitude: pos.longitude,
      );
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_cacheKey, json.encode(data.toJson()));
      AppLog.i(_tag, 'Saved prayer times to cache');
      return data;
    } catch (e) {
      AppLog.e(_tag, 'Download failed', e);
      // No internet / server problem: fall back to the last saved times.
      if (cached != null) {
        AppLog.w(_tag, 'Showing cached times from ${cached.date} instead');
        return cached;
      }
      throw Exception(
        'Could not download prayer times. Check your internet connection.',
      );
    }
  }
}
