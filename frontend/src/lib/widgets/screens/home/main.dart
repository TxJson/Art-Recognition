// Native Packages
import 'package:flutter/material.dart';

// Plugin
// import 'package:camera/camera.dart';

// Redux
import 'package:flutter_redux/flutter_redux.dart';
// ignore: depend_on_referenced_packages
import 'package:redux/redux.dart';

class MyHome extends StatelessWidget {
  const MyHome({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: const BoxDecoration(color: Colors.green),
        child: StoreConnector<int, int>(
            converter: (store) => store.state,
            builder: (context, value) {
              return const Center(
                child: Text('Home'),
              );
            }));
  }
}
