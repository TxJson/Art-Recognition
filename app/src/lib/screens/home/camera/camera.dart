import 'dart:isolate';

import 'package:art_app_fyp/classification/classifier.dart';
import 'package:art_app_fyp/shared/helpers/models/model.dart';
import 'package:art_app_fyp/shared/helpers/models/models.dart';
import 'package:art_app_fyp/shared/helpers/prediction.dart';
import 'package:art_app_fyp/shared/helpers/message.dart';
import 'package:art_app_fyp/shared/widgets/loader.dart';
import 'package:art_app_fyp/shared/isolate_inference/isolate_inference.dart';
import 'package:art_app_fyp/shared/isolate_inference/isolate_model.dart';
import 'package:art_app_fyp/shared/helpers/utilities.dart';
import 'package:image/image.dart' as imglib;
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:art_app_fyp/shared/helpers/validators.dart';
import 'package:logger/logger.dart';

// String DEFAULT_MODEL = 'assets/default_ssd_mobilenet/detect.tflite';
// String DEFAULT_LABELS = 'assets/default_ssd_mobilenet/labels.txt';
// String DEFAULT_MODEL = 'assets/yolov5_license_plates/detect.tflite';
// String DEFAULT_LABELS = 'assets/yolov5_license_plates/labels.txt';
// String DEFAULT_MODEL = 'assets/yolov5n_art_style/detect.tflite';
// String DEFAULT_LABELS = 'assets/yolov5n_art_style/labels.txt';
// String DEFAULT_MODEL = 'assets/default_yolov5/detect.tflite';
// String DEFAULT_LABELS = 'assets/default_yolov5/labels.txt';

// Adapted from Flutter Camera Package Documentation
// https://pub.dev/packages/camera
class CameraView extends StatefulWidget {
  final int _activeCameraIndex;
  final bool _detectionActive;
  final Models _models;

  /// Callback to pass results after inference to [HomeView]
  final Function(List<Prediction>) _resultsCallback;
  final Function(List<CameraDescription>) _setCameras;
  final Function(bool stop) _stopPredictions;

  // Default Constructor
  const CameraView(
      {Key? key,
      required int activeCameraIndex,
      required Models models,
      required dynamic Function(List<Prediction>) resultsCallback,
      required dynamic Function(List<CameraDescription>) setCameras,
      required dynamic Function(bool) stopPredictions,
      bool detectionActive = false})
      : _stopPredictions = stopPredictions,
        _setCameras = setCameras,
        _resultsCallback = resultsCallback,
        _models = models,
        _detectionActive = detectionActive,
        _activeCameraIndex = activeCameraIndex,
        super(key: key);

  Models get models => _models;

  @override
  State<CameraView> createState() => CameraViewState();
}

class CameraViewState extends State<CameraView> {
  late IsolateInference isolator;
  late Classifier classifier;
  late Model activeModel;
  late Logger logger;

  CameraController? controller;

  bool isPredicting = false;
  bool irregularOutput = false;

  @override
  void initState() {
    super.initState();
    initCamera();
    initDefaults();
  }

  void initDefaults() async {
    logger = Logger();

    activeModel = widget.models.getActive();

    // If the labels are already loaded, no need to load them again
    if (activeModel.labelsLoaded) {
      classifier = Classifier(
          labels: activeModel.labelList, model: activeModel.modelPath);
    } else {
      classifier = Classifier(
          labels: activeModel.labelsPath, model: activeModel.modelPath);
    }

    await classifier.load();

    isolator = IsolateInference();
    await isolator.start();
  }

  // Only call setState, if the component is mounted
  // Setting state when component is not active causes exceptions
  // this mitigate those exceptions
  void setStateIfMounted(void Function() func) {
    if (mounted) {
      setState(func);
    }
  }

  void initCamera() async {
    final List<CameraDescription> cameras = await availableCameras();
    widget._setCameras(cameras);
    controller = CameraController(
        cameras[widget._activeCameraIndex], ResolutionPreset.max,
        enableAudio: false);
    if (controller != null) {
      controller!.initialize().then((_) async {
        if (!mounted) {
          return;
        }

        await controller!.startImageStream(cameraStream);
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
  }

  void cameraStream(CameraImage cameraImage) async {
    if (isPredicting ||
        !isInitialized() ||
        !mounted ||
        !widget._detectionActive) {
      return;
    }

    setStateIfMounted(() {
      isPredicting = true;
    });

    if (isPredicting) {
      Message? response = await predictIsolate(cameraImage);
      List<Prediction>? predictionResponse = handleResponse(response);

      if (predictionResponse == null) {
        // If response is suddenly null, set predictions to an empty list
        widget._resultsCallback([]);
      } else {
        widget._resultsCallback(predictionResponse);
      }
    }

    setStateIfMounted(() {
      isPredicting = false;
    });
  }

  List<Prediction>? handleResponse(Message response) {
    if (response.status == OutcomeStatus.ok) {
      if (response.result is List<Prediction>) {
        return response.result;
      } else {
        return [];
      }
    } else {
      if (response.status == OutcomeStatus.warning) {
        logger.w(response.message);
      }

      if (response.status == OutcomeStatus.error) {
        logger.e(response.message);
      }

      if (response.action == BehaviorActions.stop) {
        widget._stopPredictions(true);
        setState(() {
          isPredicting = false;
        });
      }
    }

    return null;
  }

  /// Check if defaults has been initialized
  bool isInitialized() {
    return (classifier.interpreterDefined && isolator.sendPortInitialized);
  }

  Future<Message> predictIsolate(CameraImage cameraImage) async {
    int maxResults = activeModel.detectionsCount;
    IsolateModel isolateModel = IsolateModel(
        interpreterAddress: classifier.interAddress,
        cameraImage: cameraImage,
        labels: classifier.listOfLabels,
        maxResults: maxResults == -1 ? 10 : maxResults);

    // Start isolator
    ReceivePort responsePort = ReceivePort();
    isolator.sendPort.send(isolateModel..responsePort = responsePort.sendPort);

    Message response = await responsePort.first;
    return response;
  }

  @override
  void dispose() {
    controller!.dispose();
    classifier.close();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    if (controller == null) {
      return;
    }
    switch (state) {
      case AppLifecycleState.paused:
        controller!.stopImageStream();

        break;
      case AppLifecycleState.resumed:
        if (!controller!.value.isStreamingImages) {
          await controller!.startImageStream(cameraStream);
        }
        break;
      default:
    }
  }

  @override
  Widget build(BuildContext context) {
    if (controller == null || !controller!.value.isInitialized || !mounted) {
      // Use Maroon colour
      return Loader(
          milliseconds: 50,
          color: Utilities.getHexColor("#800000"),
          message: 'Loading Camera');
    }

    return MaterialApp(
        home: GestureDetector(

            /// Zoom functionality Adapted from:
            /// https://stackoverflow.com/questions/60424964/zoom-camera-in-flutter#:~:text=You%20can%20use%20cameraController.,limits%20for%20the%20zoom%20level.
            /// TODO: Known bug - When zooming in it always starts from 0
            onScaleUpdate: (details) async {
              double max = await controller!.getMaxZoomLevel();
              double min = await controller!.getMinZoomLevel();

              double dragIntensity = details.scale;
              if (dragIntensity < min) {
                controller!.setZoomLevel(min);
              } else if (dragIntensity.between(min, max)) {
                controller!.setZoomLevel(dragIntensity);
              } else if (dragIntensity > max) {
                controller!.setZoomLevel(max);
              }
            },
            child: CameraPreview(controller!)));
  }
}
