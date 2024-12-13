class Localtime {
  final String localtime;

  Localtime(this.localtime);

  // Vérifie si l'heure locale est valide
  static bool isValidLocaltime(String localtime) {
    final RegExp regExp = RegExp(r"^\d{4}-\d{2}-\d{2}[T ]\d{2}:\d{2}$");
    return regExp.hasMatch(localtime);
  }

  // Renvoie l'heure locale
  String getLocaltime() => localtime;
  
}
