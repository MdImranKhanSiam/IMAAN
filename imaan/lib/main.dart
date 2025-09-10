import 'package:flutter/material.dart';
import 'package:imaan/all_pages/widget_tree.dart';
void main() {
  runApp(const IMAAN());
}

class IMAAN extends StatefulWidget {
  const IMAAN({super.key});

  @override
  State<IMAAN> createState() => _IMAANState();
}

class _IMAANState extends State<IMAAN> {
  
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromARGB(255, 18, 120, 222),
          brightness: Brightness.light,
        ),
      ),
      home: WidgetTree(),
    );
  }
}
