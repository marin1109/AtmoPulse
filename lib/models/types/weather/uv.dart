import '../../../utils/value_object.dart';

enum UVUnit { uv }

class UV extends ValueObject<int> {
  static const int minUV = 0;
  static const int maxUV = 43;

  UVUnit get unit => UVUnit.uv;

  const UV(super.value);

  @override
  bool isValid() {
    return value >= minUV && value <= maxUV;
  }

  static String unitToString(UVUnit unit) {
    switch (unit) {
      case UVUnit.uv:
        return "UV";
    }
  }

  static bool isValidUV(double value) {
    return value >= minUV && value <= maxUV;
  }

  static String loadUVText(UV uv) {
    switch (uv.unit) {
      case UVUnit.uv:
        return uv.value.toString();
    }
  }
}
