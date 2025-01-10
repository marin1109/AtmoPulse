import '../../utils/value_object.dart';

class Password extends ValueObject<String> {
  static final RegExp _passwordRegex = RegExp(
    r'^(?=.*[A-Z])(?=.*[a-z])(?=.*\d)(?=.*[!@#\$&*~]).{8,}$',
  );

  const Password(String value) : super(value);

  @override
  bool isValid() {
    final result = _passwordRegex.hasMatch(value);
    if (!result) {
      print("Validation échouée pour le mot de passe: $value");
    }
    return result;
  }
}