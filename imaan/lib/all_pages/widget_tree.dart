import 'package:flutter/material.dart';
import 'package:imaan/all_pages/pages/hijri_calendar.dart';
import 'package:imaan/all_pages/pages/prayer_time.dart';
import 'package:imaan/all_pages/pages/qibla.dart';
import 'package:imaan/data/notifiers.dart';

import 'widget/navbar_widget.dart';

List<Widget> pages = [
  PrayerTime(),
  Qibla(),
  HijriCalendar(),
];

class WidgetTree extends StatelessWidget {
  const WidgetTree({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("IMAAN"), centerTitle: true),
      
      body: ValueListenableBuilder(valueListenable: SelectPage, builder: (context, SelectedPage, child) {
        return pages.elementAt(SelectedPage);
      },),

      bottomNavigationBar: NavbarWidget(),
    );
  }
}
