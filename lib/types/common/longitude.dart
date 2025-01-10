import '../../utils/value_object.dart';

class Longitude extends ValueObject<double> {
  static const double minLongitude = -180.0;
  static const double maxLongitude = 180.0;

  const Longitude(super.value);

  @override
  bool isValid() => value >= minLongitude && value <= maxLongitude;
}
