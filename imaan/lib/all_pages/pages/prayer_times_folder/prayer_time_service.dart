import 'package:http/http.dart' as http;
import 'package:imaan/classes/country_method_map.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class PrayerTimeService {
  // Time threshold for cache expiration (e.g., 24 hours)
  static const cacheDuration = Duration(hours: 24);

  Future<Map<String, String>> getPrayerTimesFromLocation(
      double latitude, double longitude, String countryName) async {
    try {
      // First, check if we have cached prayer times and if they're valid
      final cachedPrayerTimes = await _getCachedPrayerTimes();
      if (cachedPrayerTimes != null) {
        return cachedPrayerTimes;
      }

      // If no valid cache or expired, fetch from the API
      final method = countryMethodMap[countryName] ?? 2; // Default method

      final url = Uri.parse(
        'https://api.aladhan.com/v1/timings?latitude=$latitude&longitude=$longitude&method=$method&madhab=1',
      );

      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final timings = Map<String, String>.from(data['data']['timings']);
        
        // Cache the prayer times with the current timestamp
        await _cachePrayerTimes(timings);
        
        return timings;
      } else {
        throw Exception('Failed to load prayer times');
      }
    } catch (e) {
      throw Exception('Error fetching prayer times: $e');
    }
  }

  // Caching the prayer times along with the timestamp
  Future<void> _cachePrayerTimes(Map<String, String> prayerTimes) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = json.encode(prayerTimes);
    final timestamp = DateTime.now().toIso8601String();
    
    await prefs.setString('cachedPrayerTimes', jsonString);
    await prefs.setString('cachedPrayerTimesTimestamp', timestamp);
  }

  // Retrieving the cached prayer times and checking for expiration
  Future<Map<String, String>?> _getCachedPrayerTimes() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString('cachedPrayerTimes');
    final timestampString = prefs.getString('cachedPrayerTimesTimestamp');
    
    if (jsonString != null && timestampString != null) {
      final timestamp = DateTime.parse(timestampString);
      
      // If the cache is older than the specified duration, refresh it
      if (DateTime.now().difference(timestamp) < cacheDuration) {
        final Map<String, dynamic> jsonData = json.decode(jsonString);
        return Map<String, String>.from(jsonData);
      } else {
        // Cache expired, return null so it will be refreshed
        return null;
      }
    }
    
    // No cache found, return null
    return null;
  }
}
