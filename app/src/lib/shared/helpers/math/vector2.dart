import 'dart:math';
import 'package:flutter/material.dart';

class Vector2 {
  double? _x;
  double? _y;

  Vector2([this._x, this._y]);

  static zero() => Vector2(0, 0);
  static one() => Vector2(1, 1);
  static all(double value) => Vector2(value, value);
  static setFromVector2(Vector2 vec) => Vector2(vec.x, vec.y);
  static setFromRect(Rect rect) => Vector2(rect.width, rect.height);
  static distanceBetween(Vector2 vec1, Vector2 vec2) {
    double x = vec1.x - vec2.x;
    double y = vec1.y - vec2.y;

    return sqrt((x * x) + (y * y));
  }

  void setX(double x) => _x = x;
  void setY(double y) => _y = y;

  void set(double x, double y) {
    _x = x;
    _y = y;
  }

  double distanceFrom(Vector2 vec) {
    if (_x == null || _y == null) {
      return 0;
    }

    double x = _x! - vec.x;
    double y = _y! - vec.y;

    return sqrt((x * x) + (y * y));
  }

  void normalize() {
    if (_x == null || _y == null) {
      return;
    }

    final length = sqrt((_x! * _x!) + (_y! * _y!));
    if (length != 0) {
      _x = _x! * (1.0 / length);
      _y = _y! * (1.0 / length);
    }
  }

  double get x => _x!;
  double get y => _y!;
}
