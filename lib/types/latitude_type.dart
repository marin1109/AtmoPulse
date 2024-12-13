class Latitude {
  final double latitude;

  Latitude(this.latitude);

  // Vérifie si la latitude est valide
  bool isValidLatitude() {
    return latitude >= -90 && latitude <= 90;
  }

  // Renvoie la latitude
  double getLatitude() => latitude;

}
