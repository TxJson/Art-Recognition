import 'package:flutter/material.dart';

// Adapted from:
// https://flutterigniter.com/using-hexadecimal-color-strings/
Color getHexColor(String hex, {double opacity = 1}) {
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
