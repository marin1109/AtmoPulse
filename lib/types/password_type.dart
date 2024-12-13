class Password {
  final String value;

  Password(this.value);

  // Méthode statique pour valider un mot de passe
  static bool isValidPassword(Password password) {
    final passwordRegex = RegExp(
      r'^(?=.*[A-Z])(?=.*[a-z])(?=.*\d)(?=.*[!@#\$&*~]).{8,}$');
    return passwordRegex.hasMatch(password.toString());
  }

  // Renvoie le mot de passe
  @override
  String toString() => value;
  
}
