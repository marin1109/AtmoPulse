enum PressureUnit { hPa, atm, psi, Pa, mmHg }

class Pressure {
  final double value;
  final PressureUnit unit;

  Pressure(this.value, this.unit);

  // Conversion en hPa
  double toHpa() {
    switch (unit) {
      case PressureUnit.hPa:
        return value;
      case PressureUnit.atm:
        return value * 1013.25;
      case PressureUnit.psi:
        return value * 68.9476;
      case PressureUnit.Pa:
        return value / 100;
      case PressureUnit.mmHg:
        return value * 1.33322;
    }
  }

  // Conversion en atm
  double toAtm() {
    switch (unit) {
      case PressureUnit.hPa:
        return value / 1013.25;
      case PressureUnit.atm:
        return value;
      case PressureUnit.psi:
        return value / 14.6959;
      case PressureUnit.Pa:
        return value / 101325;
      case PressureUnit.mmHg:
        return value / 760;
    }
  }

  // Conversion en psi
  double toPsi() {
    switch (unit) {
      case PressureUnit.hPa:
        return value / 68.9476;
      case PressureUnit.atm:
        return value * 14.6959;
      case PressureUnit.psi:
        return value;
      case PressureUnit.Pa:
        return value / 6894.76;
      case PressureUnit.mmHg:
        return value / 51.715;
    }
  }

  // Conversion en Pa
  double toPa() {
    switch (unit) {
      case PressureUnit.hPa:
        return value * 100;
      case PressureUnit.atm:
        return value * 101325;
      case PressureUnit.psi:
        return value * 6894.76;
      case PressureUnit.Pa:
        return value;
      case PressureUnit.mmHg:
        return value * 133.322;
    }
  }

  // Conversion en mmHg
  double toMmHg() {
    switch (unit) {
      case PressureUnit.hPa:
        return value / 1.33322;
      case PressureUnit.atm:
        return value * 760;
      case PressureUnit.psi:
        return value * 51.715;
      case PressureUnit.Pa:
        return value / 133.322;
      case PressureUnit.mmHg:
        return value;
    }
  }

  // Renvoie la valeur de la pression
  @override
  String toString() {
    switch (unit) {
      case PressureUnit.hPa:
        return "${value.toStringAsFixed(2)} hPa";
      case PressureUnit.atm:
        return "${value.toStringAsFixed(5)} atm";
      case PressureUnit.psi:
        return "${value.toStringAsFixed(2)} psi";
      case PressureUnit.Pa:
        return "${value.toStringAsFixed(0)} Pa";
      case PressureUnit.mmHg:
        return "${value.toStringAsFixed(2)} mmHg";
    }
  }

  static PressureUnit stringToPressureUnit(String unit) {
    switch (unit) {
      case "hPa":
        return PressureUnit.hPa;
      case "atm":
        return PressureUnit.atm;
      case "psi":
        return PressureUnit.psi;
      case "Pa":
        return PressureUnit.Pa;
      case "mmHg":
        return PressureUnit.mmHg;
      default:
        throw Exception('Valeur de pression inconnue : $unit');
    }
  }

  // Conversion de l'unité en string
  static String unitToString(PressureUnit unit) {
    switch (unit) {
      case PressureUnit.hPa:
        return "hPa";
      case PressureUnit.atm:
        return "atm";
      case PressureUnit.psi:
        return "psi";
      case PressureUnit.Pa:
        return "Pa";
      case PressureUnit.mmHg:
        return "mmHg";
    }
  }

  static bool isValidPressure(double value) {
    return value >= 870 && value <= 1084;
  }
  
  Map<String, dynamic> toJson() {
    return {
      'value': value,
      'unit': unit.name,
    };
  }

}
