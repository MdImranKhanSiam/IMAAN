import 'package:flutter/material.dart';
import 'package:imaan/classes/theme_changer.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final isDark = prefs.getBool('isDarkMode') ?? false;

  runApp(
    ThemeChanger(
      initialThemeMode: isDark ? ThemeMode.dark : ThemeMode.light,
    ),
  );
}
