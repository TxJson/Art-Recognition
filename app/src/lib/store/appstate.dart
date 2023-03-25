import 'package:art_app_fyp/shared/helpers/models/models.dart';
import 'package:art_app_fyp/shared/helpers/prediction.dart';
import 'package:art_app_fyp/shared/helpers/validators.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import './actions.dart';

@immutable
class AppState {
  final bool detectionState;
  final bool debugState;
  final bool debugTools;
  final int activeCameraIndex;
  final List<Prediction>? predictions;
  final Models models;

  const AppState(
      {required this.models,
      required this.activeCameraIndex,
      this.debugTools = false,
      this.detectionState = false,
      this.debugState = false,
      this.predictions});
}

// Only change passed variables in AppState, keep the rest the same
AppState updateAppState(state,
    {models,
    cameras,
    detectionState,
    debugState,
    debugTools,
    activeCameraIndex,
    predictions}) {
  return AppState(
      models: Validators.defaultIfNull(models, state.models),
      detectionState:
          Validators.defaultIfNull(detectionState, state.detectionState),
      debugState: Validators.defaultIfNull(debugState, state.debugState),
      debugTools: Validators.defaultIfNull(debugTools, state.debugTools),
      activeCameraIndex:
          Validators.defaultIfNull(activeCameraIndex, state.activeCameraIndex),
      predictions: Validators.defaultIfNull(predictions, state.predictions));
}

// TODO: Cleanup functionality
// This could likely be cleaned up but not important right now
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
