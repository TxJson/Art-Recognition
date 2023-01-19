import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:art_app_fyp/shared/validators.dart';

// Adapted from Flutter Camera Package Documentation
// https://pub.dev/packages/camera
class CameraView extends StatefulWidget {
  final List<CameraDescription> cameras;
  final int activeCameraIndex;

  // Default Constructor
  const CameraView(
      {Key? key, required this.cameras, required this.activeCameraIndex})
      : super(key: key);

  @override
  State<CameraView> createState() => CameraViewState();
}

class CameraViewState extends State<CameraView> {
  late CameraController controller;

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
