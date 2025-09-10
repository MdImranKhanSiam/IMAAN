import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:intl/intl.dart';

class PrayerTimesRow extends StatefulWidget {
  final String? city;
  final String? country;
  final String? methodName;

  const PrayerTimesRow({super.key, this.city, this.country, this.methodName});

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
      final savedList = prefs.getStringList(indicesKey);
      if (savedList != null) {
        selectedIndices = savedList.map((e) => int.parse(e)).toSet();
      }
    } else {
      await prefs.remove(indicesKey);
      await prefs.setString(dateKey, today);
      selectedIndices.clear();
    }

    setState(() {});
  }

  Future<void> _markPrayer(int index) async {
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());

    if (!selectedIndices.contains(index)) {
      setState(() {
        selectedIndices.add(index);
      });

      await prefs.setStringList(
        indicesKey,
        selectedIndices.map((e) => e.toString()).toList(),
      );
      await prefs.setString(dateKey, today);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.city != null &&
              widget.country != null &&
              widget.methodName != null) ...[
            Text(
              'Location: ${widget.city}, ${widget.country}',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 5),
            Text(
              'Calculation Method: ${widget.methodName}',
              style: TextStyle(fontSize: 14, fontStyle: FontStyle.italic),
            ),
            SizedBox(height: 15),
          ],
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(prayers.length, (index) {
              final prayer = prayers[index];
              final isSelected = selectedIndices.contains(index);

              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 3.5),
                  child: GestureDetector(
                    onTap: () => _markPrayer(index),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      padding: const EdgeInsets.symmetric(
                        vertical: 10,
                        horizontal: 4,
                      ),
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
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 6,
                            offset: Offset(2, 3),
                          ),
                        ],
                      ),
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              isSelected ? Icons.check_circle : prayer['icon'],
                              color: isSelected ? Colors.white : Colors.indigo,
                              size: 22,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              prayer['name'],
                              overflow: TextOverflow.ellipsis,
                              softWrap: false,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color:
                                    isSelected
                                        ? Colors.white
                                        : Colors.indigo.shade700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}
