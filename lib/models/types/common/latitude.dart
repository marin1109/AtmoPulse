import '../../../utils/value_object.dart';

class Latitude extends ValueObject<double> {
  static const double minLatitude = -90.0;
  static const double maxLatitude = 90.0;

  const Latitude(super.value);

  @override
  bool isValid() => value >= minLatitude && value <= maxLatitude;
}
