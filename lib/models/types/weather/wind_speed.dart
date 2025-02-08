import '../../../utils/value_object.dart';

enum WindUnit { kmh, ms, mph, fts, knots }

class WindSpeed extends ValueObject<int> {
  static const int minWindSpeed = 0;
  static const int maxWindSpeed = 408;

  final WindUnit unit;

  const WindSpeed(super.value, this.unit);

  static WindSpeed convert(WindSpeed wind, WindUnit unit) {
    switch (unit) {
      case WindUnit.kmh:
        return WindSpeed(wind.toKmh(), WindUnit.kmh);
      case WindUnit.ms:
        return WindSpeed(wind.toMs(), WindUnit.ms);
      case WindUnit.mph:
        return WindSpeed(wind.toMph(), WindUnit.mph);
      case WindUnit.fts:
        return WindSpeed(wind.toFts(), WindUnit.fts);
      case WindUnit.knots:
        return WindSpeed(wind.toKnots(), WindUnit.knots);
    }
  } 

  int toKmh() {
    switch (unit) {
      case WindUnit.kmh:
        return value;
      case WindUnit.ms:
        return (value * 3.6).round();
      case WindUnit.mph:
        return (value * 1.60934).round();
      case WindUnit.fts:
        return (value * 1.09728).round();
      case WindUnit.knots:
        return (value * 1.852).round();
    }
  }

  int toMs() {
    switch (unit) {
      case WindUnit.kmh:
        return (value / 3.6).round();
      case WindUnit.ms:
        return value;
      case WindUnit.mph:
        return (value * 0.44704).round();
      case WindUnit.fts:
        return (value * 0.3048).round();
      case WindUnit.knots:
        return (value * 0.514444).round();
    }
  }

  int toMph() {
    switch (unit) {
      case WindUnit.kmh:
        return (value * 0.621371).round();
      case WindUnit.ms:
        return (value * 2.23694).round();
      case WindUnit.mph:
        return value;
      case WindUnit.fts:
        return (value * 0.681818).round();
      case WindUnit.knots:
        return (value * 1.15078).round();
    }
  }

  int toFts() {
    switch (unit) {
      case WindUnit.kmh:
        return (value * 0.911344).round();
      case WindUnit.ms:
        return (value * 3.28084).round();
      case WindUnit.mph:
        return (value * 1.46667).round();
      case WindUnit.fts:
        return value;
      case WindUnit.knots:
        return (value * 1.68781).round();
    }
  }

  int toKnots() {
    switch (unit) {
      case WindUnit.kmh:
        return (value * 0.539957).round();
      case WindUnit.ms:
        return (value * 1.94384).round();
      case WindUnit.mph:
        return (value * 0.868976).round();
      case WindUnit.fts:
        return (value * 0.592484).round();
      case WindUnit.knots:
        return value;
    }
  }

  @override
  bool isValid() {
    return value >= minWindSpeed && value <= maxWindSpeed;
  }

  @override
  String toString() {
    switch (unit) {
      case WindUnit.kmh:
        return "$value km/h";
      case WindUnit.ms:
        return "$value m/s";
      case WindUnit.mph:
        return "$value mph";
      case WindUnit.fts:
        return "$value ft/s";
      case WindUnit.knots:
        return "$value nœuds";
    }
  }

  static String unitToString(WindUnit unit) {
    switch (unit) {
      case WindUnit.kmh:
        return "km/h";
      case WindUnit.ms:
        return "m/s";
      case WindUnit.mph:
        return "mph";
      case WindUnit.fts:
        return "ft/s";
      case WindUnit.knots:
        return "nœuds";
    }
  }

  static WindUnit stringToWindUnit(String unit) {
    switch (unit) {
      case "kmh":
        return WindUnit.kmh;
      case "ms":
        return WindUnit.ms;
      case "mph":
        return WindUnit.mph;
      case "fts":
        return WindUnit.fts;
      case "knots":
        return WindUnit.knots;
      default:
        throw Exception('Valeur de vitesse du vent inconnue : $unit');
    }
  }

  static String loadWindText(WindSpeed wind, WindUnit unit) {
    switch (unit) {
      case WindUnit.kmh:
        return "${wind.toKmh()} km/h";
      case WindUnit.ms:
        return "${wind.toMs()} m/s";
      case WindUnit.mph:
        return "${wind.toMph()} mph";
      case WindUnit.fts:
        return "${wind.toFts()} ft/s";
      case WindUnit.knots:
        return "${wind.toKnots()} nœuds";
    }
  }

  static bool isValidWindSpeed(int speed, WindUnit unit) {
    WindSpeed wind = WindSpeed(speed, unit);
    return wind.toKmh() >= minWindSpeed && wind.toKmh() <= maxWindSpeed;
  }

  Map<String, dynamic> toJson() {
    return {
      'value': value,
      'unit': unit.name,
    };
  }
}
