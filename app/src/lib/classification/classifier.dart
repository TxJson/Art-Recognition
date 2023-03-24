import 'dart:typed_data';
import 'package:art_app_fyp/classification/tensor_processor.dart';
import 'package:art_app_fyp/classification/prediction.dart';
import 'package:art_app_fyp/screens/home/camera/cameraInfo.dart';
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
  final CameraInfo? cameraInfo;

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
      this.cameraInfo}) {
    // Model is optional in case
    if (interpreter == null && labels is String && model.isNotEmpty) {
      loadDefaults(model, labels);
    } else if (labels is List<String>) {
      labelList = (labels as List<String>).trim();
    }

    if (labelList.isNotEmpty) {
      processor = CustomTensorProcessor(
          labelList.length, labelList, interpreter!.address, threshold);
    }
  }

  // Will be initialized & loaded with loadLabels/loadModel
  List<String> labelList = [];

  // Output tensors
  List<int> outputShapes = [];
  List<int> outputTypes = [];

  // Used in image pre-processing
  ImageProcessor? imageProcessor;

  void loadDefaults(String model, String labels) async {
    if (labels.isEmpty) {
      // Warn if we are loading an empty list
      logger.w('No labels passed: ', labels);
      return;
    }
    loadLabels(labels);

    if (model.isEmpty) {
      // Warn if we are loading an empty list
      logger.w('No model passed: ', model);
      return;
    }
    loadModel(model);

    logger.i('Classifier default loaded successfully');
  }

  void loadLabels(String labels) async {
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

  void loadModel(String model) async {
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
  Map<String, dynamic> predictItem(Image image, {bool logEnabled = false}) {
    if (interpreter == null || interpreter!.isDeleted) {
      return {
        "status": PredictionStatus.error,
        "message": "Interpreter is null or deleted"
      };
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
        return {
          "status": PredictionStatus.error,
          "message":
              "Output Tensors buffer size does not match: ${outputTensor.getBuffers(outputBuffer)}\nInterpreter cannot run if the byte sizes do not match",
          "stop": true
        };
      }
    } else {
      return {
        "status": PredictionStatus.error,
        "message":
            "Image Input and Tensor Input byte size does not match: ${inputTensor.getBuffers(inputBuffer)}\nInterpreter cannot run if the byte sizes do not match",
        "stop": true
      };
    }

    List<Prediction> predictions = processor.postprocess(outputBuffer);

    return {
      "status": PredictionStatus.ok,
      "result": predictions,
    };
  }

  void close() {
    interpreter!.close();
  }

  int get interAddress => interpreter!.address;
  bool get interpreterDefined => interpreter != null;
  bool get interAllocated => interpreter!.isAllocated;
  List<String> get listOfLabels => labelList;
}
