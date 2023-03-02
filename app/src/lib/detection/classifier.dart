import 'dart:math';
import 'dart:typed_data';

import 'package:art_app_fyp/detection/prediction.dart';
import 'package:art_app_fyp/shared/utilities.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:image/image.dart' as imglib;
import 'package:tflite_flutter_helper/tflite_flutter_helper.dart';

class Classifier {
  var logger = Logger();

  final String model; // Pass asset path, ex assets/model.tflite
  final String labels; // Pass asset path, ex assets/labels.txt

  final double imageWidth;
  final double imageHeight;

  final int threads;
  final double threshold;

  Interpreter? interpreter;

  Classifier(
      {required this.labels,
      required this.model,
      this.imageWidth = 1280,
      this.imageHeight = 720,
      this.threshold = 0.5,
      this.threads = 4,
      this.interpreter}) {
    loadDefaults(model, labels);
  }

  // Will be initialized & loaded with loadLabels/loadModel
  List<String> labelList = [];

  // Output tensors
  List<Tensor> outputTensors = [];

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
      labelList = (await rootBundle.loadString(labels)).split('\n');

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

    await Interpreter.fromAsset(model).then((Interpreter interpr) {
      interpreter = interpr;
      outputTensors = interpr.getOutputTensors();
    }).catchError((Object e) {
      logger.e('An error occured while loading the model:', e);
    });
  }

  // https://pub.dev/packages/tflite_flutter_helper
  List<Prediction>? predictItem(imglib.Image img) {
    if (interpreter == null || outputTensors.isEmpty) {
      return null;
    }

    TensorImage inputImg = TensorImage.fromImage(img);

    int cropSize = max(img.height, img.width);
    imageProcessor = ImageProcessorBuilder()
        .add(ResizeWithCropOrPadOp(cropSize, cropSize))
        .add(ResizeOp(
            imageHeight.toInt(), imageWidth.toInt(), ResizeMethod.BILINEAR))
        .build();
    inputImg = imageProcessor.process(inputImg);

    // TensorBuffers for output tensors
    // TensorBuffer outputLocations = TensorBufferFloat(outputTensors[0].shape);
    TensorBuffer outputClasses = TensorBufferFloat(outputTensors[0].shape);
    // TensorBuffer outputProbability = TensorBufferFloat(outputTensors[2].shape);
    // TensorBuffer numLocations = TensorBufferFloat(outputTensors[3].shape);

    // Inputs object for runForMultipleInputs
    // Use [TensorImage.buffer] or [TensorBuffer.buffer] to pass by reference
    List<Object> inputs = [inputImg.buffer];

    // Outputs map
    Map<int, Object> outputs = {
      // 0: outputLocations.buffer,
      0: outputClasses.buffer,
      // 2: outputProbability.buffer,
      // 3: numLocations.buffer,
    };

    // Using bounding box utils for easy conversion of tensorbuffer to List<Rect>
    // List<Rect> locations = BoundingBoxUtils.convert(
    //   tensor: outputLocations,
    //   valueIndex: [0, 1, 2, 3], // left, top, right, bottom
    //   boundingBoxAxis: 2,
    //   boundingBoxType: BoundingBoxType.BOUNDARIES,
    //   coordinateType: CoordinateType.RATIO,
    //   height: imageHeight.toInt(),
    //   width: imageWidth.toInt(),
    // );

    interpreter!.runForMultipleInputs(inputs, outputs);

    List<Prediction> predictions = [];

    for (int i = 0; i < 10; i++) {
      // double probability = outputProbability.getDoubleValue(i);

      // +1 offset as index starts at 0
      int labelIndex = outputClasses.getIntValue(i) + 1;
      String label = labelList.elementAt(labelIndex);

      // if (probability > threshold) {
      //   // Rect rectangle = imageProcessor.inverseTransformRect(
      //   //     locations[i], img.height, img.width);
      //   predictions.add(
      //     Prediction(i, label, probability),
      //   );
      // }
    }

    return predictions;
  }
}
