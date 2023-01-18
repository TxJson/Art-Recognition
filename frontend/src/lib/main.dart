// Native packages
import 'package:flutter/material.dart';
import 'package:art_app_fyp/redux/appstate.dart';
import 'package:art_app_fyp/app.dart';

// Plugins
import 'package:flutter_redux/flutter_redux.dart';
// ignore: depend_on_referenced_packages
import 'package:redux/redux.dart';

void main() async {
  WidgetsFlutterBinding
      .ensureInitialized(); //Ensure plugin services are initialized
  Store<AppState> store = Store<AppState>(appReducer, initialState: AppState());

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
