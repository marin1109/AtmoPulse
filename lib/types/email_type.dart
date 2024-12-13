class Email {
  final String _value;

  Email(this._value);

  // Méthode statique pour valider un email
  static bool isValidEmail(Email email) {
    final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    return emailRegex.hasMatch(email.toString());
  }

  // Renvoie l'email
  @override
  String toString() => _value;
  
}
