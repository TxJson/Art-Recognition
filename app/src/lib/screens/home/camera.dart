import 'package:art_app_fyp/detection/classifier.dart';
import 'package:art_app_fyp/detection/prediction.dart';
import 'package:art_app_fyp/shared/utilities.dart';
import 'package:image/image.dart' as imglib;
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:art_app_fyp/shared/validators.dart';
import 'package:logger/logger.dart';

// import 'package:tflite/tflite.dart';

import 'dart:math' as math;

import 'package:tflite_flutter/tflite_flutter.dart';

// Adapted from Flutter Camera Package Documentation
// https://pub.dev/packages/camera
class CameraView extends StatefulWidget {
  final List<CameraDescription> cameras;
  final int activeCameraIndex;

  /// Callback to pass results after inference to [HomeView]
  // final Function(List<Prediction>) resultsCallback;

  // Default Constructor
  const CameraView(
      {Key? key, required this.cameras, required this.activeCameraIndex})
      : super(key: key);

  @override
  State<CameraView> createState() => CameraViewState();
}

String DEFAULT_MODEL = 'assets/ssd_mobilenet.tflite';
String DEFAULT_LABELS = 'assets/labels.txt';

class CameraViewState extends State<CameraView> {
  late CameraController controller;
  bool isPredicting = false;
  Logger logger = Logger();
  Classifier classifier =
      Classifier(labels: DEFAULT_LABELS, model: DEFAULT_MODEL);

  @override
  void initState() {
    super.initState();
    controller = CameraController(
        widget.cameras[widget.activeCameraIndex], ResolutionPreset.max);
    controller.initialize().then((_) async {
      if (!mounted) {
        return;
      }

      setState(() {});

      await controller.startImageStream((CameraImage cameraImage) {
        if (isPredicting || classifier.interpreter == null) {
          if (classifier.interpreter == null) {
            logger.w('Classifier Interpreter is null');
          }
          return;
        }

        imglib.Image img = Utilities.convertToYUV420(cameraImage);
        List<Prediction>? results = classifier.predictItem(img);

        logger.i('hello $results');

        isPredicting = false;
      });
    }).catchError((Object e) {
      if (e is CameraException) {
        switch (e.code) {
          case 'CameraAccessDenied':
            // Handle access errors here.
            break;
          default:
            // Handle other errors here.
            break;
        }
      }
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!controller.value.isInitialized) {
      return Container();
    }

    // var tmp = MediaQuery.of(context).size;
    // var screenH = math.max(tmp.height, tmp.width);
    // var screenW = math.min(tmp.height, tmp.width);

    // tmp = controller.value.previewSize as Size;
    // var previewH = math.max(tmp.height, tmp.width);
    // var previewW = math.min(tmp.height, tmp.width);
    // var screenRatio = screenH / screenW;
    // var previewRatio = previewH / previewW;

    // return OverflowBox(
    //   maxHeight:
    //       screenRatio > previewRatio ? screenH : screenW / previewW * previewH,
    //   maxWidth:
    //       screenRatio > previewRatio ? screenH / previewH * previewW : screenW,
    //   child: CameraPreview(controller),
    // );

    return MaterialApp(
        home: GestureDetector(

            /// Zoom functionality Adapted from:
            /// https://stackoverflow.com/questions/60424964/zoom-camera-in-flutter#:~:text=You%20can%20use%20cameraController.,limits%20for%20the%20zoom%20level.
            /// TODO: Known bug - When zooming in it always starts from 0
            onScaleUpdate: (details) async {
              double max = await controller.getMaxZoomLevel();
              double min = await controller.getMinZoomLevel();

              double dragIntensity = details.scale;
              if (dragIntensity < min) {
                controller.setZoomLevel(min);
              } else if (dragIntensity.between(min, max)) {
                controller.setZoomLevel(dragIntensity);
              } else if (dragIntensity > max) {
                controller.setZoomLevel(max);
              }
            },
            child: CameraPreview(controller)));
  }
}
