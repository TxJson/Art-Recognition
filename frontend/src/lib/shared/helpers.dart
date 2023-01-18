import 'package:flutter/material.dart';

// Adapted from:
// https://flutterigniter.com/using-hexadecimal-color-strings/
Color getHexColor(String hex) {
  hex = hex.replaceAll('#', '');

  if (hex.length == 6) {
    hex = 'FF$hex';
  }

  return Color(int.parse("0x$hex"));
}
