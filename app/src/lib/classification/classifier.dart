import 'dart:math';
import 'dart:typed_data';
import 'dart:ui';
import 'package:art_app_fyp/classification/prediction.dart';
import 'package:art_app_fyp/shared/utilities.dart';
import 'package:logger/logger.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:image/image.dart' as imglib;

// TFLite Packages
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:tflite_flutter_helper/tflite_flutter_helper.dart';

class Classifier {
  var logger = Logger();

  final String model; // Pass asset path, ex assets/model.tflite
  final dynamic labels; // Pass asset path, ex assets/labels.txt

  final int threads;
  double threshold;

  // Some datasets return outputs between 0-100 instead of 0-1

  Interpreter? interpreter;

  Classifier(
      {required this.labels,
      this.model = '',
      this.threshold = 0.5, // Threshold between 0 - 1
      this.threads = 4,
      this.interpreter}) {
    // Model is optional in case
    if (interpreter == null && labels is String && model.isNotEmpty) {
      loadDefaults(model, labels);
    } else if (labels is List) {
      labelList = labels;
    }

    // // Most outputs will return a value between 0-1
    // // But some are irregular, their output will be between 0-100
    // if (irregularOutput) {
    //   threshold *= 100;
    // }
  }

  // Will be initialized & loaded with loadLabels/loadModel
  List<String> labelList = [];

  // Output tensors
  List<int> outputShapes = [];
  List<int> outputTypes = [];

  // Used in image pre-processing
  late ImageProcessor imageProcessor;

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

    interpreter = await Interpreter.fromAsset(model,
            options: InterpreterOptions()..threads = 4)
        .catchError((Object e) {
      logger.e('An error occured while loading the model:', e);
    });
  }

  void logInfo(TensorImage inputImage) {
    logger.i('Label Count: ${labelList.length}');

    logger.i(
      'Output shape: ${interpreter!.getOutputTensor(0).shape}, '
      'type: ${interpreter!.getOutputTensor(0).type}',
    );

    logger.i('Input shape ${interpreter!.getInputTensor(0).shape}, '
        'type: ${interpreter!.getInputTensor(0).type}, '
        'length: ${interpreter!.getInputTensor(0).shape.length}');

    logger.i('Pre-processed image: ${inputImage.width}x${inputImage.height}, '
        'size: ${inputImage.buffer.lengthInBytes} bytes, '
        'type: ${inputImage.dataType}');
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

  TensorImage preprocessInput(imglib.Image image) {
    final inputTensor = TensorImage.fromImage(image);

    final minLength = min(inputTensor.height, inputTensor.width);
    final shapeLength = interpreter!.getInputTensor(0).shape[1];
    final quantOps = interpreter!.getInputTensor(0).params;

    final imageProcessor = ImageProcessorBuilder()
        .add(ResizeWithCropOrPadOp(minLength, minLength))
        .add(ResizeOp(shapeLength, shapeLength, ResizeMethod.BILINEAR))
        // .add(NormalizeOp(127.5, 127.5))
        // .add(QuantizeOp(quantOps.zeroPoint.toDouble(), quantOps.scale))
        .build();

    imageProcessor.process(inputTensor);
    return inputTensor;
  }

  List<Prediction> processOutput(TensorBuffer output) {
    // final outputs = 1 / (1 + exp(-output))
    final predictionProcessor = TensorProcessorBuilder().build();
    final processedOutput = predictionProcessor.process(output);

    // Create label map
    TensorLabel tensorLabels = TensorLabel.fromList(labelList, processedOutput);
    List<Category> processedLabels = tensorLabels.getCategoryList();

    // Find predictions within threshold
    List<Prediction> predictions = [];
    Category cat;
    double probability;
    for (int i = 0; i < processedLabels.length; i++) {
      cat = processedLabels.elementAt(i);

      // Score not quantized so split by 255.0
      probability = cat.score / 255.0;

      if (probability > 0.5) {
        predictions.add(Prediction(i, cat.label, probability));
      }
    }

    return predictions;
  }

  // https://pub.dev/packages/tflite_flutter_helper
  Map<String, dynamic> predictItem(imglib.Image image,
      {bool logEnabled = false}) {
    if (interpreter == null || interpreter!.isDeleted) {
      return {
        "status": PredictionStatus.error,
        "message": "Interpreter is null or deleted"
      };
    }

    TensorImage inputImage = preprocessInput(image);
    TensorBuffer output = TensorBuffer.createFixedSize(
        interpreter!.getOutputTensor(0).shape,
        interpreter!.getOutputTensor(0).type);

    if (logEnabled) {
      logInfo(inputImage);
    }

    interpreter!.run(inputImage.tensorBuffer.buffer, output.buffer);

    List<Prediction> predictions = processOutput(output);
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
