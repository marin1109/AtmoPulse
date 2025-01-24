import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Services
import '../services/account_service.dart';
import '../services/fetch_and_notify.dart';

// Types
import '../types/common/email.dart';
import '../types/common/password.dart';
import '../types/common/fname.dart';
import '../types/common/lname.dart';
import '../types/common/age.dart';
import '../types/weather/humidity.dart';
import '../types/weather/precipitation.dart';
import '../types/weather/temperature.dart';
import '../types/weather/wind_speed.dart';
import '../types/weather/uv.dart';

// Utils
import '../utils/user_preferences.dart';

// Views
import '../views/user/user_page.dart';

/// Contrôleur pour la gestion du login et de l'inscription.
class LSController {
  /// Les clés de formulaire, injectées depuis la Vue.
  final GlobalKey<FormState> loginFormKey;
  final GlobalKey<FormState> signUpFormKey;

  // Données "login"
  late Email email;
  late Password password;

  // Données "signup"
  late FName name;
  late LName surname;
  late Age ageValue;

  // Sensibilités
  late Humidity humidityMin;
  late Humidity humidityMax;
  late Precipitation precipitationMin;
  late Precipitation precipitationMax;
  late Temperature temperatureMin;
  late Temperature temperatureMax;
  late WindSpeed windMin;
  late WindSpeed windMax;
  late UV uvValue;

  LSController({
    required this.loginFormKey,
    required this.signUpFormKey,
  });

  /// Connexion
  Future<void> loginUser(BuildContext context) async {
    if (loginFormKey.currentState!.validate()) {
      loginFormKey.currentState!.save();

      final userPrefs = Provider.of<UserPreferences>(context, listen: false);

      try {
        // Appel au service qui fait la requête HTTP (existe dans account_service.dart)
        final userData = await loginUserService(email, password);

        // Récupération des unités de préférences depuis le serveur
        final data = await getPreferencesUnit(email);

        // Mise à jour des préférences locales
        await userPrefs.setPreferredTemperatureUnit(
          Temperature.stringToTemperatureUnit(data['unite_temperature']),
        );
        await userPrefs.setPreferredWindUnit(
          WindSpeed.stringToWindUnit(data['unite_vent']),
        );
        await userPrefs.setPreferredHumidityUnit(
          Humidity.stringToHumidityUnit(data['unite_humidite']),
        );
        await userPrefs.setPreferredPrecipitationUnit(
          Precipitation.stringToPrecipitationUnit(data['unite_precipitations']),
        );

        // Sauvegarde des données utilisateur en local
        await _saveUserPrefs(context, userData);

        // Lancer la notification
        fetchAndNotify();

        // Redirection vers la page utilisateur
        _navigateToUserPage(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Email ou mot de passe incorrect')),
        );
      }
    }
  }

  /// Inscription
  Future<void> registerUser(BuildContext context) async {
    if (signUpFormKey.currentState!.validate()) {
      signUpFormKey.currentState!.save();
      final userPrefs = Provider.of<UserPreferences>(context, listen: false);

      try {
        // Création du compte sur le serveur
        await addUser(
          name,
          surname,
          email,
          password,
          ageValue,
          humidity_min: humidityMin,
          humidity_max: humidityMax,
          precipitation_min: precipitationMin,
          precipitation_max: precipitationMax,
          temperature_min: temperatureMin,
          temperature_max: temperatureMax,
          wind_min: windMin,
          wind_max: windMax,
          uv: uvValue,
        );

        // Mise à jour des unités sur le serveur
        await updatePreferencesUnit(
          email,
          userPrefs.preferredTemperatureUnit,
          userPrefs.preferredWindUnit,
          userPrefs.preferredHumidityUnit,
          userPrefs.preferredPrecipitationUnit,
        );

        // On se connecte automatiquement pour récupérer les infos
        final userData = await loginUserService(email, password);

        // Sauvegarde en local
        await _saveUserPrefs(context, userData);

        // Navigation vers la page utilisateur
        _navigateToUserPage(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erreur lors de l\'inscription')),
        );
      }
    }
  }

  /// Sauvegarde les informations de l'utilisateur dans les [UserPreferences].
  Future<void> _saveUserPrefs(BuildContext context, Map<String, dynamic> userData) async {
    final userPrefs = Provider.of<UserPreferences>(context, listen: false);

    // Indique qu'on est loggué
    await userPrefs.setIsLogged(true);

    // Sauvegarde infos personnelles
    await userPrefs.setEmail(userData['email'] ?? '');
    if (userData['nom'] != null) {
      await userPrefs.setNom(userData['nom']);
    }
    if (userData['prenom'] != null) {
      await userPrefs.setPrenom(userData['prenom']);
    }
    if (userData['age'] != null) {
      await userPrefs.setAge(userData['age']);
    }

    // Sauvegarde des sensibilités
    if (userData['temperature_min'] != null) {
      await userPrefs.setTempMin(userData['temperature_min'].toInt());
    }
    if (userData['temperature_max'] != null) {
      await userPrefs.setTempMax(userData['temperature_max'].toInt());
    }
    if (userData['humidite_min'] != null) {
      await userPrefs.setHumidityMin(userData['humidite_min'].toInt());
    }
    if (userData['humidite_max'] != null) {
      await userPrefs.setHumidityMax(userData['humidite_max'].toInt());
    }
    if (userData['precipitations_min'] != null) {
      await userPrefs.setPrecipMin(userData['precipitations_min'].toInt());
    }
    if (userData['precipitations_max'] != null) {
      await userPrefs.setPrecipMax(userData['precipitations_max'].toInt());
    }
    if (userData['vent_min'] != null) {
      await userPrefs.setWindMin(userData['vent_min'].toInt());
    }
    if (userData['vent_max'] != null) {
      await userPrefs.setWindMax(userData['vent_max'].toInt());
    }
    if (userData['uv'] != null) {
      await userPrefs.setUV(userData['uv'].toInt());
    }
  }

  /// Redirige vers la [UserPage].
  void _navigateToUserPage(BuildContext context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const UserPage()),
    );
  }
}
