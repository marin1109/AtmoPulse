class Country {
  final String _name;

  Country(this._name);

  // Getter pour le nom du pays
  String get name => _name;

  // Méthode statique pour valider un pays
  static bool isValidCountry(String name) {
    final countryRegex = RegExp(r"^[a-zA-ZÀ-ÖØ-öø-ÿ' -]{2,}(?: [a-zA-ZÀ-ÖØ-öø-ÿ' -]+)*$");
    return countryRegex.hasMatch(name);
  }

  // Renvoie le pays
  @override
  String toString() => _name;
  
}
