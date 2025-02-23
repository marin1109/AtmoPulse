import '../../../utils/value_object.dart';

class Timezone extends ValueObject<String> {
  static final RegExp _timezoneRegex = RegExp(
    r"^(?:[A-Za-z_]+(?:\/[A-Za-z_]+)*(?:\/[A-Za-z_]+)*|UTC|GMT(?:[+-]\d{1,2})?)$",
  );

  const Timezone(super.value);

  @override
  bool isValid() => _timezoneRegex.hasMatch(value);
}
