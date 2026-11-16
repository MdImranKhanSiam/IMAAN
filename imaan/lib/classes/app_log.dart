import 'package:flutter/foundation.dart';

/// Simple app-wide logger.
///
/// Every line looks like:  `12:01:33.120 [IMAAN][Prayer] Loaded from cache`
///
/// Where to see the logs:
///  * Started with F5 / "Run > Start Debugging" in VS Code -> DEBUG CONSOLE tab
///  * Started with `flutter run` in a terminal          -> that terminal
///  * Any build on the phone                             -> `adb logcat -s flutter`
class AppLog {
  AppLog._();

  static void i(String tag, String message) => _write('', tag, message);

  static void w(String tag, String message) => _write('WARN ', tag, message);

  static void e(String tag, String message, [Object? error]) =>
      _write('ERROR ', tag, error == null ? message : '$message -> $error');

  /// Runs [action] and logs how long it took.
  static Future<T> timed<T>(
    String tag,
    String label,
    Future<T> Function() action,
  ) async {
    final sw = Stopwatch()..start();
    try {
      final result = await action();
      i(tag, '$label done in ${sw.elapsedMilliseconds} ms');
      return result;
    } catch (err) {
      w(tag, '$label failed after ${sw.elapsedMilliseconds} ms: $err');
      rethrow;
    }
  }

  static void _write(String level, String tag, String message) {
    final now = DateTime.now();
    String two(int n) => n.toString().padLeft(2, '0');
    final time =
        '${two(now.hour)}:${two(now.minute)}:${two(now.second)}'
        '.${now.millisecond.toString().padLeft(3, '0')}';
    debugPrint('$time [IMAAN][$tag] $level$message');
  }
}
