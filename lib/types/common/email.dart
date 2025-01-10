import '../../utils/value_object.dart';

class Email extends ValueObject<String>{
  static final RegExp _emailRegex = RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
  );

  const Email(super.value);

  @override
  bool isValid() {
    final result = _emailRegex.hasMatch(value);
    if (!result) {
      print("Validation échouée pour l'email: $value");
    }
    return result;
  }
}
