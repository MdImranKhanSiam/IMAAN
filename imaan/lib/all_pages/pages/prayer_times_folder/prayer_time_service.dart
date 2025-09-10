import 'dart:convert';
import 'package:http/http.dart' as http;

class PrayerTimeService {
  Future<Map<String, String>> getPrayerTimes(String city, String country) async {
    final url = Uri.parse(
        'https://api.aladhan.com/v1/timingsByCity?city=$city&country=$country&method=2');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final timings = data['data']['timings'];

      return {
        'Fajr': timings['Fajr'],
        'Dhuhr': timings['Dhuhr'],
        'Asr': timings['Asr'],
        'Maghrib': timings['Maghrib'],
        'Isha': timings['Isha'],
      };
    } else {
      throw Exception('Failed to load prayer times');
    }
  }
}
