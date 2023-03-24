import 'dart:typed_data';

import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:tflite_flutter_helper/tflite_flutter_helper.dart';

extension DoubleParsing on double {
  bool between(double low, double high) {
    return this > low && this < high;
  }
}

extension IntegerParsing on int {
  bool between(int low, int high) {
    return this > low && this < high;
  }
}

extension NumberParsing on String {
  int parseInt() {
    return int.parse(this);
  }

  double parseDouble() {
    return double.parse(this);
  }
}

extension StringListParsing on List<String> {
  List<String> trim() {
    return map((str) => str.trim()).toList();
  }
}

extension StringIterableParsing on Iterable<String> {
  Iterable<String> trim() {
    return map((str) => str.trim());
  }
}

extension TensorParsing on Tensor {
  bool bufferMatch(dynamic buffer) {
    if (buffer is ByteBuffer) {
      return numBytes() == buffer.lengthInBytes;
    } else if (buffer is TensorBuffer ||
        buffer is TensorBufferFloat ||
        buffer is TensorBufferUint8) {
      return numBytes() == buffer.getBuffer().lengthInBytes;
    }

    return false;
  }

  List<int> getBuffers(dynamic buffer) {
    if (buffer is ByteBuffer) {
      return [buffer.lengthInBytes, numBytes()];
    } else if (buffer is TensorBuffer) {
      return [buffer.getBuffer().lengthInBytes, numBytes()];
    }

    return [];
  }
}

class Validators {
  static dynamic defaultIfNull(dynamic item, dynamic defaultItem) {
    return item ?? defaultItem;
  }
}
