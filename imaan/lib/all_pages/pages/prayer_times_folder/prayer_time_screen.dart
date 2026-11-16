import 'dart:async';

import 'package:flutter/material.dart';
import 'package:imaan/all_pages/pages/prayer_times_folder/prayer_time_service.dart';
import 'package:imaan/classes/app_log.dart';
import 'package:imaan/classes/location_helper.dart';
import 'package:imaan/classes/prayer_time_list.dart';

class PrayerTimeScreen extends StatefulWidget {
  final void Function(String, String, String) onLocationDataFetched;

  const PrayerTimeScreen({super.key, required this.onLocationDataFetched});

  @override
  State<PrayerTimeScreen> createState() => _PrayerTimeScreenState();
}

class _PrayerTimeScreenState extends State<PrayerTimeScreen>
    with WidgetsBindingObserver {
  static const _tag = 'Prayer';

  final _service = PrayerTimeService();
  PrayerData? _data;
  bool _loading = true;
  bool _refreshing = false;
  String? _errorMessage;
  LocationException? _locationError;

  static const Map<int, String> methodNames = {
    0: 'Shia Ithna-Ashari',
    1: 'U. of Islamic Sciences, Karachi',
    2: 'ISNA (North America)',
    3: 'Muslim World League',
    4: 'Umm Al-Qura, Makkah',
    5: 'Egyptian General Survey',
    7: 'Tehran Univ. of Geophysics',
    8: 'Gulf Region',
    9: 'Kuwait',
    10: 'Qatar',
    11: 'MUIS, Singapore',
    12: 'France (UOIF)',
    13: 'Diyanet, Turkey',
    14: 'Russia (SAMR)',
  };

  @override
  void initState() {
    super.initState();
    AppLog.i(_tag, 'Screen opened');
    WidgetsBinding.instance.addObserver(this);
    LocationHelper.position.addListener(_onPositionChanged);
    _start();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    LocationHelper.position.removeListener(_onPositionChanged);
    super.dispose();
  }

  /// When the app comes back from the background, make sure the times are
  /// still for today.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      AppLog.i(_tag, 'App resumed, checking prayer times are current');
      _refresh();
    }
  }

  void _onPositionChanged() {
    final pos = LocationHelper.position.value;
    if (pos != null &&
        _data != null &&
        LocationHelper.distanceKm(pos, _data!.position) > 2) {
      AppLog.i(_tag, 'Location changed, reloading prayer times');
      _refresh();
    }
  }

  Future<void> _start() async {
    // 1. Show the last saved times instantly so the screen is never empty.
    final cached = await _service.loadCached();
    if (cached != null && mounted) {
      _show(cached);
      AppLog.i(_tag, 'Showing cached times while refreshing');
    }
    // 2. Then make sure they are correct for today and this location.
    await _refresh();
  }

  Future<void> _refresh() async {
    if (_refreshing) return;
    _refreshing = true;
    if (_data == null) {
      setState(() {
        _loading = true;
        _errorMessage = null;
        _locationError = null;
      });
    }

    try {
      final pos = await LocationHelper.getPosition();
      final data = await _service.fetch(pos);
      if (mounted) _show(data);
    } on LocationException catch (e) {
      AppLog.w(_tag, 'Location problem: ${e.message}');
      if (mounted && _data == null) {
        setState(() {
          _loading = false;
          _errorMessage = e.message;
          _locationError = e;
        });
      }
    } catch (e) {
      AppLog.e(_tag, 'Could not load prayer times', e);
      if (mounted && _data == null) {
        setState(() {
          _loading = false;
          _errorMessage = e.toString().replaceFirst('Exception: ', '');
        });
      }
    } finally {
      _refreshing = false;
    }
  }

  void _show(PrayerData data) {
    final isNew = _data == null ||
        _data!.date != data.date ||
        _data!.city != data.city ||
        _data!.timings.toString() != data.timings.toString();
    if (!isNew) return;

    setState(() {
      _data = data;
      _loading = false;
      _errorMessage = null;
    });
    AppLog.i(
      _tag,
      'Showing times for ${data.city}, ${data.country} (${data.date}): '
      '${['Fajr', 'Dhuhr', 'Asr', 'Maghrib', 'Isha'].map((p) => '$p ${data.timings[p]}').join(', ')}',
    );
    widget.onLocationDataFetched(
      data.city,
      data.country,
      methodNames[data.method] ?? 'Muslim World League',
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(color: Color.fromARGB(255, 66, 80, 151)),
            SizedBox(height: 16),
            Text(
              'Loading prayer times...',
              style: TextStyle(fontSize: 16, color: Colors.black54),
            ),
          ],
        ),
      );
    }

    if (_data == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.location_off, size: 48, color: Colors.black45),
              const SizedBox(height: 12),
              Text(
                _errorMessage ?? 'Failed to load prayer times',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16, color: Colors.black87),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  AppLog.i(_tag, 'Tapped "Try again"');
                  _refresh();
                },
                child: const Text('Try again'),
              ),
              if (_locationError?.hasFix ?? false)
                TextButton(
                  onPressed: () {
                    AppLog.i(_tag, 'Tapped "Open settings"');
                    _locationError!.openFixSettings();
                  },
                  child: const Text('Open settings'),
                ),
            ],
          ),
        ),
      );
    }

    return PrayerTimeList(prayerEntries: _data!.timings.entries);
  }
}
