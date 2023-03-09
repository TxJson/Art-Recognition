import 'dart:isolate';

import 'package:art_app_fyp/detection/classifier.dart';
import 'package:art_app_fyp/detection/prediction.dart';
import 'package:art_app_fyp/shared/isolate/isolate_inference.dart';
import 'package:art_app_fyp/shared/isolate/isolate_model.dart';
import 'package:art_app_fyp/shared/utilities.dart';
import 'package:image/image.dart' as imglib;
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:art_app_fyp/shared/validators.dart';
import 'package:logger/logger.dart';
import 'dart:typed_data';

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
  late IsolateInference isolator;
  late Classifier classifier;
  late Logger logger;

  bool isPredicting = false;

  @override
  void initState() {
    super.initState();
    initDefaults();
    initCamera();
  }

  void initDefaults() async {
    classifier = Classifier(labels: DEFAULT_LABELS, model: DEFAULT_MODEL);
    logger = Logger();

    isolator = IsolateInference();
    await isolator.start();
  }

  void initCamera() {
    controller = CameraController(
        widget.cameras[widget.activeCameraIndex], ResolutionPreset.low);
    controller.initialize().then((_) async {
      if (!mounted) {
        return;
      }

      await controller.startImageStream(cameraStream);
    }).catchError((Object e) {
      if (e is CameraException) {
        switch (e.code) {
          case 'CameraAccessDenied':
            logger.w('ERROR when accessing the camera ${e.description}');
            break;
          default:
            logger.w('ERROR occured ${e.description}');
            break;
        }
        throw Exception(e.description);
      }
    });
  }

  void cameraStream(CameraImage cameraImage) async {
    // if (isPredicting || classifier.interpreter == null) {
    //   if (classifier.interpreter == null) {
    //     logger.w('Classifier Interpreter is null');
    //   }
    //   return;
    // }

    // isPredicting = true;

    // imglib.Image image = Utilities.convertYUV420ToImage(cameraImage);
    // classifier.predictItem(image);

    // // logger.i(results);

    // // logger.i('hello $results');

    // isPredicting = false;

    if (!isInitialized()) {
      return;
    }

    setState(() {
      isPredicting = true;
    });

    dynamic results = await predictIsolate(cameraImage);

    setState(() {
      isPredicting = false;
    });
  }

  bool isInitialized() {
    return !classifier.interDefined ||
        isPredicting ||
        isolator.sendPortInitialized;
  }

  Future<dynamic> predictIsolate(CameraImage cameraImage) async {
    IsolateModel isolateModel = IsolateModel(
        interpreterAddress: classifier.interAddress,
        cameraImage: cameraImage,
        labels: classifier.listOfLabels);

    // Start isolator
    ReceivePort responsePort = ReceivePort();
    isolator.sendPort.send(isolateModel..responsePort = responsePort.sendPort);

    dynamic response = await responsePort.first;
    return response;
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
