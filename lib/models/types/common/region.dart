import '../../../utils/value_object.dart';
import '../../../utils/regex_validation.dart';

class Region extends ValueObject<String> with RegexValidation {
  static final RegExp _regionRegex = RegExp(
    r"^[a-zA-ZÀ-ÖØ-öø-ÿ' -]+(?: [a-zA-ZÀ-ÖØ-öø-ÿ' -]+)*$",
  );

  Region(super.value) {
    regex = _regionRegex;
  }
}
