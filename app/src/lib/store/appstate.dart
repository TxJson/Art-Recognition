import 'package:art_app_fyp/classification/prediction.dart';
import 'package:art_app_fyp/shared/helpers/validators.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import './actions.dart';

@immutable
class AppState {
  final List<CameraDescription> cameras;
  final bool detectionState;
  final bool debugState;
  final int activeCameraIndex;
  final List<Prediction>? predictions;

  const AppState(
      {this.cameras = const <CameraDescription>[],
      this.detectionState = false,
      this.debugState = false,
      this.activeCameraIndex = 0,
      this.predictions});
}

// Only change passed variables in AppState, keep the rest the same
AppState updateAppState(state,
    {cameras, detectionState, debugState, activeCameraIndex, predictions}) {
  return AppState(
      cameras: Validators.defaultIfNull(cameras, state.cameras),
      detectionState:
          Validators.defaultIfNull(detectionState, state.detectionState),
      debugState: Validators.defaultIfNull(debugState, state.debugState),
      activeCameraIndex:
          Validators.defaultIfNull(activeCameraIndex, state.activeCameraIndex),
      predictions: Validators.defaultIfNull(predictions, state.predictions));
}

AppState appReducer(AppState state, action) {
  if (action is SetDetectionActiveAction) {
    return updateAppState(state, detectionState: action.payload);
  } else if (action is SetDetectionDisabledAction) {
    return updateAppState(state, detectionState: action.payload);
  } else if (action is ToggleDetection) {
    return updateAppState(state, detectionState: action.payload);
  } else if (action is ToggleDebugStateAction) {
    return updateAppState(state, debugState: action.payload);
  } else if (action is SetPredictions) {
    return updateAppState(state, predictions: action.payload);
  } else if (action is SetCameras) {
    return updateAppState(state, cameras: action.payload);
  }

  return state;
}
