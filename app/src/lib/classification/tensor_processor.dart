import 'dart:math';

import 'package:art_app_fyp/classification/prediction.dart';
import 'package:logger/logger.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:tflite_flutter_helper/tflite_flutter_helper.dart';
import 'package:image/image.dart';

// Define the anchor box parameters and number of classes
final anchorBoxes = [
  [0.738768, 0.874946],
  [2.42204, 2.65704],
  [4.30971, 7.04493],
  [10.246, 4.59428],
  [12.6868, 11.8741]
];

class CustomTensorProcessor {
  final int _classes;
  final List<String> _labels;
  final int _interpreterAddress;
  final double _threshold;

  bool _preprocessorInitialized = false;
  late ImageProcessor _imageProcessor;
  late Interpreter _interpreter;

  CustomTensorProcessor(
      this._classes, this._labels, this._interpreterAddress, this._threshold) {
    _interpreter = Interpreter.fromAddress(_interpreterAddress);
  }

  int get classes => _classes;
  List<String> get labels => _labels;
  bool get preprocessInitialized => _preprocessorInitialized;

  TensorImage preprocess(Image img) {
    TensorImage inputTensor = TensorImage.fromImage(img);

    final minLength = min(inputTensor.height, inputTensor.width);
    final shapeLength = _interpreter.getInputTensor(0).shape[1];

    // final quantOps = _interpreter.getInputTensor(0).params;

    if (!_preprocessorInitialized) {
      _imageProcessor = ImageProcessorBuilder()
          .add(ResizeWithCropOrPadOp(minLength, minLength))
          .add(ResizeOp(
              shapeLength, shapeLength, ResizeMethod.NEAREST_NEIGHBOUR))
          .add(NormalizeOp(0, 255.0))
          .add(CastOp(TfLiteType.float32))
          .build();

      _preprocessorInitialized = true;
    }

    inputTensor = _imageProcessor.process(inputTensor);

    return inputTensor;
  }

  List<Prediction> postprocess(TensorBuffer output) {
    // Get the output shape and number of detections
    final outputShape = output.shape;
    final numDetections = outputShape[1];

    // Get the output data as a Float32List
    final outputData = output.buffer.asFloat32List();

    List<Prediction> predictions = [];
    // Loop over the detections
    for (var i = 0; i < numDetections; i++) {
      final detectionOffset = i * (_classes + 5);

      // Get the confidence score for this detection
      final confidence = outputData[detectionOffset + 4];

      // Get the class ID for this detection
      var classId = -1;
      var maxClassConfidence = 0.0;
      for (var j = 0; j < _classes; j++) {
        final classConfidence = outputData[detectionOffset + 5 + j];
        if (classConfidence > maxClassConfidence) {
          classId = j;
          maxClassConfidence = classConfidence;
        }
      }

      // Get the bounding box coordinates for this detection
      final x = outputData[detectionOffset];
      final y = outputData[detectionOffset + 1];
      final width = outputData[detectionOffset + 2];
      final height = outputData[detectionOffset + 3];

      // Apply the anchor box parameters to the bounding box coordinates
      final anchorBox = anchorBoxes[i % anchorBoxes.length];
      final centerX = anchorBox[0] * width + x;
      final centerY = anchorBox[1] * height + y;
      final w = exp(width) * anchorBox[0];
      final h = exp(height) * anchorBox[1];

      // Add the detection to the list of results
      // Map<String, dynamic> detection = {
      //   "classId": classId,
      //   "confidence": confidence,
      //   "x": centerX - w / 2,
      //   "y": centerY - h / 2,
      //   "width": w,
      //   "height": h,
      // };

      if (classId > -1) {
        Prediction detection =
            Prediction(classId, labels[classId], confidence, null);
        predictions.add(detection);
      }
    }

    return predictions;

// // Sort the results by confidence score
//     results.sort((a, b) => b.confidence.compareTo(a.confidence));

// // Filter out low-confidence detections
//     results = results.where((d) => d.confidence >= minConfidence).toList();
  }
}
