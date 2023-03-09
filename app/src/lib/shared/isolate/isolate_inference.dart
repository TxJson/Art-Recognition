import 'dart:isolate';
import 'package:art_app_fyp/shared/utilities.dart';
import 'package:art_app_fyp/shared/isolate/isolate_model.dart';
import 'package:art_app_fyp/detection/classifier.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as imglib;

class IsolateInference {
  ReceivePort receivePort = ReceivePort();

  late Isolate isolate;
  late SendPort sendPort;

  bool _sendPortInitialized = false;

  Future<void> start() async {
    isolate = await Isolate.spawn<SendPort>(process, receivePort.sendPort,
        debugName: 'IsolateInference');

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
          interpreter: Interpreter.fromAddress(model.interpreterAddress));

      // Convert image from yuv420 format
      imglib.Image image = Utilities.convertYUV420ToImage(model.cameraImage);
      classifier.allocateInter(); // Allicate tensors if not already
      dynamic results = classifier.predictItem(image);
      model.responsePort.send(results);
    });

    // for (final isolateModel in port) {
    //   if (isolateModel == null) {
    //     return;
    //   }

    //   Classifier classifier = Classifier(
    //       labels: isolateModel.labels,
    //       interpreter:
    //           Interpreter.fromAddress(isolateModel.interpreterAddress));

    //   Map<String, dynamic> results = classifier.predictItem(
    //       Utilities.convertYUV420ToImage(isolateModel.cameraImage));
    //   isolateModel.responsePort.send(results);
    // }
  }

  SendPort get getSendPort => sendPort;
  bool get sendPortInitialized => _sendPortInitialized;
}
