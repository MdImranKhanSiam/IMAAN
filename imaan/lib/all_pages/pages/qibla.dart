import 'package:flutter/material.dart';
import 'package:imaan/all_pages/pages/qibla_folder/qibla_screen.dart';

class Qibla extends StatelessWidget {
  /// False while another tab is showing.
  final bool active;

  const Qibla({super.key, this.active = true});

  @override
  Widget build(BuildContext context) {
    // QiblaScreen handles location permission, GPS and compass itself.
    return QiblaScreen(active: active);
  }
}
