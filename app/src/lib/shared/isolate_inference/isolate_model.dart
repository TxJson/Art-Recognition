import 'dart:isolate';

import 'package:camera/camera.dart';

class IsolateModel {
  final int _interpreterAddress;
  final CameraImage _cameraImage;
  final List<String> _labels;
  final int _maxResults;
  late SendPort responsePort;

  IsolateModel(
      {required int interpreterAddress,
      required CameraImage cameraImage,
      required List<String> labels,
      int? maxResults})
      : _interpreterAddress = interpreterAddress,
        _cameraImage = cameraImage,
        _labels = labels,
        _maxResults = maxResults ?? 10;

  int get interpreterAddress => _interpreterAddress;
  CameraImage get cameraImage => _cameraImage;
  List<String> get labels => _labels;
  int get maxResults => _maxResults;
}
