import 'dart:math';

import 'package:art_app_fyp/classification/prediction.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:tflite_flutter_helper/tflite_flutter_helper.dart';
import 'package:image/image.dart';

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

      if (classId > -1 && classId <= classes) {
        Prediction detection =
            Prediction(classId, labels[classId], confidence, null);
        predictions.add(detection);
      }
    }

    return predictions;
  }
}
