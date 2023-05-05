import 'package:art_app_fyp/shared/helpers/math/vector2.dart';
import 'package:flutter/material.dart';

// @redundant - unused
// Keep for now - might be useful for future implementation
class CameraInfo {
  Size inputSize;
  Size screenSize;

  // late double _ratio;
  late Vector2 _ratio;
  late Size _actualPreviewSize;

  CameraInfo([this.inputSize = Size.zero, this.screenSize = Size.zero]) {
    _ratio = Vector2.zero(); // Set ratio as undefined
    setDefaults();
  }

  void setDefaults() {
    double x = screenSize.width / inputSize.width;
    double y = screenSize.height / inputSize.height;
    _ratio.set(x, y);
    _actualPreviewSize = Size(screenSize.width * x, screenSize.height * y);
  }

  Size get getInputSize => inputSize;
  Size get getScreenSize => screenSize;
  Size get getActualPreviewSize => _actualPreviewSize;
  Vector2 get getRatio => _ratio;

  void setInputSize(Size size) {
    inputSize = size;

    // Recalculate ratio if input size changes
    setDefaults();
  }

  void setScreenSize(Size size) {
    screenSize = size;

    // Recalculate ratio if input size changes
    setDefaults();
  }
}
