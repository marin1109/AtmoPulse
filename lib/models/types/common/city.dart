import '../../../utils/value_object.dart';
import '../../../utils/regex_validation.dart';

class City extends ValueObject<String> with RegexValidation {
  static final RegExp _cityRegex = RegExp(
    r"^[a-zA-ZÀ-ÖØ-öø-ÿ' -]+(?: [a-zA-ZÀ-ÖØ-öø-ÿ' -]+)*$",
  );

  City(super.value) {
    regex = _cityRegex;
  }
}
