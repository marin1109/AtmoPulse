// Dart imports
import 'dart:math';

enum HumidityUnit { relative, absolute }

class Humidity {
  final double value;
  final HumidityUnit unit;

  Humidity(this.value, this.unit);

  // Conversion en %RH
  double toAbsolute(double temperatureCelsius) {
    if (unit == HumidityUnit.absolute) {
      return value;
    } else {
      const double mwWater = 18.01528;
      const double r = 8.314462618;

      double saturationPressure = 6.1078 *
          100 *
          pow(10, (7.5 * temperatureCelsius) / (temperatureCelsius + 237.3));

      double partialPressure =
          (value * saturationPressure) / 100;

      return (partialPressure * mwWater) / (r * (temperatureCelsius + 273.15));
    }
  }

  // Conversion en g/m³
  double toRelative(double temperatureCelsius) {
    if (unit == HumidityUnit.relative) {
      return value;
    } else {
      const double mwWater = 18.01528;
      const double r = 8.314462618;

      double saturationPressure = 6.1078 *
          100 *
          pow(10, (7.5 * temperatureCelsius) / (temperatureCelsius + 237.3));

      double partialPressure =
          (value * r * (temperatureCelsius + 273.15)) / mwWater;

      return (partialPressure / saturationPressure) * 100;
    }
  }

  // Renvoie la valeur de l'humidité
  @override
  String toString() {
    switch (unit) {
      case HumidityUnit.relative:
        return "${value.toStringAsFixed(1)} %RH";
      case HumidityUnit.absolute:
        return "${value.toStringAsFixed(2)} g/m³";
    }
  }

  // Conversion de l'unité en string
  static String unitToString(HumidityUnit unit) {
    switch (unit) {
      case HumidityUnit.relative:
        return "%RH";
      case HumidityUnit.absolute:
        return "g/m³";
    }
  }

  static HumidityUnit stringToHumidityUnit(String unit) {
    switch (unit) {
      case "relative":
        return HumidityUnit.relative;
      case "absolute":
        return HumidityUnit.absolute;
      default:
        throw Exception('Valeur d\'humidité inconnue : $unit');
    }
  }

  static String loadHumidityText(Humidity humidity, HumidityUnit unit) {
    switch (unit) {
      case HumidityUnit.relative:
        return "${humidity.value.toStringAsFixed(1)} %RH";
      case HumidityUnit.absolute:
        return "${humidity.value.toStringAsFixed(2)} g/m³";
    }
  }

  // Vérifie si la valeur de l'humidité est valide
  static bool isValidHumidity(double value, HumidityUnit unit, double temperatureCelsius) {
    Humidity humidity = Humidity(value, unit);
    return humidity.toRelative(temperatureCelsius) >= 0 && humidity.toRelative(temperatureCelsius) <= 100;
  }

  Map<String, dynamic> toJson() {
    return {
      'value': value,
      'unit': unit.name,
    };
  }

}
