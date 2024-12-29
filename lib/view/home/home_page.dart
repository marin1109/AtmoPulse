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
import '../../services/account_service.dart';

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
        icon: Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
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

  // Cache local des favoris
  List<Map<String, String>> _favorites = []; 

  @override
  void initState() {
    super.initState();
    loadSavedWeatherData();   // récup météo en local
    getWeatherData();         // récup météo en ligne
    _loadFavoritesLocally();  // on charge les favoris depuis SharedPreferences

    // Optionnel : si on veut forcer la synchro dès le démarrage
    // _syncFavoritesFromServerIfLoggedIn();
  }

  //////////////////////////
  /// GESTION DES FAVORIS ///
  //////////////////////////

  // Charger les favoris en local
  Future<void> _loadFavoritesLocally() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? favString = prefs.getString('favorites');
    if (favString != null) {
      List<dynamic> decoded = jsonDecode(favString);
      setState(() {
        _favorites = decoded.map((item) => Map<String, String>.from(item)).toList();
      });
    }
  }

  // Sauvegarder les favoris en local
  Future<void> _saveFavoritesLocally() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String encoded = jsonEncode(_favorites);
    await prefs.setString('favorites', encoded);
  }

  // Charger depuis le serveur si l'utilisateur est connecté
  Future<void> _syncFavoritesFromServerIfLoggedIn() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? storedEmail = prefs.getString('email');
    if (storedEmail != null && storedEmail.isNotEmpty) {
      try {
        final serverFavorites = await getFavoriteCities(storedEmail);
        // Convertir pour stocker dans notre _favorites
        List<Map<String, String>> adapted = serverFavorites.map((fav) {
          // fav = { "id": 12, "ville_url": "Paris" }
          return {
            'id': fav['id'].toString(),
            'url': fav['ville_url'].toString(),
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

  // Ajouter un favori (en local + serveur si connecté)
  Future<void> _addToFavorites(String name, String cityUrl) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? storedEmail = prefs.getString('email');

    // Ajout local
    bool alreadyExists = _favorites.any((item) => item['url'] == cityUrl);
    if (!alreadyExists) {
      setState(() {
        _favorites.add({
          'name': name,
          'url': cityUrl,
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

    // Ajout côté serveur (si connecté)
    if (storedEmail != null && storedEmail.isNotEmpty) {
      try {
        await addFavoriteCity(storedEmail, cityUrl);
        // Si succès, tout est synchro
      } catch (e) {
        print('Erreur côté serveur : $e');
        // Vous pouvez gérer la synchro plus tard si besoin
      }
    }
  }

  // Supprimer un favori (local + serveur si connecté)
  Future<void> _removeFromFavorites(String cityUrl) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? storedEmail = prefs.getString('email');

    // Suppression local
    setState(() {
      _favorites.removeWhere((item) => item['url'] == cityUrl);
    });
    await _saveFavoritesLocally();

    // Suppression côté serveur (si connecté)
    if (storedEmail != null && storedEmail.isNotEmpty) {
      try {
        await removeFavoriteCity(storedEmail, cityUrl);
      } catch (e) {
        print('Erreur côté serveur : $e');
      }
    }
  }

  // Afficher la liste des favoris
  void _showFavoritesDialog() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? storedEmail = prefs.getString('email');
    if (storedEmail == null || storedEmail.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Vous devez être connecté pour accéder à vos favoris.')),
      );
      return;
    }

    // On peut re-synchroniser si on veut toujours avoir la dernière liste
    await _syncFavoritesFromServerIfLoggedIn();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Mes favoris'),
          content: (_favorites.isEmpty)
              ? Text('Vous n\'avez pas encore de favoris.')
              : SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: _favorites.map((fav) {
                      final cityName = fav['name'] ?? fav['url'] ?? 'Inconnu';
                      final cityUrl = fav['url'] ?? '';
                      return ListTile(
                        title: Text(cityName),
                        trailing: IconButton(
                          icon: Icon(Icons.delete),
                          onPressed: () async {
                            Navigator.of(context).pop();
                            await _removeFromFavorites(cityUrl);
                            _showFavoritesDialog(); // Raffraîchir
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
              child: Text('Fermer'),
            ),
          ],
        );
      },
    );
  }

  /////////////////////////////////////////////
  /// Méthodes existantes pour la météo etc. ///
  /////////////////////////////////////////////

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

    final cityName = currentData.location.city.name;
    bool isLoggedIn = await _isUserLoggedIn();
    if (isLoggedIn) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Ajouter aux favoris ?'),
            content: Text('Voulez-vous ajouter $cityName à vos favoris ?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('Non'),
              ),
              ElevatedButton(
                onPressed: () async {
                  Navigator.of(context).pop();
                  await _addToFavorites(cityName, cityUrl);
                },
                child: Text('Oui'),
              ),
            ],
          );
        },
      );
    }
  }

  Future<bool> _isUserLoggedIn() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? storedEmail = prefs.getString('email');
    return (storedEmail != null && storedEmail.isNotEmpty);
  }

  void _checkLoginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? storedEmail = prefs.getString('email');

    if (storedEmail != null && storedEmail.isNotEmpty) {
      Navigator.push(context, MaterialPageRoute(builder: (context) => UserPage()));
    } else {
      Navigator.push(context, MaterialPageRoute(builder: (context) => LSPage()));
    }
  }

  // Récupération des données météo (existant)
  Future<void> getWeatherData() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.deniedForever) {
          print('Les permissions de localisation sont refusées de façon permanente.');
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
      final Map<String, dynamic> decodedForecastJson = jsonDecode(forecastString);

      final locationObj = Location.fromJson(decodedJson['location']);
      final currentObj = CurrentWeather.fromJson(decodedJson['current']);
      final weeklyForecastObj = ForecastWeather.fromJson(decodedForecastJson['forecast']);

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

  ///////////////////////////////
  /// Build de l'interface UI ///
  ///////////////////////////////

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
              IconButton(
                icon: Icon(Icons.star),
                onPressed: () {
                  _showFavoritesDialog();
                },
              ),
              if (_isCustomCity)
                IconButton(
                  icon: Icon(Icons.home),
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
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) => PreferencesPage()));
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
              child: (weatherData != null)
                  ? ListView(
                      children: [
                        const SizedBox(height: 80),
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
                              child:_buildWeatherInfo(
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
                              final DateTime date = DateTime.parse(day.date);
                              final String dayOfWeek = _getJourSemaine(date);

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
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                                              userPreferences.preferredTemperatureUnit,
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
    } catch (e) {
      return input;
    }
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

  String _getJourSemaine(DateTime date) {
    int dayOfWeek = date.weekday; 
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
