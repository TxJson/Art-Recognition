import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as imglib;

class Utilities {
  // Adapted from:
  // https://flutterigniter.com/using-hexadecimal-color-strings/
  static Color getHexColor(String hex, {double opacity = 1}) {
    hex = hex.replaceAll('#', '');

    if (hex.length == 6) {
      hex = 'FF$hex';
    }

    Color col = Color(int.parse('0x$hex'));

    // Allows opacity to be specified if necessary as well
    if (opacity < 1) {
      return col.withOpacity(opacity);
    }

    return col;
  }

  static String removeIfExists(String str, String match) {
    if (str.contains(match)) {
      return str.replaceAll(match, '');
    }

    return str;
  }

  // Standard image convertion, borrowed from: https://gist.github.com/Alby-o/fe87e35bc21d534c8220aed7df028e03
  // CameraImage YUV420_888 -> PNG -> Image (compresion:0, filter: none)
  // Black
  static imglib.Image convertToYUV420(CameraImage image) {
    var img = imglib.Image(image.width, image.height); // Create Image buffer

    Plane plane = image.planes[0];
    const int shift = (0xFF << 24);

    // Fill image buffer with plane[0] from YUV420_888
    for (int x = 0; x < image.width; x++) {
      for (int planeOffset = 0;
          planeOffset < image.height * image.width;
          planeOffset += image.width) {
        final pixelColor = plane.bytes[planeOffset + x];
        // color: 0x FF  FF  FF  FF
        //           A   B   G   R
        // Calculate pixel color
        var newVal =
            shift | (pixelColor << 16) | (pixelColor << 8) | pixelColor;

        img.data[planeOffset + x] = newVal;
      }
    }

    return img;
  }
}
