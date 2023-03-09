import 'dart:isolate';

import 'package:camera/camera.dart';

class IsolateModel {
  int interpreterAddress;
  CameraImage cameraImage;
  List<String> labels;
  late SendPort responsePort;

  IsolateModel(
      {required this.interpreterAddress,
      required this.cameraImage,
      required this.labels});
}
