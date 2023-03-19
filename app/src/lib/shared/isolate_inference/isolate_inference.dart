import 'dart:io';
import 'dart:isolate';
import 'package:art_app_fyp/classification/prediction.dart';
import 'package:art_app_fyp/shared/helpers/utilities.dart';
import 'package:art_app_fyp/shared/isolate_inference/isolate_model.dart';
import 'package:art_app_fyp/classification/classifier.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as imglib;

class IsolateInference {
  ReceivePort receivePort = ReceivePort();

  late Isolate isolate;
  late SendPort sendPort;

  bool _sendPortInitialized = false;

  Future<void> start() async {
    isolate = await Isolate.spawn<SendPort>(process, receivePort.sendPort,
        debugName: 'Inference');

    sendPort = await receivePort.first;
    _sendPortInitialized = true;
  }

  static void process(SendPort sendPort) async {
    final port = ReceivePort();
    sendPort.send(port.sendPort);

    port.forEach((model) {
      if (model == null || model is! IsolateModel) {
        return;
      }

      Classifier classifier = Classifier(
          labels: model.labels,
          interpreter: Interpreter.fromAddress(model.interpreterAddress),
          cameraInfo: model.cameraInfo);

      // Convert image from yuv420 format
      imglib.Image image = Utilities.convertYUV420ToImage(model.cameraImage);
      classifier.allocateInter(); // Allicate tensors if not already
      if (Platform.isAndroid) {
        image = imglib.copyRotate(image, 90);
      }
      Map<String, dynamic> response =
          classifier.predictItem(image, logEnabled: model.logEnabled);

      model.responsePort.send(response);
    });
  }

  SendPort get getSendPort => sendPort;
  bool get sendPortInitialized => _sendPortInitialized;
}
