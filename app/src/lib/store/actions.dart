import 'package:art_app_fyp/shared/helpers/prediction.dart';
import 'package:art_app_fyp/store/appstate.dart';
import 'package:camera/camera.dart';
import 'package:redux_thunk/redux_thunk.dart';
import 'package:redux/redux.dart';

abstract class ReduxAction<T> {
  T payload;

  ReduxAction(this.payload);
}

class SetDetectionActiveAction extends ReduxAction<bool> {
  SetDetectionActiveAction(bool detectionState) : super(detectionState);
}

class SetDetectionDisabledAction extends ReduxAction<bool> {
  SetDetectionDisabledAction(bool detectionState) : super(detectionState);
}

class ToggleDetection extends ReduxAction<bool> {
  ToggleDetection(bool detectionState) : super(detectionState);
}

class SetPredictions extends ReduxAction<List<Prediction>> {
  SetPredictions(List<Prediction> predictions) : super(predictions);
}

class SetCameras extends ReduxAction<List<CameraDescription>> {
  SetCameras(List<CameraDescription> cameras) : super(cameras);
}

class ToggleDebugStateAction extends ReduxAction<bool> {
  ToggleDebugStateAction(bool debugState) : super(debugState);
}

// -----------------------------------------------

// Thunk Actions
ThunkAction<AppState> setDetectionActive() {
  return (Store<AppState> store) {
    store.dispatch(SetDetectionActiveAction(true));
  };
}

ThunkAction<AppState> setDetectionDisabled() {
  return (Store<AppState> store) {
    store.dispatch(SetDetectionDisabledAction(false));
  };
}

ThunkAction<AppState> toggleDetection() {
  return (Store<AppState> store) {
    store.dispatch(SetDetectionDisabledAction(!store.state.detectionState));
  };
}

ThunkAction<AppState> setPredictions(List<Prediction> predictions) {
  return (Store<AppState> store) {
    store.dispatch(SetPredictions(predictions));
  };
}

ThunkAction<AppState> setCameras(List<CameraDescription> cameras) {
  return (Store<AppState> store) {
    store.dispatch(SetCameras(cameras));
  };
}

ThunkAction<AppState> toggleDebugState() {
  return (Store<AppState> store) {
    store.dispatch(ToggleDebugStateAction(!store.state.debugState));
  };
}
