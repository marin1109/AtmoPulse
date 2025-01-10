import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:convert';

import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../services/location_service.dart';
import '../../services/weather_service.dart';
import '../../services/account_service.dart';

import '../../utils/user_preferences.dart';

import '../account/log_in_sign_up_page.dart';
import '../account/user_page.dart';
import '../settings/preferences_page.dart';

import '../dialogs/contact_dialog.dart';
import '../dialogs/about_dialog.dart' as custom;

import '../../models/weather_data.dart';
import '../../types/weather/temperature.dart';
import '../../types/weather/wind_speed.dart';
import '../../types/weather/precipitation.dart';
import '../../types/weather/humidity.dart';
import '../../types/common/vs.dart';
import '../../types/common/city.dart';
import '../../types/common/region.dart';
import '../../types/common/country.dart';
import '../../types/weather/forecast_weather.dart';
import '../../types/weather/current_weather.dart';

class CitySearchDelegate extends SearchDelegate<String> {
  final WeatherService weatherService;
  CitySearchDelegate({required this.weatherService});

  @override
  Widget buildSuggestions(BuildContext context) {
    if (query.isEmpty) {
      return const Center(child: Text("Tapez le nom d'une ville..."));
    }
    return FutureBuilder<List<VS>>(
      future: weatherService.fetchCitySuggestions(query),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
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
              title: Text(city.city.value),
              subtitle: Text('${city.region.value}, ${city.country.value}'),
              onTap: () {
                close(context, city.url);
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
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, '');
      },
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final LocationService locationService = LocationService();
  final WeatherService weatherService = WeatherService();

  Location? location;
  CurrentWeather? weatherData;
  ForecastWeather? weeklyForecast;
  bool _isCustomCity = false;

  // Cache local des favoris
  List<Map<String, String>> _favorites = [];

  @override
  void initState() {
    super.initState();
    loadSavedWeatherData();
    getWeatherData();
    _loadFavoritesLocally();
  }

  // ===================
  // GESTION DES FAVORIS
  // ===================
  Future<void> _loadFavoritesLocally() async {
    // A vous de voir si vous voulez stocker dans userPrefs ou dans SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    final String? favString = prefs.getString('favorites');
    if (favString != null) {
      final List<dynamic> decoded = jsonDecode(favString);
      setState(() {
        _favorites =
            decoded.map((item) => Map<String, String>.from(item)).toList();
      });
    }
  }

  Future<void> _saveFavoritesLocally() async {
    final prefs = await SharedPreferences.getInstance();
    final String encoded = jsonEncode(_favorites);
    await prefs.setString('favorites', encoded);
  }

  Future<void> _syncFavoritesFromServerIfLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    final String? storedEmail = prefs.getString('email');
    if (storedEmail != null && storedEmail.isNotEmpty) {
      try {
        final serverFavorites = await getFavoriteCities(storedEmail);
        final adapted = serverFavorites.map((fav) {
          return {
            'id': fav['id'].toString(),
            'url': fav['ville_url'].toString(),
            'name': fav['ville_nom']?.toString() ?? 'Inconnu',
            'region': fav['ville_region_nom']?.toString() ?? 'Inconnue',
            'country': fav['ville_pays_nom']?.toString() ?? 'Inconnu',
          };
        }).toList();
        setState(() {
          _favorites = adapted;
        });
        await _saveFavoritesLocally();
      } catch (e) {
        print('Erreur chargement favoris serveur : $e');
      }
    }
  }

  Future<void> _addToFavorites(City name, String cityUrl, Region villeRegionNom,
      Country villePaysNom) async {
    final prefs = await SharedPreferences.getInstance();
    final String? storedEmail = prefs.getString('email');

    final bool alreadyExists = _favorites.any((item) => item['url'] == cityUrl);
    if (!alreadyExists) {
      setState(() {
        _favorites.add({
          'name': name.value,
          'url': cityUrl,
          'region': villeRegionNom.value,
          'country': villePaysNom.value,
        });
      });
      await _saveFavoritesLocally();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$name a été ajouté(e) aux favoris !')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$name est déjà dans vos favoris.')),
      );
    }
    // Envoi au serveur si loggedIn
    if (storedEmail != null && storedEmail.isNotEmpty) {
      try {
        await addFavoriteCity(
            storedEmail, cityUrl, name, villeRegionNom, villePaysNom);
      } catch (e) {
        print('Erreur côté serveur : $e');
      }
    }
  }

  Future<void> _removeFromFavorites(String cityUrl) async {
    final prefs = await SharedPreferences.getInstance();
    final String? storedEmail = prefs.getString('email');

    setState(() {
      _favorites.removeWhere((item) => item['url'] == cityUrl);
    });
    await _saveFavoritesLocally();

    if (storedEmail != null && storedEmail.isNotEmpty) {
      try {
        await removeFavoriteCity(storedEmail, cityUrl);
      } catch (e) {
        print('Erreur côté serveur : $e');
      }
    }
  }

  void _showFavoritesDialog() async {
    final prefs = await SharedPreferences.getInstance();
    final String? storedEmail = prefs.getString('email');
    if (storedEmail == null || storedEmail.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content:
                Text('Vous devez être connecté pour accéder à vos favoris.')),
      );
      return;
    }
    await _syncFavoritesFromServerIfLoggedIn();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Mes favoris'),
          content: (_favorites.isEmpty)
              ? const Text('Vous n\'avez pas encore de favoris.')
              : SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: _favorites.map((fav) {
                      final cityUrl = fav['url'] ?? '';
                      final cityName = fav['name'] ?? 'Inconnu';
                      final regionName = fav['region'] ?? 'Inconnue';
                      final countryName = fav['country'] ?? 'Inconnu';

                      return ListTile(
                        title: Text(cityName),
                        subtitle: Text('$regionName, $countryName'),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () async {
                            Navigator.of(context).pop();
                            await _removeFromFavorites(cityUrl);
                            _showFavoritesDialog();
                          },
                        ),
                        onTap: () async {
                          Navigator.of(context).pop();
                          await _onCitySelected(cityUrl);
                        },
                      );
                    }).toList(),
                  ),
                ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Fermer'),
            ),
          ],
        );
      },
    );
  }

  // ===================
  // Méthodes Météo
  // ===================
  Future<void> _onCitySelected(String cityUrl) async {
    final currentData = await weatherService.fetchCurrentWeatherByUrl(cityUrl);
    final forecastData = await weatherService.fetchWeeklyForecastByUrl(cityUrl);
    if (currentData == null || forecastData == null) {
      print('Données météo introuvables pour $cityUrl.');
      return;
    }
    setState(() {
      location = currentData.location;
      weatherData = currentData.current;
      weeklyForecast = forecastData.forecast;
      _isCustomCity = true;
    });

    final city = currentData.location.city;
    final cityRegion = currentData.location.region;
    final cityCountry = currentData.location.country;
    final bool isLoggedIn = await _isUserLoggedIn();
    if (isLoggedIn) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Ajouter aux favoris ?'),
            content: Text('Voulez-vous ajouter $city à vos favoris ?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Non'),
              ),
              ElevatedButton(
                onPressed: () async {
                  Navigator.of(context).pop();
                  await _addToFavorites(city, cityUrl, cityRegion, cityCountry);
                },
                child: const Text('Oui'),
              ),
            ],
          );
        },
      );
    }
  }

  Future<bool> _isUserLoggedIn() async {
    // Vérification simple (depuis prefs)
    final prefs = await SharedPreferences.getInstance();
    final String? storedEmail = prefs.getString('email');
    return (storedEmail != null && storedEmail.isNotEmpty);
  }

  void _checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final String? storedEmail = prefs.getString('email');
    if (storedEmail != null && storedEmail.isNotEmpty) {
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => const UserPage()));
    } else {
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => const LSPage()));
    }
  }

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
        final position = await locationService.getUserLocation();
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
        // Sauvegarde en local
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
        await sharedPrefs.setString('currentWeather', jsonEncode(weatherMap));
        await sharedPrefs.setString('forecastWeather', jsonEncode(forecastMap));
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
      final decodedJson = jsonDecode(weatherString) as Map<String, dynamic>;
      final decodedForecastJson =
          jsonDecode(forecastString) as Map<String, dynamic>;
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
  Widget build(BuildContext context) {
    return Consumer<UserPreferences>(
      builder: (context, userPreferences, child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text(
              'AtmoPulse',
              style: TextStyle(
                  fontFamily: 'Montserrat', fontWeight: FontWeight.bold),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.search),
                onPressed: () async {
                  final cityUrl = await showSearch<String>(
                    context: context,
                    delegate:
                        CitySearchDelegate(weatherService: weatherService),
                  );
                  if (cityUrl != null && cityUrl.isNotEmpty) {
                    await _onCitySelected(cityUrl);
                  }
                },
              ),
              IconButton(
                icon: const Icon(Icons.star),
                onPressed: () => _showFavoritesDialog(),
              ),
              if (_isCustomCity)
                IconButton(
                  icon: const Icon(Icons.home),
                  onPressed: () async {
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
                              builder: (context) => const PreferencesPage()));
                      break;
                    case 'contact':
                      showDialog(
                        context: context,
                        builder: (BuildContext context) =>
                            const ContactDialog(),
                      );
                      break;
                    case 'a_propos':
                      showDialog(
                        context: context,
                        builder: (BuildContext context) =>
                            const custom.AboutDialog(),
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
                  colors: [Colors.blue.shade700, Colors.blue.shade200],
                ),
              ),
              child: (weatherData != null)
                  ? ListView(
                      children: [
                        const SizedBox(height: 80),
                        Center(
                          child: Text(
                            '$location',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Montserrat',
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Center(
                          child: Image.network(
                            'https:${weatherData!.condition.icon}',
                            width: 100,
                          ),
                        ),
                        const SizedBox(height: 10),
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
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Expanded(
                              child: _buildWeatherInfo(
                                icon: Icons.air,
                                value: WindSpeed.loadWindText(
                                  weatherData!.wind,
                                  userPreferences.preferredWindUnit,
                                ),
                                label: 'Vent',
                              ),
                            ),
                            Expanded(
                              child: _buildWeatherInfo(
                                icon: Icons.water,
                                value: Humidity.loadHumidityText(
                                  weatherData!.humidity,
                                  userPreferences.preferredHumidityUnit,
                                ),
                                label: 'Humidité',
                              ),
                            ),
                            Expanded(
                              child: _buildWeatherInfo(
                                icon: Icons.opacity,
                                value: Precipitation.loadPrecipitationText(
                                  weatherData!.precipitation,
                                  userPreferences.preferredPrecipitationUnit,
                                ),
                                label: 'Précip.',
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 30),
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
                        if (weeklyForecast?.forecastDays != null)
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: weeklyForecast!.forecastDays.length,
                            itemBuilder: (context, index) {
                              final day = weeklyForecast!.forecastDays[index];
                              final date = DateTime.parse(day.date);
                              final dayOfWeek = _getJourSemaine(date);

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
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
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
                                      Row(
                                        children: [
                                          Image.network(
                                            'https:${day.condition.icon}',
                                            width: 40,
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            Temperature.loadTemperatureText(
                                              day.avgTemp,
                                              userPreferences
                                                  .preferredTemperatureUnit,
                                            ),
                                            style: const TextStyle(
                                              fontSize: 18,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ],
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

  String decodeUtf8(String input) {
    try {
      return utf8.decode(input.runes.toList());
    } catch (_) {
      return input;
    }
  }

  static const List<String> joursSemaine = [
    "Lundi",
    "Mardi",
    "Mercredi",
    "Jeudi",
    "Vendredi",
    "Samedi",
    "Dimanche"
  ];

  String _getJourSemaine(DateTime date) {
    final dayOfWeek = date.weekday;
    return joursSemaine[dayOfWeek - 1];
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
