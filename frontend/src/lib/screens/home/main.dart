import 'package:art_app_fyp/shared/widgets/debug.dart';
import 'package:art_app_fyp/store/actions.dart';
import 'package:art_app_fyp/screens/home/camera.dart';
import 'package:art_app_fyp/shared/utilities.dart';
import 'package:flutter/material.dart';
import 'package:art_app_fyp/store/appstate.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:camera/camera.dart';

class MyHome extends StatelessWidget {
  const MyHome({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: const BoxDecoration(color: Colors.green),
        child: StoreConnector<AppState, AppState>(
            converter: (store) => store.state,
            builder: (context, state) {
              return Scaffold(

                  /// Set camera view from StoreConnector
                  body: Center(
                    child: CameraView(
                      cameras: state.cameras,
                      activeCameraIndex: state.activeCameraIndex,
                    ),
                  ),

                  /// Set button icon for detecting artwork
                  floatingActionButton: SizedBox(
                      height: 100,
                      child: Column(children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Text(state.detectionState ? 'Scanning...' : '',
                              style: TextStyle(
                                color: getHexColor('FFFFFF', opacity: 1),
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              )),
                        ),
                        SizedBox(
                          width: 80,
                          height: 75,
                          child: StoreConnector<AppState, dynamic>(
                              converter: (store) => store.dispatch,
                              builder: (context, dispatch) {
                                return Listener(
                                    onPointerDown: (event) {
                                      dispatch(setDetectionActive());
                                    },
                                    onPointerUp: (event) {
                                      dispatch(setDetectionDisabled());
                                    },
                                    child: FittedBox(
                                      child: FloatingActionButton(
                                        onPressed: () {},
                                        backgroundColor: Colors.black,
                                        splashColor:
                                            Colors.red.withOpacity(0.75),
                                        child: const Icon(
                                            Icons.center_focus_strong),
                                      ),
                                    ));
                              }),
                        )
                      ])),
                  floatingActionButtonLocation:
                      FloatingActionButtonLocation.centerFloat,

                  /// Debug functionality

                  bottomSheet: MyDebug(
                      debugState: state.debugState,
                      spacing: 20,
                      children: <Widget>[
                        Text(
                            'Detection Status: ${state.detectionState ? 'On' : 'Off'}'),
                        Text('Total Cameras: ${state.cameras.length}'),
                        Text('Active Camera Index: ${state.activeCameraIndex}')
                      ]));
            }));
  }
}
