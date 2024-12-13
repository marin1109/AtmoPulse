class LName {
  final String lname;

  LName(this.lname);

  // Méthode statique pour valider un nom
  static bool isValidLName(String lname) {
    final lnameRegex = RegExp(r'^[a-zA-Z]{2,}$');
    return lnameRegex.hasMatch(lname);
  }

  // Renvoie le nom
  @override
  String toString() => lname;
}
