import 'package:art_app_fyp/shared/helpers/utilities.dart';
import 'package:art_app_fyp/shared/helpers/validators.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:logger/logger.dart';
import 'package:tflite_flutter/tflite_flutter.dart';

class Model {
  final String _name;
  final String _modelPath; // Path to model
  final String _labelsPath; // Path to labels

  final bool _available; // Is the model available for use?
  final int _detectionsCount;
  int? _interpreterAddress;

  bool _active = false; // Is the model active?
  List<String> _labelList = []; // labels

  Logger logger = Logger();

  Model(
      {required String name,
      required String modelPath,
      required String labelsPath,
      required bool available,
      int? detectionsCount})
      : _name = name,
        _modelPath = modelPath,
        _labelsPath = labelsPath,
        _available = available,
        _detectionsCount = detectionsCount ??
            10; // Default to 10 if detectionsCount is not set

  Future loadLabels() async {
    _labelList = await rootBundle.loadString(_labelsPath).then((lbls) {
      return lbls.toString().split('\n');
    });

    // Remove empty spaces and characters
    _labelList.trim();
  }

  Future loadModel() async {
    // Interpreter prefers it without the "assets/"" string
    // Still want to allow it to be passed for clarity
    final modelPath = Utilities.removeIfExists(_modelPath, 'assets/');
    await Interpreter.fromAsset(modelPath).then((Interpreter interpreter) {
      _interpreterAddress = interpreter.address;
      logger.i('Successfully loaded model');
    }).catchError((Object e) {
      logger.e('An error occured while loading the model', e);
    });
  }

  String get name => _name;
  String get modelPath => _modelPath;
  String get labelsPath => _labelsPath;
  List<String> get labelList => _labelList;
  int get detectionsCount => _detectionsCount;
  int get interpreterAddress => _interpreterAddress ?? -1;
  bool get available => _available;
  bool get labelsLoaded => _labelList.isNotEmpty;
  bool get modelLoaded => _interpreterAddress != null;

  void setActive(state) => _active = state;
  bool get active => _active;
}
