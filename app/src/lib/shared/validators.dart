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
