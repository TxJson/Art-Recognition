import 'package:flutter/material.dart';

enum PredictionStatus { ok, warning, error }

class Prediction {
  int id;
  String label;
  double probability;
  // Rect? position;

  Prediction(this.id, this.label, this.probability);

  int get getId => id;
  String get getLabel => label;
  double get getProbability => probability;
  // Rect get getPosition => position!;

  @override
  String toString() {
    return 'Prediction(id: $id, label: $label, probability: $probability)';
  }
}
