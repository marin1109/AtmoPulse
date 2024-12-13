// Dart imports
import 'dart:convert';

// Package imports
import 'package:AtmoPulse/types/humidity_type.dart';
import 'package:AtmoPulse/types/precipitation_type.dart';
import 'package:AtmoPulse/types/pressure_type.dart';
import 'package:AtmoPulse/types/temperature_type.dart';
import 'package:AtmoPulse/types/uv_type.dart';
import 'package:AtmoPulse/types/wind_type.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

// Type imports
import '../types/email_type.dart';
import '../types/password_type.dart';
import '../types/fname_type.dart';
import '../types/lname_type.dart';
import '../types/age_type.dart';


final String apiBaseUrl = dotenv.env['GCLOUD_API_BASE_URL']!;

// Fonction pour ajouter un utilisateur
Future<void> addUser(
  FName prenom,
  LName nom,
  Email email,
  Password motDePasse, 
  Age age, {
  required Humidity humidity_min,
  required Humidity humidity_max,
  required Precipitation precipitation_min,
  required Precipitation precipitation_max,
  required Pressure pressure_min,
  required Pressure pressure_max,
  required Temperature temperature_min,
  required Temperature temperature_max,
  required WindSpeed wind_min,
  required WindSpeed wind_max,
  required UV uv,
}) async {
  final url = Uri.parse(
      '$apiBaseUrl/create_utilisateurs');
  final response = await http.post(
    url,
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({
      'prenom': prenom.toString(),
      'nom': nom.toString(),
      'age': age.toInt(),
      'email': email.toString(),
      'mot_de_passe': motDePasse.toString(),
      'sensibilites': {
        'humidite_min': humidity_min.value,
        'humidite_max': humidity_max.value,
        'precipitations_min': precipitation_min.value,
        'precipitations_max': precipitation_max.value,
        'pression_min': pressure_min.value,
        'pression_max': pressure_max.value,
        'temperature_min': temperature_min.value,
        'temperature_max': temperature_max.value,
        'vent_min': wind_min.value,
        'vent_max': wind_max.value,
        'uv': uv.value,
      },
    }),
  );

  print('Status Code: ${response.statusCode}');
  print('Response Body: ${response.body}');

  if (response.statusCode == 201) {
    print('Utilisateur ajouté avec succès.');
  } else {
    throw Exception(
        'Erreur lors de l\'ajout de l\'utilisateur: ${response.body}');
  }
}

// Fonction pour se connecter
Future<Map<String, dynamic>> loginUser(Email email, Password motDePasse) async {
  final url = Uri.parse(
      '$apiBaseUrl/login_utilisateurs');
  final response = await http.post(
    url,
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({
      'email': email.toString(),
      'mot_de_passe': motDePasse.toString(),
    }),
  );

  print('Status Code: ${response.statusCode}');
  print('Response Body: ${response.body}');

  if (response.statusCode == 200) {
    print('Connexion réussie.');
    return jsonDecode(response.body);
  } else {
    throw Exception('Erreur lors de la connexion: ${response.body}');
  }
}

// Fonction pour mettre à jour le mot de passe
Future<void> updatePassword(Email email, Password oldPassword, Password newPassword) async {
  final url = Uri.parse('$apiBaseUrl/update_password');
  final response = await http.put(
    url,
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({
      'email': email,
      'old_password': oldPassword.toString(),
      'new_password': newPassword.toString(),
    }),
  );

  print('Status Code: ${response.statusCode}');
  print('Response Body: ${response.body}');

  if (response.statusCode == 200) {
    print('Mot de passe mis à jour avec succès.');
  } else {
    throw Exception('Erreur lors de la mise à jour du mot de passe: ${response.body}');
  }
}

// Fonction pour supprimer un utilisateur (mise à jour)
Future<void> deleteUser(Email email, Password password) async {
  final url = Uri.parse('$apiBaseUrl/rm_utilisateur');
  final response = await http.delete(
    url,
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({
      'email': email.toString(),
      'password': password.toString(),
    }),
  );

  print('Status Code: ${response.statusCode}');
  print('Response Body: ${response.body}');

  if (response.statusCode == 200) {
    print('Utilisateur supprimé avec succès.');
  } else {
    throw Exception('Erreur lors de la suppression de l\'utilisateur: ${response.body}');
  }
}

// Fonction pour mettre à jour ou ajouter les préférences d'unités
Future<void> updatePreferencesUnit(
  Email email, 
  TemperatureUnit? uniteTemperature,
  WindUnit? uniteVent,
  HumidityUnit? uniteHumidite,
  PressureUnit? unitePression,
  PrecipitationUnit? unitePrecipitations,
) async {
  final url = Uri.parse('$apiBaseUrl/update_preferences_unite');
  final response = await http.post(
    url,
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({
      'email': email.toString(),
      'preferences': {
        'unite_temperature': uniteTemperature?.name,
        'unite_vent': uniteVent?.name,
        'unite_humidite': uniteHumidite?.name,
        'unite_pression': unitePression?.name,
        'unite_precipitations': unitePrecipitations?.name,
      },
    }),
  );

  print('Status Code: ${response.statusCode}');
  print('Response Body: ${response.body}');

  if (response.statusCode == 200) {
    print('Préférences mises à jour avec succès.');
  } else {
    throw Exception('Erreur lors de la mise à jour des préférences: ${response.body}');
  }
}

// Fonction pour récupérer les préférences d'unités d'un utilisateur
Future<Map<String, dynamic>> getPreferencesUnit(Email email) async {
  final url = Uri.parse('$apiBaseUrl/get_preferences_unite');
  final response = await http.post(
    url,
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({
      'email': email.toString(),
    }),
  );

  print('Status Code: ${response.statusCode}');
  print('Response Body: ${response.body}');

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    print('Préférences récupérées avec succès.');
    return data;
  } else {
    throw Exception('Erreur lors de la récupération des préférences: ${response.body}');
  }
}

