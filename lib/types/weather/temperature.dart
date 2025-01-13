import '../../utils/value_object.dart';

enum TemperatureUnit { celsius, fahrenheit, kelvin }

class Temperature extends ValueObject<int> {
  static const int minTemperature = -100;
  static const int maxTemperature = 60;

  final TemperatureUnit unit;

  const Temperature(super.value, this.unit);

  int toCelsius() {
    switch (unit) {
      case TemperatureUnit.celsius:
        return value;
      case TemperatureUnit.fahrenheit:
        return ((value - 32) * 5 / 9).round();
      case TemperatureUnit.kelvin:
        return (value - 273.15).round();
    }
  }

  int toFahrenheit() {
    switch (unit) {
      case TemperatureUnit.celsius:
        return (value * 9 / 5 + 32).round();
      case TemperatureUnit.fahrenheit:
        return value;
      case TemperatureUnit.kelvin:
        return ((value - 273.15) * 9 / 5 + 32).round();
    }
  }

  int toKelvin() {
    switch (unit) {
      case TemperatureUnit.celsius:
        return (value + 273.15).round();
      case TemperatureUnit.fahrenheit:
        return ((value - 32) * 5 / 9 + 273.15).round();
      case TemperatureUnit.kelvin:
        return value;
    }
  }

  @override
  bool isValid() {
    return value >= minTemperature && value <= maxTemperature;
  }

  @override
  String toString() {
    switch (unit) {
      case TemperatureUnit.celsius:
        return "$value °C";
      case TemperatureUnit.fahrenheit:
        return "$value °F";
      case TemperatureUnit.kelvin:
        return "$value K";
    }
  }

  static String unitToString(TemperatureUnit unit) {
    switch (unit) {
      case TemperatureUnit.celsius:
        return "°C";
      case TemperatureUnit.fahrenheit:
        return "°F";
      case TemperatureUnit.kelvin:
        return "K";
    }
  }

  static TemperatureUnit stringToTemperatureUnit(String value) {
    switch (value) {
      case 'celsius':
        return TemperatureUnit.celsius;
      case 'fahrenheit':
        return TemperatureUnit.fahrenheit;
      case 'kelvin':
        return TemperatureUnit.kelvin;
      default:
        throw ArgumentError('Valeur de température inconnue : $value');
    }
  }

  static String loadTemperatureText(Temperature temperature, TemperatureUnit unit) {
    switch (unit) {
      case TemperatureUnit.celsius:
        return "${temperature.toCelsius()} °C";
      case TemperatureUnit.fahrenheit:
        return "${temperature.toFahrenheit()} °F";
      case TemperatureUnit.kelvin:
        return "${temperature.toKelvin()} K";
    }
  }

  static bool isValidTemperature(int value, TemperatureUnit unit) {
    Temperature temperature = Temperature(value, unit);
    return temperature.toCelsius() >= minTemperature && temperature.toCelsius() <= maxTemperature;
  }

  Map<String, dynamic> toJson() {
    return {
      'value': value,
      'unit': unit.name,
    };
  }
}
