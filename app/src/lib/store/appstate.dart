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
      cameras: cameras ?? state.cameras,
      detectionState: detectionState ?? state.detectionState,
      debugState: debugState ?? state.debugState,
      activeCameraIndex: activeCameraIndex ?? state.activeCameraIndex);
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
