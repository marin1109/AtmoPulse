import '../../utils/value_object.dart';
import 'dart:math';

enum HumidityUnit { relative, absolute }

class Humidity extends ValueObject<int> {
  static const int minHumidity = 0;
  static const int maxHumidity = 100;
  final HumidityUnit unit;

  const Humidity(super.value, this.unit);

  static Humidity convert(Humidity humidity, HumidityUnit unit) {
    switch (unit) {
      case HumidityUnit.relative:
        return Humidity(humidity.toRelative(0).round(), unit);
      case HumidityUnit.absolute:
        return Humidity(humidity.toAbsolute(0).round(), unit);
    }
  }

  double toAbsolute(int temperatureCelsius) {
    if (unit == HumidityUnit.absolute) {
      return value.toDouble();
    } else {
      const double mwWater = 18.01528;
      const double r = 8.314462618;

      double saturationPressure = 6.1078 *
          100 *
          pow(10, (7.5 * temperatureCelsius) / (temperatureCelsius + 237.3));

      // Conversion de la valeur entière en double pour le calcul
      double partialPressure = (value.toDouble() * saturationPressure) / 100;

      return (partialPressure * mwWater) / (r * (temperatureCelsius + 273.15));
    }
  }

  double toRelative(int temperatureCelsius) {
    if (unit == HumidityUnit.relative) {
      return value.toDouble();
    } else {
      const double mwWater = 18.01528;
      const double r = 8.314462618;

      double saturationPressure = 6.1078 *
          100 *
          pow(10, (7.5 * temperatureCelsius) / (temperatureCelsius + 237.3));

      double partialPressure =
          (value.toDouble() * r * (temperatureCelsius + 273.15)) / mwWater;

      return (partialPressure / saturationPressure) * 100;
    }
  }

  @override
  bool isValid() {
    if (unit == HumidityUnit.relative) {
      return value >= minHumidity && value <= maxHumidity;
    } else {
      return value >= 0;
    }
  }

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
        return "${humidity.value} %";
      case HumidityUnit.absolute:
        return "${humidity.value} g/m³";
    }
  }

  static bool isValidHumidity(int value, HumidityUnit unit, int temperatureCelsius) {
    Humidity humidity = Humidity(value, unit);
    double relativeHumidity = humidity.toRelative(temperatureCelsius);
    return relativeHumidity >= 0 && relativeHumidity <= 100;
  }
}
