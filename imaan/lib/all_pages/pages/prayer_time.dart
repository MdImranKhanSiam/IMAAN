import 'package:flutter/material.dart';
import 'package:imaan/all_pages/pages/prayer_times_folder/prayer_time_screen.dart';
import 'package:imaan/classes/prayer_times_row.dart';

class PrayerTime extends StatefulWidget {
  const PrayerTime({super.key});

  @override
  State<PrayerTime> createState() => _PrayerTimeState();
}

class _PrayerTimeState extends State<PrayerTime> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(flex: 2, child: PrayerTimeScreen()),
          //Divider(height: 1),
          Expanded(child: PrayerTimesRow()),
        ],
      ),
    );
  }
}
