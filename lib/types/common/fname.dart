import '../../utils/value_object.dart';
import '../../utils/regex_validation.dart';

class FName extends ValueObject<String> with RegexValidation {
  static final RegExp _fnameRegex = RegExp(r'^[a-zA-Z]{2,}$');

  FName(super.value) {
    regex = _fnameRegex;
  }
}
