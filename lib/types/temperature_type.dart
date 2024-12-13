enum TemperatureUnit { celsius, fahrenheit, kelvin }

class Temperature {
  final int value;
  final TemperatureUnit unit;

  Temperature(this.value, this.unit);

  // Conversion en °C
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

  // Conversion en °F
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

  // Conversion en K
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

  // Conversion en unité donnée
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

  // Conversion de l'unité en string
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
        return "${temperature.toCelsius()} ${unitToString(unit)}";
      case TemperatureUnit.fahrenheit:
        return "${temperature.toFahrenheit()} ${unitToString(unit)}";
      case TemperatureUnit.kelvin:
        return "${temperature.toKelvin()} ${unitToString(unit)}";
    }
  }

  // Vérification de la validité de la valeur de température
  static bool isValidTemperature(int value) {
    return value >= -100 && value <= 60;
  }
  
}
