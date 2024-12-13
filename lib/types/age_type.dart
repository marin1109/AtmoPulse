class Age{
  final int _age;
  
  Age(this._age);

  // Vérifie si l'âge est valide
  static bool isValidAge(int age) {
    return age >= 0 && age <= 120;
  }
  
  // Renvoie l'âge
  int toInt() => _age;

  // Renvoie l'âge sous forme de chaîne de caractères
  @override
  String toString() => '$_age';
  
}
