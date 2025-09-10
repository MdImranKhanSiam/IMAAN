import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:imaan/all_pages/pages/prayer_times_folder/prayer_time_service.dart';
import 'package:intl/intl.dart';

class PrayerTimeScreen extends StatefulWidget {
  const PrayerTimeScreen({super.key});

  @override
  _PrayerTimeScreenState createState() => _PrayerTimeScreenState();
}

class _PrayerTimeScreenState extends State<PrayerTimeScreen> {
  Map<String, String>? prayerTimes;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchPrayerTimes();
  }

  void fetchPrayerTimes() async {
    try {
      final service = PrayerTimeService();
      final times = await service.getPrayerTimes(
        'Dhaka',
        'Bangladesh',
      ); // You can make this dynamic
      setState(() {
        prayerTimes = times;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      if (kDebugMode) {
        print('Error fetching prayer times: $e');
      }
    }
  }

  String convertTo12Hour(String time24) {
    final dateTime = DateFormat("HH:mm").parse(time24);
    final formattedTime = DateFormat("h:mm a").format(dateTime);
    return formattedTime;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 251, 248, 248), //Background Color
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 251, 248, 248), //Appbar Color
        title: Text(
          'Prayer Times',
          style: TextStyle(
            fontWeight: FontWeight.w900,
            color: const Color.fromARGB(255, 0, 0, 0),
            fontSize: 30,
            
          ),
        ),
        centerTitle: true,
      ),
      body:
          isLoading
              ? Center(child: CircularProgressIndicator())
              : prayerTimes == null
              ? Center(child: Text('Failed to load prayer times'))
              : ListView(
                children:
                    prayerTimes!.entries.map((entry) {
                      return Card(
                        margin: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        child: ListTile(
                          title: Text(
                            entry.key,
                            style: TextStyle(
                              color: const Color.fromARGB(255, 0, 0, 0),
                              fontSize: 25,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          trailing: Text(
                            convertTo12Hour(entry.value),
                            style: TextStyle(
                              color: const Color.fromARGB(255, 12, 185, 104),
                              fontSize: 25,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
              ),
    );
  }
}
