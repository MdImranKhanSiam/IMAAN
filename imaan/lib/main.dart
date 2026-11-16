import 'package:flutter/material.dart';
import 'package:imaan/classes/app_log.dart';
import 'package:imaan/classes/theme_changer.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  AppLog.i('App', 'Starting IMAAN');

  // Location permission is requested by the prayer time / qibla screens
  // themselves, so startup is never blocked waiting for it.
  bool isDark = false;
  try {
    final prefs = await SharedPreferences.getInstance();
    isDark = prefs.getBool('isDarkMode') ?? false;
  } catch (e) {
    AppLog.e('App', 'Could not read settings', e);
  }

  runApp(
    ThemeChanger(
      initialThemeMode: isDark ? ThemeMode.dark : ThemeMode.light,
    ),
  );
}
