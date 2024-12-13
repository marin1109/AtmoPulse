// Flutter/Dart imports
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:convert';

// Package imports
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Service imports
import '../../services/location_service.dart';
import '../../services/weather_service.dart';

// Utility imports
import '../../utils/user_preferences.dart';

// Page imports
import '../account/LogInSignUp_page.dart';
import '../account/user_page.dart';
import '../settings/preferences_page.dart';

// Dialogue imports
import '../dialogs/contact_dialog.dart';
import '../dialogs/about_dialog.dart' as custom;

// Type imports
import '../../types/weather_type.dart';
import '../../types/temperature_type.dart';
import '../../types/wind_type.dart';
import '../../types/precipitation_type.dart';
import '../../types/humidity_type.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final LocationService locationService = LocationService();
  final WeatherService weatherService = WeatherService();

  Location? location;
  CurrentWeather? weatherData;
  ForecastWeather? weeklyForecast;

  // Vérifie si l'utilisateur est déjà connecté
  void _checkLoginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? storedEmail = prefs.getString('email');

    if (storedEmail != null && storedEmail.isNotEmpty) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => UserPage()),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => LSPage()),
      );
    }
  }

  void getWeatherData() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.deniedForever) {
          print(
              'Les permissions de localisation sont refusées de façon permanente.');
          return;
        }
      }

      if (permission == LocationPermission.always ||
          permission == LocationPermission.whileInUse) {
        Position position = await locationService.getUserLocation();
        final currentData = await weatherService.fetchCurrentWeather(position);
        final forecastData = await weatherService.fetchWeeklyForecast(position);

        if (currentData == null || forecastData == null) {
          print('Données météo non disponibles.');
          return;
        }

        setState(() {
          location = currentData.location;
          weatherData = currentData.current;
          weeklyForecast = forecastData.forecast;
        });
      }
    } catch (e) {
      print('Erreur inattendue : $e');
    }
  }

  @override
  void initState() {
    super.initState();
    getWeatherData();
  }

  // Liste des jours de la semaine en français
  static const List<String> joursSemaine = [
    "Lundi",
    "Mardi",
    "Mercredi",
    "Jeudi",
    "Vendredi",
    "Samedi",
    "Dimanche"
  ];

  // Fonction pour obtenir le jour de la semaine à partir d'une date
  String getJourSemaine(DateTime date) {
    int dayOfWeek = date.weekday;
    return joursSemaine[dayOfWeek - 1];
  }

  String decodeUtf8(String input) {
    try {
      return utf8.decode(input.runes.toList());
    } catch (e) {
      return input;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UserPreferences>(
      builder: (context, userPreferences, child) {
      
        return Scaffold(
          appBar: AppBar(
            title: Text(
              'AtmoPulse',
              style: TextStyle(
                fontFamily: 'Montserrat',
                fontWeight: FontWeight.bold,
              ),
            ),
            actions: [
              PopupMenuButton<String>(
                icon: Icon(Icons.menu),
                onSelected: (String value) {
                  switch (value) {
                    case 'compte':
                      _checkLoginStatus();
                      break;
                    case 'preferences':
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => PreferencesPage()));
                      break;
                    case 'contact':
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return const ContactDialog();
                        },
                      );
                      break;
                    case 'a_propos':
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return const custom.AboutDialog();
                        },
                      );
                      break;
                  }
                },
                itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                  PopupMenuItem<String>(value: 'compte', child: Text('Compte')),
                  PopupMenuItem<String>(
                      value: 'preferences', child: Text('Préférences')),
                  PopupMenuItem<String>(
                      value: 'a_propos', child: Text('À propos')),
                  PopupMenuItem<String>(
                      value: 'contact', child: Text('Contact')),
                ],
              ),
            ],
            backgroundColor: Colors.transparent,
            elevation: 0,
          ),
          extendBodyBehindAppBar: true,
          body: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.blue.shade700,
                  Colors.blue.shade200,
                ],
              ),
            ),
            child: Center(
              child: weatherData != null
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(height: 80),
                        Text(
                          '$location',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Montserrat',
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 20),
                        Image.network(
                          'https:${weatherData!.condition.icon}',
                          width: 100,
                        ),
                        SizedBox(height: 10),
                        Text(
                          Temperature.loadTemperatureText(weatherData!.temp, userPreferences.preferredTemperatureUnit),
                          style: TextStyle(
                            fontSize: 60,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Montserrat',
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          decodeUtf8(weatherData!.condition.text),
                          style: TextStyle(
                            fontSize: 24,
                            fontFamily: 'Montserrat',
                            color: Colors.white70,
                          ),
                        ),
                        SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildWeatherInfo(
                              icon: Icons.air,
                              value: WindSpeed.loadWindText(weatherData!.wind, userPreferences.preferredWindUnit),
                              label: 'Vent',
                            ),
                            _buildWeatherInfo(
                              icon: Icons.water_drop,
                              value: Humidity.loadHumidityText(weatherData!.humidity, userPreferences.preferredHumidityUnit),
                              label: 'Humidité',
                            ),
                            _buildWeatherInfo(
                              icon: Icons.opacity,
                              value: Precipitation.loadPrecipitationText(weatherData!.precipitation, userPreferences.preferredPrecipitationUnit),
                              label: 'Précip.',
                            ),
                          ],
                        ),
                        SizedBox(height: 30),
                        Text(
                          'Prévisions Hebdomadaires',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Montserrat',
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 10),
                        Expanded(
                          child: ListView.builder(
                            scrollDirection: Axis.vertical,
                            itemCount: weeklyForecast?.forecastDays.length ?? 0,
                            itemBuilder: (context, index) {
                              final day = weeklyForecast!.forecastDays[index];
                              final DateTime date = DateTime.parse(day.date);
                              final String dayOfWeek = getJourSemaine(date);

                              return Card(
                                color: Colors.white.withOpacity(0.2),
                                margin: EdgeInsets.symmetric(
                                    vertical: 8, horizontal: 20),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(15.0),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          dayOfWeek,
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontFamily: 'Montserrat',
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                      Image.network(
                                        'https:${day.condition.icon}',
                                        width: 40,
                                      ),
                                      SizedBox(width: 10),
                                      Text(
                                        Temperature.loadTemperatureText(day.avgTemp, userPreferences.preferredTemperatureUnit),
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontFamily: 'Montserrat',
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        )
                      ],
                    )
                  : CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildWeatherInfo(
      {required IconData icon, required String value, required String label}) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 28),
        SizedBox(height: 5),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontFamily: 'Montserrat',
            color: Colors.white,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontFamily: 'Montserrat',
            color: Colors.white70,
          ),
        ),
      ],
    );
  }
}
