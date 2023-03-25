import 'package:art_app_fyp/shared/helpers/models/model.dart';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:logger/logger.dart';

class Models {
  String _path; // Path to models.json or equivalent

  late List<Model> _models;
  late Logger logger = Logger();
  int _defaultModel = -1;

  bool _isInitialized = false;

  Models({required String path}) : _path = path;

  Future load({withLabels = true}) async {
    String data = await rootBundle.loadString(_path);
    Map<String, dynamic> jsonData = await json.decode(data);
    dynamic keys = jsonData.keys;

    _models = [];

    // Use future for fully async
    // Models need to load before anything else can be used in this class
    await Future.forEach(keys, (String key) {
      final obj = jsonData[key];
      final path = 'assets/${obj["path"]}';
      Model model = Model(
          name: key,
          modelPath: '$path/${obj["model"]}',
          labelsPath: '$path/${obj["labels"]}',
          available: obj['available'],
          detectionsCount: obj['detections_count'] ?? -1);

      _models.add(model);
    });

    if (withLabels) {
      await loadLabels();
    }

    _isInitialized = true;
  }

  Future loadLabels() async {
    for (final model in _models) {
      await model.loadLabels();
    }
  }

  int getIndexByName(String name) {
    final index = _models.indexWhere((model) => model.name == name);
    return index;
  }

  Model getByName(String name) {
    final index = getIndexByName(name);
    return models[index];
  }

  void setDefault(dynamic model) {
    // Checking twice to be able to warn incase wrong type has been passed
    if (model is int || model is String) {
      if (model is int) {
        _defaultModel = model;
      } else if (model is String) {
        _defaultModel = getIndexByName(model);
      }

      models[_defaultModel].setActive(true);

      return;
    }

    logger.w('Unable to set default model to $model');
  }

  /// Ensure that if you set a model a active, that it actually is.
  /// If not, it may cause confusion
  void setActive(dynamic item, bool state) {
    // Checking twice to be able to warn incase wrong type has been passed
    if (item is int || item is String) {
      if (item is int) {
        models[item].setActive(state);
      } else if (item is String) {
        getByName(item).setActive(state);
      }

      return;
    }

    logger.w('Unable to set item $item to active state $state');
  }

  /// Currently we only allow one model at a time to be active
  /// This may change in the future...
  Model getActive() {
    final index = _models.indexWhere((model) => model.active == true);
    return _models[index];
  }

  String get path => _path;
  List<Model> get models => _models;
  bool get isInitialized => _isInitialized;

  Model get defaultModel => _models[_defaultModel];
}
