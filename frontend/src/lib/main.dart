import 'package:flutter/material.dart';
import 'package:art_app_fyp/redux/appstate.dart';
import 'package:art_app_fyp/app.dart';
import 'package:flutter_redux/flutter_redux.dart';
// ignore: depend_on_referenced_packages
import 'package:redux/redux.dart';
import 'package:camera/camera.dart';

void main() async {
  WidgetsFlutterBinding
      .ensureInitialized(); //Ensure plugin services are initialized

  final _cameras = await availableCameras();
  Store<AppState> store =
      Store<AppState>(appReducer, initialState: AppState(cameras: _cameras));

  runApp(StoreProvider<AppState>(
      store: store,
      child: MaterialApp(
        home: const MyApp(),
        theme: ThemeData(
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          hoverColor: Colors.transparent,
        ),
      )));
}
