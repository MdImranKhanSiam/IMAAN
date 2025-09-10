import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:islamic_hijri_calendar/islamic_hijri_calendar.dart';

class HijriCalendar extends StatefulWidget {
  const HijriCalendar({super.key});

  @override
  State<HijriCalendar> createState() => _HijriCalendarState();
}

class _HijriCalendarState extends State<HijriCalendar> {
  String convertArabicDateToEnglish(String arabicDate) {
    const arabicDigits = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
    const englishDigits = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];

    // Replace Arabic digits with English digits
    for (int i = 0; i < arabicDigits.length; i++) {
      arabicDate = arabicDate.replaceAll(arabicDigits[i], englishDigits[i]);
    }

    // Split the date into day, month, year
    List<String> dateParts = arabicDate.split('-');

    // Reformat to year-month-day format
    String formattedDate = '${dateParts[2]}-${dateParts[1]}-${dateParts[0]}';

    return formattedDate;
  }

  String formatGregorianDate(String date) {
    // Parse the input string into a DateTime object
    DateTime parsedDate = DateTime.parse(date);

    // Format the DateTime object into the desired format
    String formattedDate = DateFormat('EEEE, MMMM d, yyyy').format(parsedDate);

    return formattedDate;
  }

  String formatHijriDate(String hijriDate) {
    // List of Hijri month names in English
    const hijriMonthNames = [
      '', // Index 0 is unused
      'Muharram',
      'Safar',
      'Rabi al-Awwal',
      'Rabi al-Thani',
      'Jumada al-Awwal',
      'Jumada al-Thani',
      'Rajab',
      'Sha’ban',
      'Ramadan',
      'Shawwal',
      'Dhu al-Qi’dah',
      'Dhu al-Hijjah',
    ];

    // Split the input string (e.g., "1446-11-17") into year, month, and day
    List<String> parts = hijriDate.split('-');
    int year = int.parse(parts[0]);
    int month = int.parse(parts[1]);
    int day = int.parse(parts[2]);

    // Return the formatted date as "12 Shawwal 1446"
    return '$day ${hijriMonthNames[month]} $year';
  }

  String? Hijri_Date;
  String? English_Date;
  bool Clicked = false;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              IslamicHijriCalendar(
                isHijriView: true,
                // highlightBorder: Theme.of(context).colorScheme.primary,
                // isDisablePreviousNextMonthDates: true,
                // adjustmentValue: 0,            //To adjust Hijri
                isDisablePreviousNextMonthDates: true,

                getSelectedEnglishDate: (selectedDate) {
                  English_Date = formatGregorianDate('${selectedDate}');
                  setState(() {
                    Clicked = true;
                  });
                },

                getSelectedHijriDate: (selectedDate) {
                  String The_date = '${selectedDate}';
                  String converted_date = convertArabicDateToEnglish(The_date);
                  Hijri_Date = formatHijriDate(converted_date);
                },
              ),

              if (Clicked!) ...[
                Expanded(
                  child: ListView(
                    children: [
                      //Date
                      Container(
                        margin: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.2),
                              spreadRadius: 2,
                              blurRadius: 6,
                              offset: Offset(
                                0,
                                3,
                              ), // changes position of shadow
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.blue.shade100,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.calendar_today,
                                color: Colors.blue,
                                size: 28,
                              ),
                            ),
                            SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Date',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    English_Date!,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey[700],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            //Icon(Icons.chevron_right, color: Colors.grey),
                          ],
                        ),
                      ),

                      //Hijri Date
                      Container(
                        margin: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.2),
                              spreadRadius: 2,
                              blurRadius: 6,
                              offset: Offset(
                                0,
                                3,
                              ), // changes position of shadow
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.blue.shade100,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.mosque,
                                color: Colors.blue,
                                size: 28,
                              ),
                            ),
                            SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Hijri Date',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    Hijri_Date!,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey[700],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            //Icon(Icons.chevron_right, color: Colors.grey),
                          ],
                        ),
                      ),

                      //Today's Islamic Event
                      Container(
                        margin: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.2),
                              spreadRadius: 2,
                              blurRadius: 6,
                              offset: Offset(
                                0,
                                3,
                              ), // changes position of shadow
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.blue.shade100,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.event_available_outlined,
                                color: Colors.blue,
                                size: 28,
                              ),
                            ),
                            SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Today's Islamic Event",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    'No Event',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey[700],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            //Icon(Icons.chevron_right, color: Colors.grey),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
