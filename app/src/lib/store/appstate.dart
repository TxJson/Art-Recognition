import 'package:art_app_fyp/shared/validators.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import './actions.dart';

@immutable
class AppState {
  final List<CameraDescription> cameras;
  final bool detectionState;
  final bool debugState;
  final int activeCameraIndex;

  const AppState(
      {this.cameras = const <CameraDescription>[],
      this.detectionState = false,
      this.debugState = false,
      this.activeCameraIndex = 0});
}

// Only change passed variables in AppState, keep the rest the same
AppState updateAppState(state,
    {cameras, detectionState, debugState, activeCameraIndex}) {
  return AppState(
      cameras: Validators.defaultIfNull(cameras, state.cameras),
      detectionState:
          Validators.defaultIfNull(detectionState, state.detectionState),
      debugState: Validators.defaultIfNull(debugState, state.debugState),
      activeCameraIndex:
          Validators.defaultIfNull(activeCameraIndex, state.activeCameraIndex));
}

AppState appReducer(AppState state, action) {
  if (action is SetDetectionActiveAction) {
    return updateAppState(state, detectionState: true);
  } else if (action is SetDetectionDisabledAction) {
    return updateAppState(state, detectionState: false);
  } else if (action is ToggleDebugStateAction) {
    return updateAppState(state, debugState: !state.debugState);
  }

  return state;
}
