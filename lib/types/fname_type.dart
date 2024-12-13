class FName {
  final String _fname;

  FName(this._fname);

  // Méthode statique pour valider un prénom
  static bool isValidFName(String fname) {
    final fnameRegex = RegExp(r'^[a-zA-Z]{2,}$');
    return fnameRegex.hasMatch(fname);
  }

  // Renvoie le prénom
  @override
  String toString() => _fname;

}
