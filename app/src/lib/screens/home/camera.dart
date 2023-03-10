import 'dart:isolate';

import 'package:art_app_fyp/classification/classifier.dart';
import 'package:art_app_fyp/classification/prediction.dart';
import 'package:art_app_fyp/shared/isolate/isolate_inference.dart';
import 'package:art_app_fyp/shared/isolate/isolate_model.dart';
import 'package:image/image.dart' as imglib;
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:art_app_fyp/shared/validators.dart';
import 'package:logger/logger.dart';
import 'dart:typed_data';

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

// String DEFAULT_MODEL = 'assets/default_ssd_mobilenet/ssd_mobilenet.tflite';
// String DEFAULT_LABELS = 'assets/default_ssd_mobilenet/labels.txt';
String DEFAULT_MODEL = 'assets/yolov5_license_plates/yolov5n-fp16.tflite';
String DEFAULT_LABELS = 'assets/yolov5_license_plates/labels.txt';

class CameraViewState extends State<CameraView> {
  late CameraController controller;
  late IsolateInference isolator;
  late Classifier classifier;
  late Logger logger;
  late List<Prediction> predictions;

  bool isPredicting = false;
  bool irregularOutput = false;

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
    if (isPredicting || !isInitialized()) {
      return;
    }

    setState(() {
      isPredicting = true;
    });

    Map<String, dynamic> response = await predictIsolate(cameraImage);
    List<Prediction>? predictionResponse = handleResponse(response);

    setState(() {
      if (predictionResponse == null) {
        // If response is suddenly null, set predictions to an empty list
        predictions = [];
      } else {
        predictions = predictionResponse;
      }
    });

    setState(() {
      isPredicting = false;
    });
  }

  List<Prediction>? handleResponse(Map<String, dynamic> response) {
    if (response['status'] == PredictionStatus.ok) {
      return response['result'];
    } else if (response['status'] == PredictionStatus.warning) {
      logger.w(response['message']);
    } else if (response['status'] == PredictionStatus.error) {
      logger.e(response['message']);
    }

    return null;
  }

  /// Check if defaults has been initialized
  bool isInitialized() {
    return (classifier.interpreterDefined && isolator.sendPortInitialized);
  }

  Future<Map<String, dynamic>> predictIsolate(CameraImage cameraImage) async {
    IsolateModel isolateModel = IsolateModel(
        interpreterAddress: classifier.interAddress,
        cameraImage: cameraImage,
        labels: classifier.listOfLabels,
        logEnabled: false);

    // Start isolator
    ReceivePort responsePort = ReceivePort();
    isolator.sendPort.send(isolateModel..responsePort = responsePort.sendPort);

    Map<String, dynamic> response = await responsePort.first;
    return response;
  }

  @override
  void dispose() {
    controller.dispose();
    classifier.close();
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
