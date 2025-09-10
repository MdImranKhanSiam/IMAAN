import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:intl/intl.dart';

class PrayerTimesRow extends StatefulWidget {
  @override
  _PrayerTimesRowState createState() => _PrayerTimesRowState();
}

class _PrayerTimesRowState extends State<PrayerTimesRow> {
  Set<int> selectedIndices = {};
  late SharedPreferences prefs;
  final String dateKey = 'selectedDate';
  final String indicesKey = 'selectedPrayers';

  final List<Map<String, dynamic>> prayers = [
    {'name': 'Fajr', 'icon': LucideIcons.sunrise},
    {'name': 'Dhuhr', 'icon': LucideIcons.sun},
    {'name': 'Asr', 'icon': LucideIcons.sunset},
    {'name': 'Maghrib', 'icon': LucideIcons.moon},
    {'name': 'Isha', 'icon': LucideIcons.moonStar},
  ];

  @override
  void initState() {
    super.initState();
    _loadSelection();
  }

  Future<void> _loadSelection() async {
    prefs = await SharedPreferences.getInstance();
    final savedDate = prefs.getString(dateKey);
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());

    if (savedDate == today) {
      // Load the selections for today
      final savedList = prefs.getStringList(indicesKey);
      if (savedList != null) {
        selectedIndices = savedList.map((e) => int.parse(e)).toSet();
      }
    } else {
      // If the date has changed, reset the selections and save today
      await prefs.remove(indicesKey);
      await prefs.setString(dateKey, today);
      selectedIndices.clear(); // Ensure we reset previous day's data
    }

    setState(() {});
  }

  Future<void> _markPrayer(int index) async {
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());

    // Only mark a prayer if it isn't already selected
    if (!selectedIndices.contains(index)) {
      setState(() {
        selectedIndices.add(index);
      });

      await prefs.setStringList(
        indicesKey,
        selectedIndices.map((e) => e.toString()).toList(),
      );
      await prefs.setString(dateKey, today); // Save today's date
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(prayers.length, (index) {
          final prayer = prayers[index];
          final isSelected = selectedIndices.contains(index);

          return GestureDetector(
            onTap: () => _markPrayer(index),
            child: AnimatedContainer(
              duration: Duration(milliseconds: 300),
              width: 60,
              height: 80,
              padding: EdgeInsets.symmetric(vertical: 8, horizontal: 6),
              decoration: BoxDecoration(
                gradient:
                    isSelected
                        ? LinearGradient(
                          colors: [
                            Colors.green.shade300,
                            Colors.green.shade500,
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        )
                        : LinearGradient(
                          colors: [
                            Colors.blue.shade100,
                            Colors.indigo.shade100,
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 8,
                    offset: Offset(2, 4),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    isSelected ? Icons.check_circle : prayer['icon'],
                    color: isSelected ? Colors.white : Colors.indigo,
                    size: 22,
                  ),
                  SizedBox(height: 4),
                  Text(
                    prayer['name'],
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? Colors.white : Colors.indigo.shade700,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}
