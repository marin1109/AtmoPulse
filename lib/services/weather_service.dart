// Dart imports
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';

// Package imports
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';

// Types imports
import '../models/weather_data.dart';
import '../types/common/vs.dart';

// Classe pour gérer les services météo
class WeatherService {
  final String apiKey = dotenv.env['WHEATHER_API_KEY']!;
  String apiBaseUrl = 'https://api.weatherapi.com/v1';

  // Fonction pour récupérer les données météo actuelles
  Future<WeatherData?> fetchCurrentWeather(Position position) async {
    final latitude = position.latitude;
    final longitude = position.longitude;

    final url = Uri.parse('$apiBaseUrl/current.json?key=$apiKey&q=$latitude,$longitude&lang=fr');

    final response = await http.get(url);

    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      WeatherData currentWeather = WeatherData.fromJson(data);
      return currentWeather;
    } else {
      print('Erreur lors de la récupération des données météo actuelles');
      return null;
    }
  }

  // Fonction pour récupérer les prévisions météo
  Future<WeatherData?> fetchWeeklyForecast(Position position) async {
    final latitude = position.latitude;
    final longitude = position.longitude;

    final url = Uri.parse(
        'https://api.weatherapi.com/v1/forecast.json?key=$apiKey&q=$latitude,$longitude&days=7&lang=fr');

    final response = await http.get(url);

    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      WeatherData forecastWeather = WeatherData.fromJson(data);
      return forecastWeather;
    } else {
      print('Erreur lors de la récupération des prévisions météo');
      return null;
    }
  }

  // Fonction pour récupérer les données météo actuelles à partir d'une ville
  Future<WeatherData?> fetchCurrentWeatherByUrl(String cityUrl) async {
    final url = Uri.parse('$apiBaseUrl/current.json?key=$apiKey&q=$cityUrl&lang=fr');

    final response = await http.get(url);

    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      WeatherData currentWeather = WeatherData.fromJson(data);
      return currentWeather;
    } else {
      print('Erreur lors de la récupération des données météo actuelles');
      return null;
    }
  }

  // Fonction pour récupérer les prévisions météo à partir d'une ville
  Future<WeatherData?> fetchWeeklyForecastByUrl(String cityUrl) async {
    final url = Uri.parse('$apiBaseUrl/forecast.json?key=$apiKey&q=$cityUrl&days=7&lang=fr');

    final response = await http.get(url);

    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      WeatherData forecastWeather = WeatherData.fromJson(data);
      return forecastWeather;
    } else {
      print('Erreur lors de la récupération des prévisions météo');
      return null;
    }
  }

  Future<List<VS>> fetchCitySuggestions(String query) async {
    final url = Uri.parse('$apiBaseUrl/search.json?key=$apiKey&q=$query&lang=fr');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((item) => VS.fromValues( 
                                    item['name'], 
                                    item['region'], 
                                    item['country'], 
                                    item['url'])).toList();
    } else {
      return [];
    }
  }

}
