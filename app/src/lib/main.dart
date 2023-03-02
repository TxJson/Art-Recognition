import 'package:flutter/material.dart';
import 'package:art_app_fyp/store/appstate.dart';
import 'package:art_app_fyp/app.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:logger/logger.dart';
import 'package:camera/camera.dart';
import 'package:redux_thunk/redux_thunk.dart';

// ignore: depend_on_referenced_packages
import 'package:redux/redux.dart';

void main() async {
  WidgetsFlutterBinding
      .ensureInitialized(); //Ensure plugin services are initialized

  final List<CameraDescription> cameras = await availableCameras();

  var logger = Logger();
  logger.d("Logger is working!");

  Store<AppState> store = Store<AppState>(appReducer,
      initialState: AppState(cameras: cameras, debugState: true),
      middleware: [thunkMiddleware]);

  runApp(StoreProvider<AppState>(
      store: store,
      child: MaterialApp(
        title: 'Art Detection App',
        home: const MyApp(),
        theme: ThemeData(
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          hoverColor: Colors.transparent,
        ),
      )));
}
