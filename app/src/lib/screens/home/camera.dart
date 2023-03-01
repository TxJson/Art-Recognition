import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:art_app_fyp/shared/validators.dart';

// import 'package:tflite/tflite.dart';

import 'dart:math' as math;

typedef Callback = void Function(List<dynamic> list, int h, int w);

// Adapted from Flutter Camera Package Documentation
// https://pub.dev/packages/camera
class CameraView extends StatefulWidget {
  final List<CameraDescription> cameras;
  final int activeCameraIndex;
  // final Callback setRecognitions;

  // Default Constructor
  // const CameraView(this.cameras, this.activeCameraIndex, this.setRecognitions);
  const CameraView(
      {Key? key, required this.cameras, required this.activeCameraIndex})
      : super(key: key);

  @override
  State<CameraView> createState() => CameraViewState();
}

class CameraViewState extends State<CameraView> {
  late CameraController controller;
  bool isDetecting = false;

  @override
  void initState() {
    super.initState();
    controller = CameraController(
        widget.cameras[widget.activeCameraIndex], ResolutionPreset.max);
    controller.initialize().then((_) {
      if (!mounted) {
        return;
      }

      setState(() {});

      controller.startImageStream((CameraImage img) async {
        // if (!isDetecting) {
        //   isDetecting = true;
        //   await Tflite.detectObjectOnFrame(
        //     bytesList: img.planes.map((plane) {
        //       return plane.bytes;
        //     }).toList(),
        //     model: "SSDMobileNet",
        //     imageHeight: img.height,
        //     imageWidth: img.width,
        //     imageMean: 127.5,
        //     imageStd: 127.5,
        //     numResultsPerClass: 3,
        //     threshold: 0.4,
        //   ).then((recognitions) {
        //     /*
        //       When setRecognitions is called here, the parameters are being passed on to the parent widget as callback. i.e. to the LiveFeed class
        //        */
        //     widget.setRecognitions(
        //         recognitions as List<dynamic>, img.height, img.width);
        //     isDetecting = false;
        //   });
        // }
      });
    }).catchError((Object e) {
      if (e is CameraException) {
        switch (e.code) {
          case 'CameraAccessDenied':
            // Handle access errors here.
            break;
          default:
            // Handle other errors here.
            break;
        }
      }
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!controller.value.isInitialized) {
      return Container();
    }

    // var tmp = MediaQuery.of(context).size;
    // var screenH = math.max(tmp.height, tmp.width);
    // var screenW = math.min(tmp.height, tmp.width);

    // tmp = controller.value.previewSize as Size;
    // var previewH = math.max(tmp.height, tmp.width);
    // var previewW = math.min(tmp.height, tmp.width);
    // var screenRatio = screenH / screenW;
    // var previewRatio = previewH / previewW;

    // return OverflowBox(
    //   maxHeight:
    //       screenRatio > previewRatio ? screenH : screenW / previewW * previewH,
    //   maxWidth:
    //       screenRatio > previewRatio ? screenH / previewH * previewW : screenW,
    //   child: CameraPreview(controller),
    // );

    return MaterialApp(
        home: GestureDetector(

            /// Zoom functionality Adapted from:
            /// https://stackoverflow.com/questions/60424964/zoom-camera-in-flutter#:~:text=You%20can%20use%20cameraController.,limits%20for%20the%20zoom%20level.
            /// TODO: Known bug - When zooming in it always starts from 0
            onScaleUpdate: (details) async {
              double max = await controller.getMaxZoomLevel();
              double min = await controller.getMinZoomLevel();

              double dragIntensity = details.scale;
              if (dragIntensity < min) {
                controller.setZoomLevel(min);
              } else if (dragIntensity.between(min, max)) {
                controller.setZoomLevel(dragIntensity);
              } else if (dragIntensity > max) {
                controller.setZoomLevel(max);
              }
            },
            child: CameraPreview(controller)));
  }
}
