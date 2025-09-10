import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:imaan/all_pages/pages/qibla_folder/qibla_screen.dart';

class Qibla extends StatefulWidget {
  const Qibla({super.key});

  @override
  State<Qibla> createState() => _QiblaState();
}

class _QiblaState extends State<Qibla> {
  bool hasPermission = false;

  @override
  void initState() {
    super.initState();
    getPermission();
  }

  Future getPermission() async {
    if (await Permission.location.serviceStatus.isEnabled) {
      var status = await Permission.location.status;
      setState(() {
        hasPermission = status.isGranted;
      });
      if (!hasPermission) {
        await Permission.location.request();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return hasPermission
        ? const QiblaScreen()
        : Scaffold(
          backgroundColor: Colors.white,
          body: Center(
            child: FutureBuilder(
              future: Future.delayed(const Duration(milliseconds: 100)),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset('assets/images/turn_on_location.jpg'),
                    ],
                  );
                } else {
                  return const SizedBox();
                }
              },
            ),
          ),
        );
  }
}
