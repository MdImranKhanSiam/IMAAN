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

  Future getPermission() async {
    if (await Permission.location.serviceStatus.isEnabled) {
      var status = await Permission.location.status;
      if (status.isGranted) {
        hasPermission = true;
      } else {
        Permission.location.request().then((value) {
          setState(() {
            hasPermission = (value == PermissionStatus.granted);
          });
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      // future: Future(() {}),
      builder: (context, snapshot) {
        if (hasPermission) {
          return const QiblaScreen();
        } else {
          return Scaffold(
            backgroundColor: Color.fromARGB(255, 255, 255, 255),
            body: Center(
              child: FutureBuilder(
                future: Future.delayed(
                  Duration(milliseconds: 100),
                ), //Delay before showing qibla screen
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset('assets/images/turn_on_location.jpg'),
                        // Text(
                        //   textAlign: TextAlign.center,
                        //   "Location is turned off\n\nPlease turn on your location to continue",
                        //   style: TextStyle(
                        //     color: Color.fromARGB(255, 25, 24, 24),
                        //     fontSize: 20,
                        //     fontWeight: FontWeight.bold,
                        //   ),
                        // ),
                      ],
                    );
                  } else {
                    return SizedBox();
                  }
                },
              ),
            ),
          );
        }
      },

      future: getPermission(),
    );
  }
}
