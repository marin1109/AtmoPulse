class Longitude {
  final double value;

  Longitude(this.value);

  // Vérifie si la longitute est valide
  static bool isValidLongitute(double value) {
    return value >= -180 && value <= 180;
  }

  double getLongitute() => value;
  
}
