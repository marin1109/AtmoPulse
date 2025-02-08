import '../../../utils/value_object.dart';
import '../../../utils/regex_validation.dart';

class LName extends ValueObject<String> with RegexValidation {
  static final RegExp _lnameRegex = RegExp(r'^[a-zA-Z]{2,}$');

  LName(super.value) {
    regex = _lnameRegex;
  }
}
