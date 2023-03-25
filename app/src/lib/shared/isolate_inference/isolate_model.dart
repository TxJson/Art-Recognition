import 'dart:isolate';

import 'package:art_app_fyp/shared/helpers/models/model.dart';
import 'package:camera/camera.dart';

class IsolateModel {
  final CameraImage _cameraImage;
  final Model _activeModel;
  late SendPort responsePort;

  IsolateModel({required CameraImage cameraImage, required Model activeModel})
      : _cameraImage = cameraImage,
        _activeModel = activeModel;

  CameraImage get cameraImage => _cameraImage;
  Model get activeModel => _activeModel;
}
