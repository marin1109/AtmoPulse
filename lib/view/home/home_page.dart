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
import '../../types/villeSugg_type.dart';

class CitySearchDelegate extends SearchDelegate<String> {
  final WeatherService weatherService;

  CitySearchDelegate({required this.weatherService});

  @override
  Widget buildSuggestions(BuildContext context) {
    if (query.isEmpty) {
      return Center(child: Text("Tapez le nom d'une ville..."));
    }
    
    // FutureBuilder pour charger les suggestions via l’API
    return FutureBuilder<List<VS>>(
      future: weatherService.fetchCitySuggestions(query),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(child: CircularProgressIndicator());
        }

        final suggestions = snapshot.data!;
        if (suggestions.isEmpty) {
          return Center(child: Text("Aucune ville trouvée pour '$query'"));
        }

        return ListView.builder(
          itemCount: suggestions.length,
          itemBuilder: (context, index) {
            final city = suggestions[index];
            return ListTile(
              title: Text(city.city.name),
              subtitle: Text('${city.region.name}, ${city.country.name}'),
              onTap: () {
                close(
                  context,
                  city.url,
                );
              },
            );
          },
        );
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      close(context, query);
    });
    return Container();
  }

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      // Bouton pour effacer la saisie
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    // Bouton de retour (flèche) pour fermer la recherche
    return IconButton(
      icon: Icon(Icons.arrow_back),
      onPressed: () {
        close(context, '');
      },
    );
  }
}

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

  bool _isCustomCity = false;

  Future<void> _onCitySelected(String cityUrl) async {
    final currentData =
        await weatherService.fetchCurrentWeatherByUrl(cityUrl);
    final forecastData =
        await weatherService.fetchWeeklyForecastByUrl(cityUrl);

    if (currentData == null || forecastData == null) {
      print('Données météo introuvables pour $cityUrl.');
      return;
    }

    setState(() {
      location = currentData.location;
      weatherData = currentData.current;
      weeklyForecast = forecastData.forecast;
      _isCustomCity = true; // On a bien une ville personnalisée
    });
  }

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

  // Récupération des données météo
  Future<void> getWeatherData() async {
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

        final sharedPrefs = await SharedPreferences.getInstance();
      
        final Map<String, dynamic> weatherMap = {
          'location': currentData.location.toJson(),
          'current': currentData.current.toJson(),
        };

        final Map<String, dynamic> forecastMap = {
          'location': forecastData.location.toJson(),
          'current': forecastData.current.toJson(),
          'forecast': forecastData.forecast?.toJson(),
        };

        final weatherJson = jsonEncode(weatherMap);
        final forecastJson = jsonEncode(forecastMap);

        await sharedPrefs.setString('currentWeather', weatherJson);
        await sharedPrefs.setString('forecastWeather', forecastJson);
      }
    } catch (e) {
      print('Erreur inattendue : $e');
    }
  }

  Future<void> loadSavedWeatherData() async {
    final prefs = await SharedPreferences.getInstance();
    final String? weatherString = prefs.getString('currentWeather');
    final String? forecastString = prefs.getString('forecastWeather');

    if (weatherString != null && forecastString != null) {
      final Map<String, dynamic> decodedJson = jsonDecode(weatherString);
      final Map<String, dynamic> decodedForecastJson =
          jsonDecode(forecastString);

      final locationObj = Location.fromJson(decodedJson['location']);
      final currentObj = CurrentWeather.fromJson(decodedJson['current']);
      final weeklyForecastObj =
          ForecastWeather.fromJson(decodedForecastJson['forecast']);

      setState(() {
        location = locationObj;
        weatherData = currentObj;
        weeklyForecast = weeklyForecastObj;
      });

      print('Données météo chargées depuis les SharedPreferences.');
    } else {
      print('Aucune donnée météo sauvegardée.');
    }
  }

  @override
  void initState() {
    super.initState();
    loadSavedWeatherData();
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
            title: const Text(
              'AtmoPulse',
              style: TextStyle(
                fontFamily: 'Montserrat',
                fontWeight: FontWeight.bold,
              ),
            ),
            actions: [
              // Icône de recherche (existant)
              IconButton(
                icon: Icon(Icons.search),
                onPressed: () async {
                  final cityUrl = await showSearch<String>(
                    context: context,
                    delegate: CitySearchDelegate(weatherService: weatherService),
                  );
                  if (cityUrl != null && cityUrl.isNotEmpty) {
                    await _onCitySelected(cityUrl);
                  }
                },
              ),

              // Bouton "Retour à la météo par défaut" (affiché seulement si on a choisi une ville personnalisée)
              if (_isCustomCity)
                IconButton(
                  icon: Icon(Icons.home),
                  onPressed: () async {
                    // Recharger la météo par défaut via la géolocalisation
                    await getWeatherData();
                    setState(() {
                      _isCustomCity = false; 
                    });
                  },
                ),
              PopupMenuButton<String>(
                icon: const Icon(Icons.menu),
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
                  const PopupMenuItem<String>(
                      value: 'compte', child: Text('Compte')),
                  const PopupMenuItem<String>(
                      value: 'preferences', child: Text('Préférences')),
                  const PopupMenuItem<String>(
                      value: 'a_propos', child: Text('À propos')),
                  const PopupMenuItem<String>(
                      value: 'contact', child: Text('Contact')),
                ],
              ),
            ],
            backgroundColor: Colors.transparent,
            elevation: 0,
          ),
          extendBodyBehindAppBar: true,
          
          body: RefreshIndicator(
            onRefresh: getWeatherData,
            child: Container(
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

              // On utilise une ListView pour pouvoir scroller
              child: (weatherData != null)
                  ? ListView(
                      children: [
                        const SizedBox(height: 80),
                        // Affichage de la localisation
                        Center(
                          child: Text(
                            '$location',
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Montserrat',
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Icône météo
                        Center(
                          child: Image.network(
                            'https:${weatherData!.condition.icon}',
                            width: 100,
                          ),
                        ),
                        const SizedBox(height: 10),

                        // Température
                        Center(
                          child: Text(
                            Temperature.loadTemperatureText(
                              weatherData!.temp,
                              userPreferences.preferredTemperatureUnit,
                            ),
                            style: const TextStyle(
                              fontSize: 60,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Montserrat',
                              color: Colors.white,
                            ),
                          ),
                        ),
                        // Condition météo
                        Center(
                          child: Text(
                            decodeUtf8(weatherData!.condition.text),
                            style: const TextStyle(
                              fontSize: 24,
                              fontFamily: 'Montserrat',
                              color: Colors.white70,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Infos vent / humidité / précipitations
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildWeatherInfo(
                              icon: Icons.air,
                              value: WindSpeed.loadWindText(
                                weatherData!.wind,
                                userPreferences.preferredWindUnit,
                              ),
                              label: 'Vent',
                            ),
                            _buildWeatherInfo(
                              icon: Icons.water_drop,
                              value: Humidity.loadHumidityText(
                                weatherData!.humidity,
                                userPreferences.preferredHumidityUnit,
                              ),
                              label: 'Humidité',
                            ),
                            _buildWeatherInfo(
                              icon: Icons.opacity,
                              value: Precipitation.loadPrecipitationText(
                                weatherData!.precipitation,
                                userPreferences.preferredPrecipitationUnit,
                              ),
                              label: 'Précip.',
                            ),
                          ],
                        ),
                        const SizedBox(height: 30),

                        // Titre "Prévisions Hebdomadaires"
                        const Center(
                          child: Text(
                            'Prévisions Hebdomadaires',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Montserrat',
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),

                        // Liste des prévisions
                        if (weeklyForecast?.forecastDays != null)
                          ListView.builder(
                            // nested ListView, on fixe shrinkWrap et physics
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: weeklyForecast!.forecastDays.length,
                            itemBuilder: (context, index) {
                              final day = weeklyForecast!.forecastDays[index];
                              final DateTime date = DateTime.parse(day.date);
                              final String dayOfWeek = getJourSemaine(date);

                              return Card(
                                color: Colors.white.withOpacity(0.2),
                                margin: const EdgeInsets.symmetric(
                                  vertical: 8,
                                  horizontal: 20,
                                ),
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
                                          style: const TextStyle(
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
                                      const SizedBox(width: 10),
                                      Text(
                                        Temperature.loadTemperatureText(
                                          day.avgTemp,
                                          userPreferences
                                              .preferredTemperatureUnit,
                                        ),
                                        style: const TextStyle(
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
                      ],
                    )
                  : const Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildWeatherInfo({
    required IconData icon,
    required String value,
    required String label,
  }) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 28),
        const SizedBox(height: 5),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontFamily: 'Montserrat',
            color: Colors.white,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontFamily: 'Montserrat',
            color: Colors.white70,
          ),
        ),
      ],
    );
  }
}
