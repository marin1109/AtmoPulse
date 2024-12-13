enum PrecipitationUnit { mm, inches, litersPerSquareMeter }

class Precipitation {
  final double value;
  final PrecipitationUnit unit;

  Precipitation(this.value, this.unit);

  // Conversion en millimètres (mm)
  double toMillimeters() {
    switch (unit) {
      case PrecipitationUnit.mm:
        return value;
      case PrecipitationUnit.inches:
        return value * 25.4;
      case PrecipitationUnit.litersPerSquareMeter:
        return value;
    }
  }

  // Conversion en pouces (inches)
  double toInches() {
    switch (unit) {
      case PrecipitationUnit.mm:
        return value / 25.4;
      case PrecipitationUnit.inches:
        return value;
      case PrecipitationUnit.litersPerSquareMeter:
        return value / 25.4;
    }
  }

  // Conversion en litres par mètre carré (l/m²)
  double toLitersPerSquareMeter() {
    switch (unit) {
      case PrecipitationUnit.mm:
        return value;
      case PrecipitationUnit.inches:
        return value * 25.4;
      case PrecipitationUnit.litersPerSquareMeter:
        return value;
    }
  }

  // Renvoie la valeur de la précipitation
  @override
  String toString() {
    switch (unit) {
      case PrecipitationUnit.mm:
        return "${value.toStringAsFixed(1)} mm";
      case PrecipitationUnit.inches:
        return "${value.toStringAsFixed(2)} inches";
      case PrecipitationUnit.litersPerSquareMeter:
        return "${value.toStringAsFixed(1)} l/m²";
    }
  }

  // Conversion de l'unité en string
  static String unitToString(PrecipitationUnit unit) {
    switch (unit) {
      case PrecipitationUnit.mm:
        return "mm";
      case PrecipitationUnit.inches:
        return "inches";
      case PrecipitationUnit.litersPerSquareMeter:
        return "l/m²";
    }
  }

  static PrecipitationUnit stringToPrecipitationUnit(String unit) {
    switch (unit) {
      case "mm":
        return PrecipitationUnit.mm;
      case "inches":
        return PrecipitationUnit.inches;
      case "litersPerSquareMeter":
        return PrecipitationUnit.litersPerSquareMeter;
      default:
        throw Exception('Valeur de précipitation inconnue : $unit');
    }
  }

  static String loadPrecipitationText(Precipitation precipitation, PrecipitationUnit unit) {
    switch (unit) {
      case PrecipitationUnit.mm:
        return "${precipitation.toMillimeters().toStringAsFixed(1)} mm";
      case PrecipitationUnit.inches:
        return "${precipitation.toInches().toStringAsFixed(2)} inches";
      case PrecipitationUnit.litersPerSquareMeter:
        return "${precipitation.toLitersPerSquareMeter().toStringAsFixed(1)} l/m²";
    }
  }

  static bool isValidPrecipitation(double value) {
    return value >= 0 && value <= 305;
  }

  Map<String, dynamic> toJson() {
    return {
      'value': value,
      'unit': unit.name,
    };
  }
  
}
