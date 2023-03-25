import 'package:art_app_fyp/shared/helpers/validators.dart';
import 'package:flutter/services.dart' show rootBundle;

class Model {
  String _name;
  String _modelPath; // Path to model
  String _labelsPath; // Path to labels

  bool _available; // Is the model available for use?
  int _detectionsCount;

  bool _active = false; // Is the model active?
  List<String> _labelList = []; // labels

  Model(
      {required String name,
      required String modelPath,
      required String labelsPath,
      required bool available,
      int detectionsCount = -1})
      : _name = name,
        _modelPath = modelPath,
        _labelsPath = labelsPath,
        _available = available,
        _detectionsCount = detectionsCount;

  Future loadLabels() async {
    _labelList = await rootBundle.loadString(_labelsPath).then((lbls) {
      return lbls.toString().split('\n');
    });

    // Remove empty spaces and characters
    _labelList.trim();
  }

  String get name => _name;
  String get modelPath => _modelPath;
  String get labelsPath => _labelsPath;
  List<String> get labelList => _labelList;
  int get detectionsCount => _detectionsCount;
  bool get available => _available;
  bool get labelsLoaded => _labelList.isNotEmpty;

  void setActive(state) => _active = state;
  bool get active => _active;
}
