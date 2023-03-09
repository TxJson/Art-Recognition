import 'dart:math';
import 'dart:typed_data';
import 'dart:ui';
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
  final double threshold;

  Interpreter? interpreter;

  Classifier(
      {required this.labels,
      this.model = '',
      this.threshold = 0.5,
      this.threads = 4,
      this.interpreter}) {
    // Model is optional in case
    if (interpreter == null && labels is String && model.isNotEmpty) {
      loadDefaults(model, labels);
    } else if (labels is List) {
      labelList = labels;
    }
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

    interpreter = await Interpreter.fromAsset(model).catchError((Object e) {
      logger.e('An error occured while loading the model:', e);
    });
  }

  // Future<imglib.Image?> preprocessImage(image) async {
  //   Uint32List imgBytes = await image.readAsBytes();
  //   // return ui.decodeImage(imgBytes)!;
  //   return imglib.decodeImage(imgBytes);
  // }

  List<double> getOutputRatio(imglib.Image img, int inputSize) {
    return [
      img.width.toDouble() / inputSize,
      img.height.toDouble() / inputSize
    ];
  }

  // Adapted from https://pub.dev/documentation/mlkit/latest/
  // Uint8List imageToByteList(imglib.Image image, int inputSize) {
  //   var convertedBytes = Uint8List(1 * inputSize * inputSize * 3);
  //   var buffer = ByteData.view(convertedBytes.buffer);
  //   int pixelIndex = 0;
  //   for (var i = 0; i < inputSize; i++) {
  //     for (var j = 0; j < inputSize; j++) {
  //       var pixel = image.getPixel(i, j);
  //       buffer.setUint8(pixelIndex, (pixel >> 16) & 0xFF);
  //       pixelIndex++;
  //       buffer.setUint8(pixelIndex, (pixel >> 8) & 0xFF);
  //       pixelIndex++;
  //       buffer.setUint8(pixelIndex, (pixel) & 0xFF);
  //       pixelIndex++;
  //     }
  //   }
  //   return convertedBytes;
  // }

  TensorImage preprocessInput(imglib.Image image) {
    // TensorImage tImage = TensorImage.fromImage(image);
    // // int targetPad = max(tImage.height, tImage.width);
    // int targetPad = max(image.height, image.width);
    // imageProcessor = ImageProcessorBuilder()
    //     .add(ResizeWithCropOrPadOp(targetPad, targetPad))
    //     .add(ResizeOp(1, 640, ResizeMethod.BILINEAR))
    //     .build();
    // return imageProcessor.process(tImage);

    final inputTensor = TensorImage.fromImage(image);

    final minLength = min(inputTensor.height, inputTensor.width);

    final shapeLength = interpreter!.getInputTensor(0).shape[1];

    final imageProcessor = ImageProcessorBuilder()
        .add(ResizeWithCropOrPadOp(minLength, minLength))
        .add(ResizeOp(shapeLength, shapeLength, ResizeMethod.BILINEAR))
        .build();

    imageProcessor.process(inputTensor);
    return inputTensor;
  }

  // https://pub.dev/packages/tflite_flutter_helper
  dynamic predictItem(imglib.Image image) {
    if (interpreter == null || interpreter!.isDeleted) {
      logger.e('Interpreter is null or deleted');
      return null;
    }

    TensorImage inputImage = preprocessInput(image);
    TensorBuffer output = TensorBuffer.createFixedSize(
        interpreter!.getOutputTensor(0).shape,
        interpreter!.getOutputTensor(0).type);

    // logger.i('Label Count: ${labelList.length}');

    // logger.i(
    //   'Output shape: ${interpreter!.getOutputTensor(0).shape}, '
    //   'type: ${interpreter!.getOutputTensor(0).type}',
    // );

    // logger.i('Input shape ${interpreter!.getInputTensor(0).shape}, '
    //     'type: ${interpreter!.getInputTensor(0).type}, '
    //     'length: ${interpreter!.getInputTensor(0).shape.length}');

    // logger.i('Pre-processed image: ${inputImage.width}x${inputImage.height}, '
    //     'size: ${inputImage.buffer.lengthInBytes} bytes, '
    //     'type: ${inputImage.dataType}');

    interpreter!.run(inputImage.tensorBuffer.buffer, output.buffer);

    return output.getDoubleList();
  }

  void close() {
    interpreter!.close();
  }

  int get interAddress => interpreter!.address;
  bool get interDefined => interpreter != null;
  bool get interAllocated => interpreter!.isAllocated;

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

  List<String> get listOfLabels => labelList;
}
