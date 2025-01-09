enum UVUnit { UV }

class UV {
  final int value;

  UV(this.value);

  @override
  String toString() => '$value';

  // Conversion de l'unité en string
  static String unitToString(UVUnit unit) {
    switch (unit) {
      case UVUnit.UV:
        return "UV";
    }
  }

  static bool isValidUV(int value) {
    return value >= 0 && value <= 43;
  }

}
