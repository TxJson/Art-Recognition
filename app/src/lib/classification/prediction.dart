import 'package:art_app_fyp/screens/home/camera/cameraInfo.dart';
import 'package:art_app_fyp/shared/helpers/math/vector2.dart';
import 'package:flutter/material.dart';
import 'dart:math';

enum PredictionStatus { ok, warning, error }

class Prediction {
  int id;
  String label;
  double probability;
  Rect boundary;
  CameraInfo? cameraInfo;

  Prediction(
      this.id, this.label, this.probability, this.boundary, this.cameraInfo);

  int get getId => id;
  String get getLabel => label;
  double get getProbability => probability;
  Rect get getBoundary => boundary;
  CameraInfo? get getCameraInfo => cameraInfo;

  Rect get renderBoundingBox {
    if (cameraInfo == null) {
      return Rect.zero;
    }

    Vector2 ratio = cameraInfo!.getRatio;

    double transLeft = max(0.1, boundary.left * ratio.x);
    double transTop = max(0.1, boundary.top * ratio.x);
    double transWidth =
        min(boundary.width * ratio.x, cameraInfo!.getActualPreviewSize.width);
    double transHeight =
        min(boundary.height * ratio.x, cameraInfo!.getActualPreviewSize.height);

    Rect transformedRect =
        Rect.fromLTWH(transLeft, transTop, transWidth, transHeight);
    return transformedRect;
  }

  @override
  String toString() {
    return 'Prediction(id: $id, label: $label, probability: $probability), boundary: $boundary';
  }
}
