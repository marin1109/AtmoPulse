class City {
  final String _name;

  City(this._name);

  // Getter pour le nom de la ville
  String get name => _name;

  // Méthode statique pour valider un nom de ville
  static bool isValidCity(String name) {
    final cityRegex = RegExp(r"^[a-zA-ZÀ-ÖØ-öø-ÿ' -]+(?: [a-zA-ZÀ-ÖØ-öø-ÿ' -]+)*$");
    return cityRegex.hasMatch(name);
  }

  // Renvoie le nom de la ville
  @override
  String toString() => _name;

}
