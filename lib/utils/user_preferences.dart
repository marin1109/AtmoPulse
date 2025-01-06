import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Importez vos types exacts
import '../types/email_type.dart';
import '../types/lname_type.dart';
import '../types/fname_type.dart';
import '../types/age_type.dart';
import '../types/temperature_type.dart';
import '../types/wind_type.dart';
import '../types/precipitation_type.dart';
import '../types/humidity_type.dart';
import '../types/uv_type.dart';

class UserPreferences extends ChangeNotifier {
  // Unités
  TemperatureUnit _preferredTemperatureUnit = TemperatureUnit.celsius;
  WindUnit _preferredWindUnit = WindUnit.kmh;
  PrecipitationUnit _preferredPrecipitationUnit = PrecipitationUnit.mm;
  HumidityUnit _preferredHumidityUnit = HumidityUnit.relative;

  // Indicateur de connexion
  bool _isLogged = false;

  // Données de l'utilisateur
  Email _email = Email('');
  LName _nom = LName('');
  FName _prenom = FName('');
  Age _age = Age(0);

  // Sensibilités
  Humidity? _humidityMin;
  Humidity? _humidityMax;
  Precipitation? _precipMin;
  Precipitation? _precipMax;
  Temperature? _tempMin;
  Temperature? _tempMax;
  WindSpeed? _windMin;
  WindSpeed? _windMax;
  UV? _uvValue;

  UserPreferences() {
    loadPreferences();
  }

  // ==============================
  // Getters (inchangés)
  // ==============================
  TemperatureUnit get preferredTemperatureUnit => _preferredTemperatureUnit;
  WindUnit get preferredWindUnit => _preferredWindUnit;
  PrecipitationUnit get preferredPrecipitationUnit => _preferredPrecipitationUnit;
  HumidityUnit get preferredHumidityUnit => _preferredHumidityUnit;

  bool get isLogged => _isLogged;

  Email get email => _email;
  LName get nom => _nom;
  FName get prenom => _prenom;
  Age get age => _age;

  Humidity? get humidityMin => _humidityMin;
  Humidity? get humidityMax => _humidityMax;
  Precipitation? get precipMin => _precipMin;
  Precipitation? get precipMax => _precipMax;
  Temperature? get tempMin => _tempMin;
  Temperature? get tempMax => _tempMax;
  WindSpeed? get windMin => _windMin;
  WindSpeed? get windMax => _windMax;
  UV? get uvValue => _uvValue;

  // ==============================
  // Méthodes de chargement (inchangées)
  // ==============================
  Future<void> loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();

    // Chargement des unités
    _preferredTemperatureUnit = TemperatureUnit.values.firstWhere(
      (e) => e.name == (prefs.getString('unite_temperature') ?? 'celsius'),
      orElse: () => TemperatureUnit.celsius,
    );
    _preferredWindUnit = WindUnit.values.firstWhere(
      (e) => e.name == (prefs.getString('unite_vitesse') ?? 'kmh'),
      orElse: () => WindUnit.kmh,
    );
    _preferredPrecipitationUnit = PrecipitationUnit.values.firstWhere(
      (e) => e.name == (prefs.getString('unite_precipitations') ?? 'mm'),
      orElse: () => PrecipitationUnit.mm,
    );
    _preferredHumidityUnit = HumidityUnit.values.firstWhere(
      (e) => e.name == (prefs.getString('unite_humidite') ?? 'relative'),
      orElse: () => HumidityUnit.relative,
    );

    // Indicateur de connexion
    _isLogged = prefs.getBool('isLogged') ?? false;

    // Données utilisateur de base
    _email = Email(prefs.getString('email') ?? '');
    _nom = LName(prefs.getString('nom') ?? '');
    _prenom = FName(prefs.getString('prenom') ?? '');
    _age = Age(prefs.getInt('age') ?? 0);

    // Sensibilités
    _humidityMin = Humidity(
      prefs.getDouble('humidite_min') ?? 0.0,
      _preferredHumidityUnit
    );
    _humidityMax = Humidity(
      prefs.getDouble('humidite_max') ?? 100.0,
      _preferredHumidityUnit
    );
    _precipMin = Precipitation(
      prefs.getDouble('precipitations_min') ?? 0.0,
      _preferredPrecipitationUnit
    );
    _precipMax = Precipitation(
      prefs.getDouble('precipitations_max') ?? 100.0,
      _preferredPrecipitationUnit
    );
    _tempMin = Temperature(
      prefs.getInt('temperature_min') ?? -50,
      _preferredTemperatureUnit
    );
    _tempMax = Temperature(
      prefs.getInt('temperature_max') ?? 50,
      _preferredTemperatureUnit
    );

    // Ici on stocke vent_min et vent_max en double. 
    // Donc on fait un getDouble, et on instancie WindSpeed avec double (à adapter si vous souhaitez un int).
    _windMin = WindSpeed(
      (prefs.getInt('vent_min') ?? 0), 
      _preferredWindUnit
    );
    _windMax = WindSpeed(
      (prefs.getInt('vent_max') ?? 200), 
      _preferredWindUnit
    );

    // L'UV est stocké sous forme de double
    _uvValue = UV(
      prefs.getDouble('uv') ?? 0.0
    );

    notifyListeners();
  }

  /// Crée les clés par défaut (si elles n'existent pas).
  Future<void> initializeDefaultUnits() async {
    final prefs = await SharedPreferences.getInstance();

    if (!prefs.containsKey('unite_temperature')) {
      await prefs.setString('unite_temperature', TemperatureUnit.celsius.name);
    }
    if (!prefs.containsKey('unite_vitesse')) {
      await prefs.setString('unite_vitesse', WindUnit.kmh.name);
    }
    if (!prefs.containsKey('unite_precipitations')) {
      await prefs.setString('unite_precipitations', PrecipitationUnit.mm.name);
    }
    if (!prefs.containsKey('unite_humidite')) {
      await prefs.setString('unite_humidite', HumidityUnit.relative.name);
    }

    await loadPreferences();
  }

  // ==============================
  // Setters pour les unités
  // ==============================
  Future<void> setPreferredTemperatureUnit(TemperatureUnit unit) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('unite_temperature', unit.name);
    _preferredTemperatureUnit = unit;
    // Réinstancier aussi les valeurs existantes de _tempMin/_tempMax 
    // (optionnel, si vous voulez immédiatement refléter la nouvelle unité)
    if (_tempMin != null) {
      _tempMin = Temperature(_tempMin!.value, _preferredTemperatureUnit);
    }
    if (_tempMax != null) {
      _tempMax = Temperature(_tempMax!.value, _preferredTemperatureUnit);
    }
    notifyListeners();
  }

  Future<void> setPreferredWindUnit(WindUnit unit) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('unite_vitesse', unit.name);
    _preferredWindUnit = unit;
    if (_windMin != null) {
      _windMin = WindSpeed(_windMin!.value, _preferredWindUnit);
    }
    if (_windMax != null) {
      _windMax = WindSpeed(_windMax!.value, _preferredWindUnit);
    }
    notifyListeners();
  }

  Future<void> setPreferredPrecipitationUnit(PrecipitationUnit unit) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('unite_precipitations', unit.name);
    _preferredPrecipitationUnit = unit;
    if (_precipMin != null) {
      _precipMin = Precipitation(_precipMin!.value, _preferredPrecipitationUnit);
    }
    if (_precipMax != null) {
      _precipMax = Precipitation(_precipMax!.value, _preferredPrecipitationUnit);
    }
    notifyListeners();
  }

  Future<void> setPreferredHumidityUnit(HumidityUnit unit) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('unite_humidite', unit.name);
    _preferredHumidityUnit = unit;
    if (_humidityMin != null) {
      _humidityMin = Humidity(_humidityMin!.value, _preferredHumidityUnit);
    }
    if (_humidityMax != null) {
      _humidityMax = Humidity(_humidityMax!.value, _preferredHumidityUnit);
    }
    notifyListeners();
  }

  // ==============================
  // Gestion de l'indicateur isLogged
  // ==============================
  Future<void> setIsLogged(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLogged', value);
    _isLogged = value;
    notifyListeners();
  }

  // ==============================
  // Setters pour l'utilisateur
  // ==============================
  Future<void> setEmail(String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('email', value);
    _email = Email(value);
    notifyListeners();
  }

  Future<void> setNom(String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('nom', value);
    _nom = LName(value);
    notifyListeners();
  }

  Future<void> setPrenom(String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('prenom', value);
    _prenom = FName(value);
    notifyListeners();
  }

  Future<void> setAge(int value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('age', value);
    _age = Age(value);
    notifyListeners();
  }

  // ==============================
  // Setters pour les sensibilités
  // ==============================

  /// Stocke l'humidité min en double, 
  /// et réinstancie `_humidityMin = Humidity(val, _preferredHumidityUnit)`.
  Future<void> setHumidityMin(double val) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('humidite_min', val);
    _humidityMin = Humidity(val, _preferredHumidityUnit);
    notifyListeners();
  }

  Future<void> setHumidityMax(double val) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('humidite_max', val);
    _humidityMax = Humidity(val, _preferredHumidityUnit);
    notifyListeners();
  }

  Future<void> setPrecipMin(double val) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('precipitations_min', val);
    _precipMin = Precipitation(val, _preferredPrecipitationUnit);
    notifyListeners();
  }

  Future<void> setPrecipMax(double val) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('precipitations_max', val);
    _precipMax = Precipitation(val, _preferredPrecipitationUnit);
    notifyListeners();
  }

  /// Ici, on stocke la température min en int dans SharedPreferences,
  /// puis on crée un objet `Temperature`.
  Future<void> setTempMin(int val) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('temperature_min', val);
    _tempMin = Temperature(val, _preferredTemperatureUnit);
    notifyListeners();
  }

  Future<void> setTempMax(int val) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('temperature_max', val);
    _tempMax = Temperature(val, _preferredTemperatureUnit);
    notifyListeners();
  }

  /// Si vous voulez stocker le vent en double, 
  /// alors assurez-vous que `WindSpeed` accepte un double.
  Future<void> setWindMin(int val) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('vent_min', val);
    _windMin = WindSpeed(val, _preferredWindUnit);
    notifyListeners();
  }

  Future<void> setWindMax(int val) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('vent_max', val);
    _windMax = WindSpeed(val, _preferredWindUnit);
    notifyListeners();
  }

  /// Si vous souhaitez un UV en double, vous pouvez le stocker en double.
  Future<void> setUV(double val) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('uv', val);
    _uvValue = UV(val);
    notifyListeners();
  }

  // ==============================
  // Méthode pour tout nettoyer
  // ==============================
  Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    await loadPreferences(); // recharge depuis zéro
    notifyListeners();
  }
}
