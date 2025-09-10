import 'package:flutter/material.dart';
import 'package:imaan/classes/theme_changer.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter/services.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Request location permission at the start of the app
  await _requestLocationPermission();

  // Initialize SharedPreferences
  final prefs = await SharedPreferences.getInstance();
  final isDark = prefs.getBool('isDarkMode') ?? false;

  runApp(
    ThemeChanger(
      initialThemeMode: isDark ? ThemeMode.dark : ThemeMode.light,
    ),
  );
}

// Function to request location permission
Future<void> _requestLocationPermission() async {
  try {
    // Check current permission status
    LocationPermission permission = await Geolocator.checkPermission();

    // If permission is denied, request it
    if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
      permission = await Geolocator.requestPermission();
      if (permission != LocationPermission.always && permission != LocationPermission.whileInUse) {
        // Handle permission denial (if needed)
        print('Location permission is required.');
        return;
      }
    }

    print('Location permission granted.');
  } on PlatformException catch (e) {
    print('Error requesting location permission: $e');
  }
}
