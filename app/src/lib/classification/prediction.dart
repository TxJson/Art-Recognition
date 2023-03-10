import 'package:flutter/material.dart';
import 'dart:math';

enum PredictionStatus { ok, warning, error }

class Prediction {
  int id;
  String label;
  double probability;
  Rect boundary;

  Prediction(this.id, this.label, this.probability, this.boundary);

  int get getId => id;
  String get getLabel => label;
  double get getProbability => probability;
  Rect get getBoundary => boundary;

  Rect get renderLocation {
    // ratioX = screenWidth / imageInputWidth
    // ratioY = ratioX if image fits screenWidth with aspectRatio = constant

    double ratioX = 1; // TODO Set proper boundary
    double ratioY = ratioX;

    double transLeft = max(0.1, boundary.left * ratioX);
    double transTop = max(0.1, boundary.top * ratioY);
    double transWidth = min(boundary.width * ratioX,
        500); // TODO Set from proper width instead of 500
    double transHeight = min(boundary.height * ratioY,
        500); // TODO Set from proper height instead of 500

    Rect transformedRect =
        Rect.fromLTWH(transLeft, transTop, transWidth, transHeight);
    return transformedRect;
  }

  @override
  String toString() {
    return 'Prediction(id: $id, label: $label, probability: $probability), boundary: $boundary';
  }
}
