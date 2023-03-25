import 'package:art_app_fyp/screens/home/prediction_display.dart';
import 'package:art_app_fyp/shared/helpers/prediction.dart';
import 'package:art_app_fyp/shared/widgets/box.dart';
import 'package:art_app_fyp/screens/home/footer_buttons.dart';
import 'package:art_app_fyp/shared/helpers/utilities.dart';
import 'package:art_app_fyp/shared/widgets/debugStatus.dart';
import 'package:art_app_fyp/screens/home/camera/camera.dart';
import 'package:art_app_fyp/store/actions.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:art_app_fyp/store/appstate.dart';
import 'package:flutter_redux/flutter_redux.dart';

class MyHome extends StatelessWidget {
  const MyHome({Key? key}) : super(key: key);

  // Future<void> loadModel() async {
  //   String res = await Tflite.loadModel(
  //       model: "assets/ssd_mobilenet.tflite",
  //       labels: "assets/labels.txt",
  //       numThreads: 1, // defaults to 1
  //       isAsset:
  //           true, // defaults to true, set to false to load resources outside assets
  //       useGpuDelegate:
  //           false // defaults to false, set to true to use GPU delegate
  //       );
  // }

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: const BoxDecoration(color: Colors.green),
        child: StoreConnector<AppState, dynamic>(
            converter: (store) => store,
            builder: (context, store) {
              return Scaffold(
                backgroundColor: Colors.black,

                /// Set camera view from StoreConnector
                body: Stack(children: <Widget>[
                  CameraView(
                      detectionActive: store.state.detectionState,
                      activeCameraIndex: store.state.activeCameraIndex,
                      models: store.state.models,
                      resultsCallback: (List<Prediction> predictions) {
                        store.dispatch(SetPredictions(predictions));
                      },
                      setCameras: (List<CameraDescription> cameras) {
                        store.dispatch(cameras);
                      },
                      stopPredictions: (bool stop) {
                        if (stop) {
                          store.dispatch(setDetectionDisabled());
                        }
                      }),
                ]),
                persistentFooterButtons: <Widget>[
                  FooterButtons(
                      visible: store.state.debugTools,
                      icon: const Icon(Icons.adb),
                      text: 'Debug',
                      backgroundColor: !store.state.debugState
                          ? Colors.green
                          : Utilities.getHexColor("#800000"),
                      onPressed: () => store.dispatch(toggleDebugState())),
                  FooterButtons(
                      visible: store.state.debugTools,
                      icon: const Icon(Icons.center_focus_strong),
                      text: 'Detection',
                      backgroundColor: !store.state.detectionState
                          ? Colors.green
                          : Utilities.getHexColor("#800000"),
                      onPressed: () => store.dispatch(toggleDetection()))
                ],
                bottomSheet: PredictionDisplay(
                    predictions: store.state.predictions,
                    detectionState: store.state.detectionState),

                /// Set button icon for detecting artwork
                // floatingActionButton: SizedBox(
                //     height: 100,
                //     child: Column(children: <Widget>[
                //       Padding(
                //         padding: const EdgeInsets.only(bottom: 10),
                //         child: Text(state.detectionState ? 'Scanning...' : '',
                //             style: TextStyle(
                //               color: Utilities.getHexColor('FFFFFF', opacity: 1),
                //               fontWeight: FontWeight.bold,
                //               fontSize: 15,
                //             )),
                //       ),
                //       SizedBox(
                //         width: 80,
                //         height: 75,
                //         child: StoreConnector<AppState, dynamic>(
                //             converter: (store) => store.dispatch,
                //             builder: (context, dispatch) {
                //               return Listener(
                //                   onPointerDown: (event) {
                //                     dispatch(setDetectionActive());
                //                   },
                //                   onPointerUp: (event) {
                //                     dispatch(setDetectionDisabled());
                //                   },
                //                   child: FittedBox(
                //                     child: FloatingActionButton(
                //                       onPressed: () {},
                //                       backgroundColor: Colors.black,
                //                       splashColor:
                //                           Colors.red.withOpacity(0.75),
                //                       child: const Icon(
                //                           Icons.center_focus_strong),
                //                     ),
                //                   ));
                //             }),
                //       )
                //     ])),
                // floatingActionButtonLocation:
                //     FloatingActionButtonLocation.centerFloat,
              );
            }));
  }
}

// Widget boundingBoxes(List<Prediction>? predictions) {
//   if (predictions == null) {
//     return Container();
//   }

//   return Stack(
//     children: predictions
//         .map((prediction) => BoxWidget(
//               prediction,
//             ))
//         .toList(),
//   );
// }
