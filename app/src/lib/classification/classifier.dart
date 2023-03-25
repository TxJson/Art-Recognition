import 'dart:typed_data';
import 'package:art_app_fyp/classification/common_response.dart';
import 'package:art_app_fyp/classification/tensor_processor.dart';
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

  final String model; // Pass asset path, ex assets/model.tflite
  final dynamic labels; // Pass asset path, ex assets/labels.txt
  final int maxResults;

  final int threads;
  double threshold;

  Interpreter? interpreter;

  late CustomTensorProcessor processor;

  Classifier(
      {required this.labels,
      this.model = '',
      this.threshold = 0.5, // Threshold between 0 - 1
      this.threads = 4,
      this.interpreter,
      this.maxResults = 10});

  // Will be initialized & loaded with loadLabels/loadModel
  List<String> labelList = [];

  // Used in image pre-processing
  ImageProcessor? imageProcessor;

  Future load() async {
    if (labels is String) {
      if (labels.isEmpty) {
        // Warn if we are loading an empty list
        logger.w('No labels passed: ', labels);
        return;
      }
      await loadLabels(labels);
    } else if (labels is List<String>) {
      labelList = labels;
    } else {
      logger.w('Something went wrong when trying to retrieve the labels');
    }

    // Only necessary if we want to pass
    if (interpreter == null) {
      if (model.isEmpty) {
        // Warn if we are loading an empty list
        logger.w('No model passed: ', model);
        return;
      }
      await loadModel(model);
    }

    processor = CustomTensorProcessor(labelList.length, labelList,
        interpreter!.address, threshold, maxResults);

    // logger.i('Classifier default loaded successfully');
  }

  Future loadLabels(String labels) async {
    try {
      labelList = await rootBundle.loadString(labels).then((lbls) {
        return lbls.toString().split('\n');
      });

      if (labelList.isEmpty) {
        // Warn if we are loading an empty list
        logger.w('Label list is empty: ', labels);
      }
    } catch (e) {
      logger.e('An error occured while loading labels:', e);
    }
  }

  Future loadModel(String model) async {
    // Interpreter prefers it without the "assets/"" string
    // Still want to allow it to be passed for clarity
    model = Utilities.removeIfExists(model, 'assets/');

    await Interpreter.fromAsset(model).then((Interpreter _interpreter) {
      interpreter = _interpreter;
      logger.i('Successfully loaded model');
    }).catchError((Object e) {
      logger.e('An error occured while loading the model', e);
    });
  }

  /// @reallocate Set true to reallocate interpreter tensors
  ///
  /// Reallocate tensors if required, else skips
  void allocateInter({bool reallocate = false}) {
    if (interpreter == null) {
      logger.e('Interpreter was null when trying to allocate tensors');
      return;
    }

    if (interpreter!.isAllocated && !reallocate) {
      return;
    }

    interpreter!.allocateTensors();
  }

  // https://pub.dev/packages/tflite_flutter_helper
  /// Make prediction
  Message run(Image image) {
    if (interpreter == null || interpreter!.isDeleted) {
      return ResponseError.noInterpreter();
    }

    TensorImage inputImage = processor.preprocess(image);

    ByteBuffer inputBuffer = inputImage.buffer;
    TensorBuffer outputBuffer = TensorBuffer.createFixedSize(
        interpreter!.getOutputTensor(0).shape,
        interpreter!.getOutputTensor(0).type);

    Tensor inputTensor = interpreter!.getInputTensor(0);
    Tensor outputTensor = interpreter!.getOutputTensor(0);
    if (inputTensor.bufferMatch(inputBuffer)) {
      if (outputTensor.bufferMatch(outputBuffer)) {
        interpreter!.run(inputBuffer, outputBuffer);
      } else {
        return ResponseError.output(outputTensor.getBuffers(outputBuffer));
      }
    } else {
      return ResponseError.input(inputTensor.getBuffers(inputBuffer));
    }

    Tensor outputs = interpreter!.getOutputTensor(0);
    List<Prediction> predictions = processor.postprocess(outputs);

    logger.i(predictions.toString());

    return ResponseOk.createOk(predictions);
  }

  void close() {
    interpreter!.close();
  }

  int get interAddress => interpreter!.address;
  bool get interpreterDefined => interpreter != null;
  bool get interAllocated => interpreter!.isAllocated;
  List<String> get listOfLabels => labelList;
}
