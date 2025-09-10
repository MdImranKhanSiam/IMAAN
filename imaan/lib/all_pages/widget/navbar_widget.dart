import 'package:flutter/material.dart';
import 'package:imaan/data/notifiers.dart';

class NavbarWidget extends StatelessWidget {
  const NavbarWidget({super.key});
  

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: SelectPage,
      builder: (context, TheSelectedPage, child) {
        return NavigationBar(
          backgroundColor: Color.fromARGB(255, 255, 255, 255), //Navigation Bar Color
          destinations: [
            NavigationDestination(
              icon: Icon(Icons.watch_later),
              label: "Prayer Time",
            ),
            NavigationDestination(icon: Icon(Icons.explore), label: "Qibla"),
            NavigationDestination(
              icon: Icon(Icons.calendar_month),
              label: "Hijri Calendar",
            ),
          ],

          onDestinationSelected: (int value) {
            SelectPage.value = value;
          },
          selectedIndex: TheSelectedPage,
        );
      },
    );
  }
}
