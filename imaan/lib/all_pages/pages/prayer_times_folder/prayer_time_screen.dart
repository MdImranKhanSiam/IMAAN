import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:imaan/all_pages/pages/prayer_times_folder/prayer_time_service.dart';
import 'package:imaan/classes/country_method_map.dart';
import 'package:imaan/classes/prayer_time_list.dart';
import 'package:intl/intl.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart'; // Import geocoding package

class PrayerTimeScreen extends StatefulWidget {
  final Function(String, String, String) onLocationDataFetched;

  const PrayerTimeScreen({
    super.key,
    required this.onLocationDataFetched,
  }); // Accept callback

  @override
  _PrayerTimeScreenState createState() => _PrayerTimeScreenState();
}

class _PrayerTimeScreenState extends State<PrayerTimeScreen> {
  Map<String, String>? prayerTimes;
  bool isLoading = true;
  String? currentCity;
  String? currentCountry;
  int? calculationMethod;

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
    fetchPrayerTimes();
  }

  void fetchPrayerTimes() async {
    try {
      LocationPermission permission = await Geolocator.requestPermission();

      if (permission == LocationPermission.always ||
          permission == LocationPermission.whileInUse) {
        final position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
        );

        final placemarks = await placemarkFromCoordinates(
          position.latitude,
          position.longitude,
        );
        final placemark = placemarks.first;
        final countryName = placemark.country ?? 'Unknown';
        final cityName =
            placemark.locality ?? placemark.subAdministrativeArea ?? 'Unknown';

        final method = countryMethodMap[countryName] ?? 2;

        final service = PrayerTimeService();
        final times = await service.getPrayerTimesFromLocation(
          position.latitude,
          position.longitude,
          countryName,
        );

        setState(() {
          prayerTimes = times;
          isLoading = false;
          currentCity = cityName;
          currentCountry = countryName;
          calculationMethod = method;

          // Pass the location data back to the parent widget
          widget.onLocationDataFetched(
            cityName,
            countryName,
            methodNames[method]!,
          );
        });
      } else {
        setState(() {
          isLoading = false;
        });
        if (kDebugMode) {
          print('Location permission denied');
        }
      }
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
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : prayerTimes == null
              ? const Center(child: Text('Failed to load prayer times'))
              : Column(
                children: [
                  Expanded(
                    child: PrayerTimeList(prayerEntries: prayerTimes!.entries),
                  ),
                ],
              ),
    );
  }
}
