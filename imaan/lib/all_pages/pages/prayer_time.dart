import 'package:flutter/material.dart';
import 'package:imaan/all_pages/pages/prayer_times_folder/prayer_time_screen.dart';
import 'package:imaan/classes/prayer_times_row.dart'; // Import PrayerRowLocked class.

class PrayerTime extends StatefulWidget {
  const PrayerTime({super.key});

  @override
  State<PrayerTime> createState() => _PrayerTimeState();
}

class _PrayerTimeState extends State<PrayerTime> {
  String? currentCity;
  String? currentCountry;
  String? calculationMethod;

  // This method will be called when PrayerTimeScreen fetches data.
  void updateLocationData(String city, String country, String method) {
    setState(() {
      currentCity = city;
      currentCountry = country;
      calculationMethod = method;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            flex: 5,
            child: PrayerTimeScreen(onLocationDataFetched: updateLocationData), // Pass the callback to PrayerTimeScreen
          ),
          // Divider is optional, can be added if needed
          Expanded(
            flex: 1,
            child: PrayerTimesRow(
              city: currentCity,
              country: currentCountry,
              methodName: calculationMethod,
            ),
          ),
        ],
      ),
    );
  }
}
