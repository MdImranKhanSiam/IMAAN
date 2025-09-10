import 'dart:async'; // Make sure to import this
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
  late StreamSubscription _qiblahSubscription;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    animation = Tween(begin: 0.0, end: 0.0).animate(_animationController!);

    // Subscribe to the qiblah stream
    _qiblahSubscription = FlutterQiblah.qiblahStream.listen((qiblahDirection) {
      // Update the animation based on new qiblah direction
      animation = Tween(
        begin: begin,
        end: (qiblahDirection.qiblah * (pi / 180) * -1),
      ).animate(_animationController!);
      begin = (qiblahDirection.qiblah * (pi / 180) * -1);
      _animationController!.forward(from: 0); // Animate the compass
    });
  }

  @override
  void dispose() {
    // Cancel the subscription when the widget is disposed
    _qiblahSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: StreamBuilder(
          stream: FlutterQiblah.qiblahStream,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Container(
                alignment: Alignment.center,
                child: const CircularProgressIndicator(
                  color: Color.fromARGB(255, 66, 80, 151),
                ),
              );
            }

            final qiblahDirection = snapshot.data;
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
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
