import 'package:art_app_fyp/store/appstate.dart';
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

class ToggleDebugStateAction extends ReduxAction<bool> {
  ToggleDebugStateAction(bool debugState) : super(debugState);
}

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

ThunkAction<AppState> toggleDebugState() {
  return (Store<AppState> store) {
    store.dispatch(ToggleDebugStateAction(!store.state.debugState));
  };
}
