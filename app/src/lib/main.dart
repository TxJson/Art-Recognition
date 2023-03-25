import 'package:art_app_fyp/shared/helpers/models/models.dart';
import 'package:flutter/material.dart';
import 'package:art_app_fyp/store/appstate.dart';
import 'package:art_app_fyp/app.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:logger/logger.dart';
import 'package:camera/camera.dart';
import 'package:redux_thunk/redux_thunk.dart';

// ignore: depend_on_referenced_packages
import 'package:redux/redux.dart';

int DEFAULT_CAMERA_INDEX = 0;
bool DEBUG_TOOLS = true;
String DEFAULT_MODEL = 'yolov5_art_style';

void main() async {
  WidgetsFlutterBinding
      .ensureInitialized(); //Ensure plugin services are initialized

  var logger = Logger();
  logger.d("Logger is working!");

  Models models = Models(path: 'assets/models.json');
  await models.load(); // Load all models

  models.setDefault(DEFAULT_MODEL);

  Store<AppState> store = Store<AppState>(appReducer,
      initialState: AppState(
          debugTools: DEBUG_TOOLS,
          debugState: true,
          detectionState: true,
          models: models,
          activeCameraIndex: DEFAULT_CAMERA_INDEX),
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
