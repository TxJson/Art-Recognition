import 'package:art_app_fyp/shared/helpers/math/vector2.dart';
import 'package:flutter/material.dart';
import 'dart:math';

class Prediction {
  int id;
  String label;
  double probability;

  Prediction(this.id, this.label, this.probability);

  int get getId => id;
  String get getLabel => label;
  double get getProbability => probability;

  String formatString() {
    final percentageProbability = (probability * 100).toStringAsFixed(2);

    return '${label.trim()} - $percentageProbability%';
  }

  @override
  String toString() {
    return 'Prediction(id: $id, label: $label, probability: $probability)';
  }
}
