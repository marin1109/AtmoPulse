// Flutter imports
import 'package:flutter/foundation.dart';

// Package imports
import 'package:shared_preferences/shared_preferences.dart';

// Import des types
import '../types/temperature_type.dart';
import '../types/wind_type.dart';
import '../types/pressure_type.dart';
import '../types/precipitation_type.dart';
import '../types/humidity_type.dart';

class UserPreferences extends ChangeNotifier {
  TemperatureUnit _preferredTemperatureUnit = TemperatureUnit.celsius;
  WindUnit _preferredWindUnit = WindUnit.kmh;
  PressureUnit _preferredPressureUnit = PressureUnit.hPa;
  PrecipitationUnit _preferredPrecipitationUnit = PrecipitationUnit.mm;
  HumidityUnit _preferredHumidityUnit = HumidityUnit.relative;
  bool _isLogged = false;

  UserPreferences() {
    loadPreferences();
  }

  // Getters
  TemperatureUnit get preferredTemperatureUnit => _preferredTemperatureUnit;
  WindUnit get preferredWindUnit => _preferredWindUnit;
  PressureUnit get preferredPressureUnit => _preferredPressureUnit;
  PrecipitationUnit get preferredPrecipitationUnit => _preferredPrecipitationUnit;
  HumidityUnit get preferredHumidityUnit => _preferredHumidityUnit;
  bool get isLogged => _isLogged;

  // Load preferences from SharedPreferences
  Future<void> loadPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _preferredTemperatureUnit = TemperatureUnit.values.firstWhere(
      (e) => e.toString() == 'TemperatureUnit.${prefs.getString('unite_temperature') ?? 'celsius'}',
      orElse: () => TemperatureUnit.celsius,
    );
    _preferredWindUnit = WindUnit.values.firstWhere(
      (e) => e.toString() == 'WindUnit.${prefs.getString('unite_vitesse') ?? 'kmh'}',
      orElse: () => WindUnit.kmh,
    );
    _preferredPressureUnit = PressureUnit.values.firstWhere(
      (e) => e.toString() == 'PressureUnit.${prefs.getString('unite_pression') ?? 'hPa'}',
      orElse: () => PressureUnit.hPa,
    );
    _preferredPrecipitationUnit = PrecipitationUnit.values.firstWhere(
      (e) => e.toString() == 'PrecipitationUnit.${prefs.getString('unite_precipitations') ?? 'mm'}',
      orElse: () => PrecipitationUnit.mm,
    );
    _preferredHumidityUnit = HumidityUnit.values.firstWhere(
      (e) => e.toString() == 'HumidityUnit.${prefs.getString('unite_humidite') ?? 'relative'}',
      orElse: () => HumidityUnit.relative,
    );
    _isLogged = prefs.getBool('isLogged') ?? false;
    notifyListeners();
  }

  // Setters
  Future<void> setPreferredTemperatureUnit(TemperatureUnit unit) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('unite_temperature', unit.name);
    _preferredTemperatureUnit = unit;
    notifyListeners();
  }

  Future<void> setPreferredWindUnit(WindUnit unit) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('unite_vitesse', unit.name);
    _preferredWindUnit = unit;
    notifyListeners();
  }

  Future<void> setPreferredPressureUnit(PressureUnit unit) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('unite_pression', unit.name);
    _preferredPressureUnit = unit;
    notifyListeners();
  }

  Future<void> setPreferredPrecipitationUnit(PrecipitationUnit unit) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('unite_precipitations', unit.name);
    _preferredPrecipitationUnit = unit;
    notifyListeners();
  }

  Future<void> setPreferredHumidityUnit(HumidityUnit unit) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('unite_humidite', unit.name);
    _preferredHumidityUnit = unit;
    notifyListeners();
  }

  Future<void> setIsLogged(bool value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLogged', value);
    _isLogged = value;
    notifyListeners();
  }
  
}
