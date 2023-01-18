import 'package:art_app_fyp/screens/home/camera.dart';
import 'package:flutter/material.dart';
import 'package:art_app_fyp/redux/appstate.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:redux/redux.dart';

class MyHome extends StatelessWidget {
  const MyHome({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: const BoxDecoration(color: Colors.green),
        child: Scaffold(
            body: StoreConnector<AppState, dynamic>(
                converter: (store) => store.state.cameras,
                builder: (context, cameras) {
                  return Center(
                    child: CameraView(cameras: cameras),
                  );
                }),
            floatingActionButton: SizedBox(
                width: 80,
                height: 80,
                child: FittedBox(
                  child: FloatingActionButton(
                    onPressed: () {},
                    backgroundColor: Colors.black,
                    splashColor: Colors.red.withOpacity(0.5),
                    child: const Icon(Icons.center_focus_strong),
                  ),
                )),
            floatingActionButtonLocation:
                FloatingActionButtonLocation.centerFloat));
  }
}
