import 'package:flutter/material.dart';
import 'package:imaan/all_pages/pages/hijri_calendar.dart';
import 'package:imaan/all_pages/pages/prayer_time.dart';
import 'package:imaan/all_pages/pages/qibla.dart';
import 'package:imaan/data/notifiers.dart';
import 'widget/navbar_widget.dart';

class WidgetTree extends StatefulWidget {
  final VoidCallback onToggleTheme;

  const WidgetTree({super.key, required this.onToggleTheme});

  @override
  State<WidgetTree> createState() => _WidgetTreeState();
}

class _WidgetTreeState extends State<WidgetTree> {
  /// Tabs the user has opened at least once. They stay alive afterwards,
  /// so switching back is instant and nothing reloads.
  final Set<int> _visited = {};

  Widget _page(int index, int selected) {
    if (!_visited.contains(index)) return const SizedBox.shrink();
    switch (index) {
      case 0:
        return const PrayerTime();
      case 1:
        return Qibla(active: selected == 1);
      default:
        return const HijriCalendar();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ValueListenableBuilder<int>(
        valueListenable: SelectPage,
        builder: (context, selectedPage, child) {
          _visited.add(selectedPage);
          return IndexedStack(
            index: selectedPage,
            children: List.generate(3, (i) => _page(i, selectedPage)),
          );
        },
      ),
      bottomNavigationBar: const NavbarWidget(),
    );
  }
}
