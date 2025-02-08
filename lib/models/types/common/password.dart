import '../../../utils/value_object.dart';
import '../../../utils/regex_validation.dart';

class Password extends ValueObject<String> with RegexValidation {
  static final RegExp _passwordRegex = RegExp(
    r'^(?=.*[A-Z])(?=.*[a-z])(?=.*\d)(?=.*[!@#\$&*~]).{8,}$',
  );

  Password(super.value) {
    regex = _passwordRegex;
  }
}