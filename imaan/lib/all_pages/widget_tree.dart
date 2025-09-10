import 'package:flutter/material.dart';
import 'package:imaan/all_pages/pages/hijri_calendar.dart';
import 'package:imaan/all_pages/pages/prayer_time.dart';
import 'package:imaan/all_pages/pages/qibla.dart';
import 'package:imaan/data/notifiers.dart';
import 'widget/navbar_widget.dart';

List<Widget> pages = [PrayerTime(), Qibla(), HijriCalendar()];

class WidgetTree extends StatelessWidget {
  final VoidCallback onToggleTheme;

  const WidgetTree({Key? key, required this.onToggleTheme}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   centerTitle: true,
      //   actions: [
      //     IconButton(
            
      //       icon: const Icon(Icons.brightness_6, size: 0,),
            
      //       tooltip: 'Toggle Theme',
      //       onPressed: onToggleTheme,
      //     ),
      //   ],
      // ),
      body: ValueListenableBuilder(
        valueListenable: SelectPage,
        builder: (context, selectedPage, child) {
          return pages.elementAt(selectedPage);
        },
      ),
      bottomNavigationBar: NavbarWidget(),
    );
  }
}
