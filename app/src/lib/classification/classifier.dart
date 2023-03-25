import 'dart:typed_data';
import 'package:art_app_fyp/classification/common_response.dart';
import 'package:art_app_fyp/classification/tensor_processor.dart';
import 'package:art_app_fyp/shared/helpers/models/model.dart';
import 'package:art_app_fyp/shared/helpers/prediction.dart';
import 'package:art_app_fyp/shared/helpers/message.dart';
import 'package:art_app_fyp/shared/helpers/utilities.dart';
import 'package:logger/logger.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:image/image.dart';

// Validators
import 'package:art_app_fyp/shared/helpers/validators.dart';

// TFLite Packages
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:tflite_flutter_helper/tflite_flutter_helper.dart';

class Classifier {
  var logger = Logger();

  final Model _model;

  double threshold;

  late CustomTensorProcessor processor;
  late Interpreter _interpreter;

  Classifier(
      {required Model model, this.threshold = 0.5}) // Threshold between 0 - 1})
      : _model = model;

  // Used in image pre-processing
  ImageProcessor? imageProcessor;

  Future load() async {
    if (!_model.labelsLoaded) {
      await _model.loadLabels();
    }
    // if (labels is String) {
    //   if (labels.isEmpty) {
    //     // Warn if we are loading an empty list
    //     logger.w('No labels passed: ', labels);
    //     return;
    //   }
    //   await loadLabels(labels);
    // } else if (labels is List<String>) {
    //   labelList = labels;
    // } else {
    //   logger.w('Something went wrong when trying to retrieve the labels');
    // }

    // Only necessary if we want to pass
    if (!_model.modelLoaded) {
      if (_model.modelPath.isEmpty) {
        // Warn if we are loading an empty list
        logger.w('No model passed: ', _model);
        return;
      }
      await _model.loadModel();
    }

    final address = _model.interpreterAddress;
    if (address != -1) {
      // Set interpreter from the address stored in the passed in model
      _interpreter = Interpreter.fromAddress(address);

      final labelList = _model.labelList;
      processor = CustomTensorProcessor(labelList.length, labelList, address,
          threshold, _model.detectionsCount);
    }
  }

  // Future loadLabels(String labels) async {
  //   try {
  //     labelList = await rootBundle.loadString(labels).then((lbls) {
  //       return lbls.toString().split('\n');
  //     });

  //     if (labelList.isEmpty) {
  //       // Warn if we are loading an empty list
  //       logger.w('Label list is empty: ', labels);
  //     }
  //   } catch (e) {
  //     logger.e('An error occured while loading labels:', e);
  //   }
  // }

  // Future loadModel(String model) async {
  //   // Interpreter prefers it without the "assets/"" string
  //   // Still want to allow it to be passed for clarity
  //   model = Utilities.removeIfExists(model, 'assets/');

  //   await Interpreter.fromAsset(model).then((Interpreter _interpreter) {
  //     interpreter = _interpreter;
  //     logger.i('Successfully loaded model');
  //   }).catchError((Object e) {
  //     logger.e('An error occured while loading the model', e);
  //   });
  // }

  /// @reallocate Set true to reallocate interpreter tensors
  ///
  /// Reallocate tensors if required, else skips
  void allocateInter({bool reallocate = false}) {
    if (_interpreter == null) {
      logger.e('Interpreter was null when trying to allocate tensors');
      return;
    }

    if (_interpreter.isAllocated && !reallocate) {
      return;
    }

    _interpreter.allocateTensors();
  }

  // https://pub.dev/packages/tflite_flutter_helper
  /// Make prediction
  Message run(Image image) {
    if (_interpreter == null || _interpreter.isDeleted) {
      return ResponseError.noInterpreter();
    }

    TensorImage inputImage = processor.preprocess(image);

    ByteBuffer inputBuffer = inputImage.buffer;
    TensorBuffer outputBuffer = TensorBuffer.createFixedSize(
        _interpreter.getOutputTensor(0).shape,
        _interpreter.getOutputTensor(0).type);

    Tensor inputTensor = _interpreter.getInputTensor(0);
    Tensor outputTensor = _interpreter.getOutputTensor(0);
    if (inputTensor.bufferMatch(inputBuffer)) {
      if (outputTensor.bufferMatch(outputBuffer)) {
        _interpreter.run(inputBuffer, outputBuffer);
      } else {
        return ResponseError.output(outputTensor.getBuffers(outputBuffer));
      }
    } else {
      return ResponseError.input(inputTensor.getBuffers(inputBuffer));
    }

    Tensor outputs = _interpreter.getOutputTensor(0);
    List<Prediction> predictions = processor.postprocess(outputs);

    return ResponseOk.createOk(predictions);
  }

  void close() {
    _interpreter.close();
  }

  int get interAddress => _interpreter.address;
  bool get interpreterDefined => _interpreter != null;
  bool get interAllocated => _interpreter.isAllocated;
}
