import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

class PrayerTimeList extends StatelessWidget {
  final Iterable<MapEntry<String, String>> prayerEntries;

  const PrayerTimeList({Key? key, required this.prayerEntries})
    : super(key: key);

  static final Map<String, IconData> prayerIcons = {
    'Fajr': LucideIcons.sunrise,
    'Dhuhr': LucideIcons.sun,
    'Asr': LucideIcons.sunset,
    'Maghrib': LucideIcons.moon,
    'Isha': LucideIcons.moonStar,
  };

  String convertTo12Hour(String time24) {
    final parts = time24.split(":");
    final hour = int.parse(parts[0]);
    final minute = parts[1];
    final suffix = hour >= 12 ? "PM" : "AM";
    final hour12 = hour % 12 == 0 ? 12 : hour % 12;
    return "$hour12:$minute $suffix";
  }

  @override
  Widget build(BuildContext context) {
    // Filter entries to only include the five prayers
    final fivePrayers = ['Fajr', 'Dhuhr', 'Asr', 'Maghrib', 'Isha'];
    final filteredEntries =
        prayerEntries
            .where((entry) => fivePrayers.contains(entry.key))
            .toList();

    return Column(
      children: [
        // Title
        SafeArea(
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(24),
              ),
              gradient: LinearGradient(
                colors: [
                  Colors.white.withOpacity(0.9),
                  Colors.white.withOpacity(0.6),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.shade400,
                  offset: const Offset(4, 6),
                  blurRadius: 12,
                  spreadRadius: 1,
                ),
                const BoxShadow(
                  color: Colors.white,
                  offset: Offset(-4, -4),
                  blurRadius: 8,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: const Text(
              'Prayer Times',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: Colors.black87,
                letterSpacing: 1.1,
              ),
            ),
          ),
        ),

        // List
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: filteredEntries.length,
            itemBuilder: (context, index) {
              final entry = filteredEntries[index];
              final name = entry.key;
              final time = entry.value;
              final icon = prayerIcons[name] ?? Icons.access_time;

              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: LinearGradient(
                    colors: [
                      Colors.white.withOpacity(0.9),
                      Colors.white.withOpacity(0.6),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.shade300,
                      offset: const Offset(3, 4),
                      blurRadius: 10,
                    ),
                    const BoxShadow(
                      color: Colors.white,
                      offset: Offset(-3, -3),
                      blurRadius: 6,
                    ),
                  ],
                ),
                child: ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [Colors.green.shade300, Colors.green.shade600],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.green.shade100,
                          blurRadius: 8,
                          offset: const Offset(2, 5),
                        ),
                      ],
                    ),
                    child: Icon(
                      icon,
                      color: Colors.white,
                      size: 24, // Smaller icon
                    ),
                  ),
                  title: Text(
                    name,
                    style: const TextStyle(
                      fontSize: 18, // Smaller text
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                    ),
                  ),
                  trailing: Text(
                    convertTo12Hour(time),
                    style: TextStyle(
                      fontSize: 18, // Smaller time font
                      fontWeight: FontWeight.w700,
                      color: Colors.green.shade700,
                    ),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
