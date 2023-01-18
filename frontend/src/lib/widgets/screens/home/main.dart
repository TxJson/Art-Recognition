// Native Packages
import 'package:flutter/material.dart';

// Plugins
import 'package:camera/camera.dart';

class MyHome extends StatelessWidget {
  const MyHome({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: const BoxDecoration(color: Colors.green),
        child: const Center(
          child: Text('Home'),
        ));
  }
}
