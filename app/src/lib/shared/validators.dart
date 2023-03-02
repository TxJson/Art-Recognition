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

class Validators {
  static dynamic defaultIfNull(dynamic item, dynamic defaultItem) {
    return item ?? defaultItem;
  }
}
