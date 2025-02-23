import '../../../utils/value_object.dart';
import '../../../utils/regex_validation.dart';

class Country extends ValueObject<String> with RegexValidation {
  static final RegExp _countryRegex = RegExp(
    r"^[a-zA-ZÀ-ÖØ-öø-ÿ' -]{2,}(?: [a-zA-ZÀ-ÖØ-öø-ÿ' -]+)*$",
  );

  Country(super.value) {
    regex = _countryRegex;
  }
}
