import 'dart:math';
import 'dart:typed_data';
import 'package:art_app_fyp/classification/prediction.dart';
import 'package:art_app_fyp/screens/home/camera/cameraInfo.dart';
import 'package:art_app_fyp/shared/helpers/utilities.dart';
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
  final CameraInfo? cameraInfo;

  final int threads;
  double threshold;

  Interpreter? interpreter;

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
    TensorImage inputTensor = TensorImage.fromImage(image);

    final minLength = min(inputTensor.height, inputTensor.width);
    final shapeLength = interpreter!.getInputTensor(0).shape[1];

    // final quantOps = interpreter!.getInputTensor(0).params;

    imageProcessor ??= ImageProcessorBuilder()
        .add(ResizeWithCropOrPadOp(minLength, minLength))
        .add(ResizeOp(shapeLength, shapeLength, ResizeMethod.NEAREST_NEIGHBOUR))
        .add(NormalizeOp(0, 255))
        .build();

    inputTensor = imageProcessor!.process(inputTensor);

    return inputTensor;
  }

  // List<Prediction> processOutput(TensorBuffer outputLocations,
  //     TensorBuffer outputScores, int inputSize, imglib.Image image) {
  //   // final outputs = 1 / (1 + exp(-output))
  //   final predictionProcessor = TensorProcessorBuilder().build();
  //   final processedOutput = predictionProcessor.process(outputScores);

  //   // Create label map
  //   TensorLabel tensorLabels = TensorLabel.fromList(labelList, processedOutput);
  //   List<Category> processedLabels = tensorLabels.getCategoryList();

  //   List<Rect> boundingBoxes = BoundingBoxUtils.convert(
  //     tensor: outputLocations,
  //     valueIndex: [1, 0, 3, 2],
  //     boundingBoxAxis: -2,
  //     boundingBoxType: BoundingBoxType.BOUNDARIES,
  //     coordinateType: CoordinateType.RATIO,
  //     height: inputSize,
  //     width: inputSize,
  //   );

  //   // Find predictions within threshold
  //   List<Prediction> predictions = [];
  //   Category cat;
  //   double probability;
  //   for (int i = 0; i < processedLabels.length; i++) {
  //     cat = processedLabels.elementAt(i);

  //     // Score not quantized so split by 255.0
  //     probability = cat.score / 255.0;
  //     if (probability > 0.5) {
  //       Rect rectBoundary = imageProcessor.inverseTransformRect(
  //           boundingBoxes[i], image.height, image.width);
  //       predictions.add(
  //           Prediction(i, cat.label, probability, rectBoundary, cameraInfo));
  //     }
  //   }

  //   return predictions;
  // }

  // // Borrowed from package example - https://github.com/am15h/object_detection_flutter/blob/master/lib/tflite/classifier.dart
  // List<Prediction> processOutput2(
  //     TensorBuffer outputLocations,
  //     TensorBuffer outputClasses,
  //     TensorBuffer outputScores,
  //     TensorBuffer numLocations,
  //     int inputSize,
  //     imglib.Image image) {
  //   // Maximum number of results to show
  //   int resultsCount = min(10, numLocations.getIntValue(0));

  //   // Using labelOffset = 1 as ??? at index 0
  //   int labelOffset = 1;

  //   // Using bounding box utils for easy conversion of tensorbuffer to List<Rect>
  //   List<Rect> locations = BoundingBoxUtils.convert(
  //     tensor: outputLocations,
  //     valueIndex: [1, 0, 3, 2],
  //     boundingBoxAxis: 2,
  //     boundingBoxType: BoundingBoxType.BOUNDARIES,
  //     coordinateType: CoordinateType.RATIO,
  //     height: inputSize,
  //     width: inputSize,
  //   );

  //   List<Prediction> predictions = [];

  //   for (int i = 0; i < resultsCount; i++) {
  //     // Prediction score
  //     double probability = outputScores.getDoubleValue(i);

  //     // Label string
  //     int labelIndex = outputClasses.getIntValue(i) + labelOffset;
  //     String label = labelList.elementAt(labelIndex);

  //     if (probability > threshold) {
  //       // inverse of rect
  //       // [locations] corresponds to the image size 300 X 300
  //       // inverseTransformRect transforms it our [inputImage]
  //       Rect transformedRect = imageProcessor.inverseTransformRect(
  //           locations[i], image.height, image.width);

  //       predictions.add(
  //         Prediction(i, label, probability, transformedRect, cameraInfo),
  //       );
  //     }
  //   }

  //   return predictions;
  // }

  List<Prediction> processOutput3(
      TensorBuffer output, int inputSize, imglib.Image image) {
    // final outputs = 1 / (1 + exp(-output))
    final predictionProcessor = TensorProcessorBuilder().build();
    final processedOutput = predictionProcessor.process(output);
    TensorLabel tensorLabels = TensorLabel.fromList(labelList, processedOutput);
    List<Category> processedLabels = tensorLabels.getCategoryList();

    // Find predictions within threshold
    double probability;
    Category cat;
    List<Prediction> predictions = [];
    for (int i = 0; i < processedLabels.length; i++) {
      cat = processedLabels.elementAt(i);

      // Score not quantized so split by 255.0
      probability = cat.score / 255.0;
      if (probability > 0.5) {
        predictions.add(Prediction(i, cat.label, probability, null));
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

    TensorBufferFloat output =
        TensorBufferFloat(interpreter!.getOutputTensor(0).shape);
    // TensorBuffer output = TensorBuffer.createFixedSize(
    //     interpreter!.getOutputTensor(0).shape,
    //     interpreter!.getOutputTensor(0).type);

    if (logEnabled) {
      logInfo(inputImage);
    }

    ByteBuffer inputBuffer = inputImage.buffer;

    Tensor inputTensor = interpreter!.getInputTensor(0);
    List<int> size = [inputBuffer.lengthInBytes, inputTensor.numBytes()];
    if (size[0] == size[1]) {
      interpreter!.run(inputBuffer, output);
    } else {
      return {
        "status": PredictionStatus.error,
        "message":
            "Image Input and Tensor Input byte size does not match: $size\nInterpreter cannot run if the byte sizes do not match",
        "stop": true
      };
    }

    List<Prediction> predictions =
        processOutput3(output, inputImage.height, image);

    // List<Prediction> predictions = processOutput2(outputLocations,
    //     outputClasses, outputScores, numLocations, inputImage.height, image);

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
