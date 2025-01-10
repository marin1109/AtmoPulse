// Dart imports
import 'dart:convert';

// Package imports
import 'package:AtmoPulse/types/weather/humidity.dart';
import 'package:AtmoPulse/types/weather/precipitation.dart';
import 'package:AtmoPulse/types/weather/temperature.dart';
import 'package:AtmoPulse/types/weather/uv.dart';
import 'package:AtmoPulse/types/weather/wind_speed.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

// Type imports
import '../types/common/email.dart';
import '../types/common/password.dart';
import '../types/common/fname.dart';
import '../types/common/lname.dart';
import '../types/common/age.dart';
import '../types/common/city.dart';
import '../types/common/region.dart';
import '../types/common/country.dart';

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
      'age': age.value,
      'email': email.toString(),
      'mot_de_passe': motDePasse.toString(),
      'sensibilites': {
        'humidite_min': humidity_min.value,
        'humidite_max': humidity_max.value,
        'precipitations_min': precipitation_min.value,
        'precipitations_max': precipitation_max.value,
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
      'email': email.toString(),
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

Future<void> updateSensibilites(
  Email email, {
  required int humiditeMin,
  required int humiditeMax,
  required int precipitationsMin,
  required int precipitationsMax,
  required int temperatureMin,
  required int temperatureMax,
  required int ventMin,
  required int ventMax,
  required int uv,
}) async {
  final url = Uri.parse('$apiBaseUrl/update_sensibilites_utilisateur');
  final response = await http.post(
    url,
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({
      'email': email.toString(),
      'humidite_min': humiditeMin,
      'humidite_max': humiditeMax,
      'precipitations_min': precipitationsMin,
      'precipitations_max': precipitationsMax,
      'temperature_min': temperatureMin,
      'temperature_max': temperatureMax,
      'vent_min': ventMin,
      'vent_max': ventMax,
      'uv': uv,
    }),
  );

  print('Status Code (updateSensibilites): ${response.statusCode}');
  print('Response Body (updateSensibilites): ${response.body}');

  if (response.statusCode == 200) {
    print('Sensibilités mises à jour avec succès dans la DB.');
  } else {
    throw Exception(
      'Erreur lors de la mise à jour des sensibilités: ${response.body}',
    );
  }
}

// Fonction pour mettre à jour ou ajouter les préférences d'unités
Future<void> updatePreferencesUnit(
  Email email, 
  TemperatureUnit? uniteTemperature,
  WindUnit? uniteVent,
  HumidityUnit? uniteHumidite,
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

// Ajouter une ville favorite
Future<void> addFavoriteCity(String email, String villeUrl, City villeNom, Region villeRegionNom, Country villePaysNom) async {
  final url = Uri.parse('$apiBaseUrl/add_favorite_city');
  final response = await http.post(
    url,
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({
      'email': email,
      'ville_url': villeUrl,
      'ville_nom': villeNom.value,
      'ville_region_nom': villeRegionNom.value,
      'ville_pays_nom': villePaysNom.value,
    }),
  );

  if (response.statusCode == 201) {
    print('Ville favorite ajoutée.');
  } else {
    throw Exception('Erreur add favorite: ${response.body}');
  }
}

// Récupérer les villes favorites
Future<List<Map<String, dynamic>>> getFavoriteCities(String email) async {
  final url = Uri.parse('$apiBaseUrl/get_favorite_cities');
  final response = await http.post(
    url,
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({'email': email}),
  );

  if (response.statusCode == 200) {
    final List<dynamic> data = jsonDecode(response.body);
    return data.map((item) => item as Map<String, dynamic>).toList();
  } else {
    throw Exception('Erreur get favorites: ${response.body}');
  }
}

// Supprimer une ville favorite
Future<void> removeFavoriteCity(String email, String villeUrl) async {
  final url = Uri.parse('$apiBaseUrl/rm_favorite_city');
  final response = await http.delete(
    url,
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({
      'email': email,
      'ville_url': villeUrl,
    }),
  );

  if (response.statusCode == 200) {
    print('Ville favorite supprimée.');
  } else {
    throw Exception('Erreur remove favorite: ${response.body}');
  }
}
