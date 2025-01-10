import '../../utils/value_object.dart';
import '../../utils/regex_validation.dart';

class Email extends ValueObject<String> with RegexValidation {
  static final RegExp _emailRegex = RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
  );

  Email(super.value) {
    regex = _emailRegex;
  }
}
