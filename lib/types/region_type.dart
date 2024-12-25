class Region {
  final String name;
  
  Region(this.name);

  // Méthode statique pour valider une région
  static bool isValidRegion(String name) {
    final regionRegex = RegExp(r"^[a-zA-ZÀ-ÖØ-öø-ÿ' -]+(?: [a-zA-ZÀ-ÖØ-öø-ÿ' -]+)*$");
    return regionRegex.hasMatch(name);
  }

  // Renvoie la région
  @override
  String toString() => name;
  
}
