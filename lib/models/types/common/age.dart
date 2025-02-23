import '../../../utils/value_object.dart';

class Age extends ValueObject<int> {
  static const int minAge = 0;
  static const int maxAge = 120;

  const Age(super.value);

  @override
  bool isValid() => value >= minAge && value <= maxAge;
}
