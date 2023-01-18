import 'package:flutter/material.dart';

// Plugins
import 'package:flutter_redux/flutter_redux.dart';
// ignore: depend_on_referenced_packages
import 'package:redux/redux.dart';

@immutable
class AppState {
  final cameras;
  final value;

  AppState({this.cameras = 0, this.value = 10});
}

// Uncomment when we need to add appstate actions
// enum Actions {}

final Reducer<AppState> appReducer = combineReducers([
  // new TypedReducer<AppState, LoadTodosAction>(loadItemsReducer),
  // new TypedReducer<AppState, UpdateItemsAction>(updateItemsReducer),
  // new TypedReducer<AppState, AddItemAction>(addItemReducer),
  // new TypedReducer<AppState, RemoveItemAction>(removeItemReducer),
  // new TypedReducer<AppState, ShuffleItemAction>(shuffleItemsReducer),
  // new TypedReducer<AppState, ReverseItemAction>(reverseItemsReducer),
]);
