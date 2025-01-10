import '../../utils/value_object.dart';
import '../../utils/regex_validation.dart';

class Localtime extends ValueObject<String> with RegexValidation {
  static final RegExp _localtimeRegex = RegExp(r"^\d{4}-\d{2}-\d{2}[T ]\d{2}:\d{2}$");

  Localtime(super.value) {
    regex = _localtimeRegex;
  }
}

