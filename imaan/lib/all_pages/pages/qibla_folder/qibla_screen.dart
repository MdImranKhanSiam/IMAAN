import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_device_compass/flutter_device_compass.dart';
import 'package:imaan/classes/app_log.dart';
import 'package:imaan/classes/location_helper.dart';

class QiblaScreen extends StatefulWidget {
  /// False while another tab is showing: the compass is paused to save battery.
  final bool active;

  const QiblaScreen({super.key, this.active = true});

  @override
  State<QiblaScreen> createState() => _QiblaScreenState();
}

class _QiblaScreenState extends State<QiblaScreen> {
  static const _tag = 'Qibla';
  bool _loading = true;
  String? _error;
  LocationException? _locationError;

  /// Direction of the Kaaba from north, in degrees.
  double? _qiblaBearing;

  /// Current phone heading from north, in degrees (null = no compass data).
  double? _heading;
  bool _noCompass = false;

  /// Total rotation in turns, kept continuous so the arrow never spins
  /// the long way round when crossing 0/360 degrees.
  double _turns = 0;

  StreamSubscription<CompassEvent>? _compassSub;
  Timer? _compassTimer;
  DateTime _lastHeadingLog = DateTime.fromMillisecondsSinceEpoch(0);

  @override
  void initState() {
    super.initState();
    AppLog.i(_tag, 'Screen opened');
    LocationHelper.position.addListener(_onPositionChanged);
    _start();
  }

  @override
  void didUpdateWidget(QiblaScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.active == widget.active) return;
    if (widget.active) {
      AppLog.i(_tag, 'Tab visible, resuming compass');
      if (_qiblaBearing != null) _listenToCompass();
    } else {
      AppLog.i(_tag, 'Tab hidden, pausing compass');
      _stopCompass();
    }
  }

  @override
  void dispose() {
    LocationHelper.position.removeListener(_onPositionChanged);
    _stopCompass();
    super.dispose();
  }

  void _stopCompass() {
    _compassSub?.cancel();
    _compassSub = null;
    _compassTimer?.cancel();
  }

  void _onPositionChanged() {
    final pos = LocationHelper.position.value;
    if (pos == null || _qiblaBearing == null || !mounted) return;
    final bearing = LocationHelper.qiblaBearing(pos.latitude, pos.longitude);
    if ((bearing - _qiblaBearing!).abs() > 0.5) {
      AppLog.i(_tag, 'Location changed, Qibla now ${bearing.toStringAsFixed(1)}°');
      setState(() {
        _qiblaBearing = bearing;
        if (_heading != null) _updateTurns();
      });
    }
  }

  Future<void> _start() async {
    setState(() {
      _loading = true;
      _error = null;
      _locationError = null;
    });

    try {
      final pos = await LocationHelper.getPosition();
      if (!mounted) return;
      setState(() {
        _qiblaBearing = LocationHelper.qiblaBearing(pos.latitude, pos.longitude);
        _loading = false;
      });
      AppLog.i(_tag, 'Qibla bearing ${_qiblaBearing!.toStringAsFixed(1)}° from North');
      if (widget.active) _listenToCompass();
    } on LocationException catch (e) {
      AppLog.w(_tag, 'Location problem: ${e.message}');
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = e.message;
        _locationError = e;
      });
    } catch (e) {
      AppLog.e(_tag, 'Failed to find Qibla', e);
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = 'Something went wrong while finding the Qibla.';
      });
    }
  }

  void _listenToCompass() {
    _stopCompass();
    AppLog.i(_tag, 'Starting compass');

    final events = FlutterCompass.events;
    if (events == null) {
      AppLog.w(_tag, 'No compass on this device');
      setState(() => _noCompass = true);
      return;
    }

    // If the sensor never answers, stop waiting and show the bearing instead.
    _compassTimer = Timer(const Duration(seconds: 5), () {
      if (mounted && _heading == null) {
        AppLog.w(_tag, 'Compass gave no reading in 5 s');
        setState(() => _noCompass = true);
      }
    });

    _compassSub = events.listen(
      (event) {
        final heading = event.heading;
        if (heading == null || !mounted) return;
        _compassTimer?.cancel();
        final now = DateTime.now();
        if (now.difference(_lastHeadingLog).inSeconds >= 3) {
          _lastHeadingLog = now;
          AppLog.i(_tag, 'Heading ${heading.toStringAsFixed(0)}°, '
              'turn ${((_qiblaBearing! - heading) % 360).toStringAsFixed(0)}° to face Qibla');
        }
        setState(() {
          _noCompass = false;
          _heading = heading;
          _updateTurns();
        });
      },
      onError: (Object e) {
        AppLog.e(_tag, 'Compass error', e);
        if (mounted) setState(() => _noCompass = true);
      },
    );
  }

  void _updateTurns() {
    final target = ((_qiblaBearing! - _heading!) % 360) / 360; // 0..1
    final current = _turns % 1;
    var delta = target - current;
    if (delta > 0.5) delta -= 1;
    if (delta < -0.5) delta += 1;
    _turns += delta;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: _buildBody(),
          ),
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(color: Color.fromARGB(255, 66, 80, 151)),
          SizedBox(height: 16),
          Text(
            'Finding Qibla direction...',
            style: TextStyle(fontSize: 16, color: Colors.black54),
          ),
        ],
      );
    }

    if (_error != null) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset('assets/images/turn_on_location.jpg', height: 250),
          const SizedBox(height: 16),
          Text(
            _error!,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16, color: Colors.black87),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              AppLog.i(_tag, 'Tapped "Try again"');
              _start();
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
      );
    }

    final bearingText = 'Qibla is ${_qiblaBearing!.round()}° from North';

    if (_heading == null) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (!_noCompass) ...[
            const CircularProgressIndicator(
              color: Color.fromARGB(255, 66, 80, 151),
            ),
            const SizedBox(height: 16),
            const Text(
              'Waiting for compass...',
              style: TextStyle(fontSize: 16, color: Colors.black54),
            ),
          ] else
            const Text(
              'Compass sensor is not available on this phone.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.black54),
            ),
          const SizedBox(height: 16),
          Text(
            bearingText,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ],
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: 300,
          child: AnimatedRotation(
            turns: _turns,
            duration: const Duration(milliseconds: 250),
            child: Image.asset('assets/images/qibla.png'),
          ),
        ),
        const SizedBox(height: 24),
        Text(
          bearingText,
          style: const TextStyle(fontSize: 16, color: Colors.black54),
        ),
      ],
    );
  }
}
