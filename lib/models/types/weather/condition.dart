import '../../../utils/value_object.dart';

class Condition extends ValueObject<Map<String, dynamic>> {
  final String text;
  final String icon;
  final int code;

  Condition({
    required this.text,
    required this.icon,
    required this.code,
  }) : super({
          'text': text,
          'icon': icon,
          'code': code,
        });

  factory Condition.fromJson(Map<String, dynamic> json) {
    return Condition(
      text: json['text'],
      icon: json['icon'],
      code: json['code'],
    );
  }

  @override
  bool isValid() {
    return text.isNotEmpty && icon.isNotEmpty && code >= 0;
  }

  Map<String, dynamic> toJson() {
    return {
      'text': text,
      'icon': icon,
      'code': code,
    };
  }
}
