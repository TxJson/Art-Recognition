import 'dart:isolate';

import 'package:art_app_fyp/screens/home/camera/cameraInfo.dart';
import 'package:camera/camera.dart';

class IsolateModel {
  int interpreterAddress;
  CameraImage cameraImage;
  List<String> labels;
  CameraInfo cameraInfo;
  final bool logEnabled;
  late SendPort responsePort;

  IsolateModel(
      {required this.interpreterAddress,
      required this.cameraImage,
      required this.labels,
      required this.cameraInfo,
      this.logEnabled = false});
}
