import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_qiblah/flutter_qiblah.dart';

class QiblaScreen extends StatefulWidget {
  const QiblaScreen({super.key});

  @override
  State<QiblaScreen> createState() => _QiblaScreenState();
}

Animation<double>? animation;
AnimationController? _animationController;
double begin = 0.0;

class _QiblaScreenState extends State<QiblaScreen>
    with SingleTickerProviderStateMixin {
  @override
  void initState() {
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(microseconds: 500),
    );
    animation = Tween(begin: 0.0, end: 0.0).animate(_animationController!);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        // backgroundColor: const Color.fromARGB(255, 48, 48, 48),
        //backgroundColor: const Color.fromARGB(255, 240, 233, 233),
        body: StreamBuilder(
          stream: FlutterQiblah.qiblahStream,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Container(
                alignment: Alignment.center,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    CircularProgressIndicator(
                      color: Color.fromARGB(255, 66, 80, 151),
                    ),
                    SizedBox(height: 16), // space between spinner and text
                    Text(
                      "Loading...Please don't change the screen",
                      style: TextStyle(fontSize: 16, color: Colors.black54),
                    ),
                  ],
                ),
              );
            }

            final qiblahDirection = snapshot.data;
            animation = Tween(
              begin: begin,
              end: (qiblahDirection!.qiblah * (pi / 180) * -1),
            ).animate(_animationController!);
            begin = (qiblahDirection.qiblah * (pi / 180) * -1);
            _animationController!.forward(from: 0);

            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Text(
                  //   "${qiblahDirection.direction.toInt()}°",       //Shows Degree Of Rotation
                  //   style: const TextStyle(
                  //     color: Colors.white,
                  //     fontSize: 24,
                  //   ),
                  // ),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 300,
                    child: AnimatedBuilder(
                      animation: animation!,
                      builder:
                          (context, child) => Transform.rotate(
                            angle: animation!.value,
                            child: Image.asset('assets/images/qibla.png'),
                          ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
