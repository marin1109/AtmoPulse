import 'value_object.dart';

mixin RegexValidation on ValueObject<String> {
  late final RegExp regex;

  @override
  bool isValid() => regex.hasMatch(value);
}
