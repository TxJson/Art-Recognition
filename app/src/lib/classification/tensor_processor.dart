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

  // The number of elements in a YOLOv5 model
  // Stands for (x, y, width, height, and probability score)
  final yolov5Bounding = 5;

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
    final shapeLength = min(_interpreter.getInputTensor(0).shape[1],
        _interpreter.getInputTensor(0).shape[2]);

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

  List<Prediction> postprocess(Tensor output) {
    // Get the output shape and number of detections
    final outputShape = output.shape;
    final numDetections = outputShape[1];

    // Get the output data as a Float32List
    final outputData = output.data.buffer.asFloat32List();

    List<Prediction> unfilteredPredictions = [];
    // Loop over the detections
    for (var i = 0; i < numDetections; i++) {
      final detectionOffset = i * (_classes + yolov5Bounding);

      // Get the probability score for this detection
      // + 4 because probability score comes after the bounding box variables
      // (x, y, width, height, and probability score)
      final probability = outputData[detectionOffset + (yolov5Bounding - 1)];

      // Get the class ID for this detection
      int classId = -1;
      double maxClassProbability = 0.0;
      for (int classIndex = 0; classIndex < _classes; classIndex++) {
        final classProbability =
            outputData[detectionOffset + yolov5Bounding + classIndex];
        if (classProbability > maxClassProbability) {
          classId = classIndex;
          maxClassProbability = classProbability;
        }
      }

      if (classId > -1 && classId <= classes) {
        if (probability > _threshold) {
          unfilteredPredictions
              .add(Prediction(classId, labels[classId], probability, null));
        }
      }
    }

    // There is probably a more efficient way to do this
    // Filters out duplicates of detections and returns only the one with the
    // highest probability
    List<Prediction> filteredPredictions = [];
    for (int i = 0; i < labels.length; i++) {
      final matchingPredictions =
          unfilteredPredictions.where((pred) => pred.id == i);
      if (matchingPredictions.isNotEmpty) {
        final pred = matchingPredictions.reduce(
            (curr, next) => curr.probability > next.probability ? curr : next);
        filteredPredictions.add(pred);
      }
    }

    return filteredPredictions;
  }
}
