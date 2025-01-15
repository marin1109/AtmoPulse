import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:geolocator/geolocator.dart';

import '../../../services/location_service.dart';
import '../../../services/weather_service.dart';
import '../../../services/account_service.dart';
import '../../../models/weather_data.dart';
import '../../../types/weather/current_weather.dart';
import '../../../types/weather/forecast_weather.dart';
import '../../../types/common/city.dart';
import '../../../types/common/region.dart';
import '../../../types/common/country.dart';
import '../account/login_signup/log_in_sign_up_page.dart';
import '../account/user_page/user_page.dart';

/// Cette classe gère la logique et l'état de HomePage.
/// Elle peut être un mixin sur State<HomePage>, ou un ChangeNotifier si vous préférez un état géré par Provider.
mixin HomePageController<T extends StatefulWidget> on State<T> {
  final LocationService locationService = LocationService();
  final WeatherService weatherService = WeatherService();

  Location? location;
  CurrentWeather? weatherData;
  ForecastWeather? weeklyForecast;
  bool isCustomCity = false;

  List<Map<String, String>> favorites = [];

  // ===================
  // Méthodes pour SharedPreferences
  // ===================
  Future<SharedPreferences> get prefs async => SharedPreferences.getInstance();

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
    final p = await prefs;
    final String? favString = p.getString('favorites');
    if (favString != null) {
      final List<dynamic> decoded = jsonDecode(favString);
      setState(() {
        favorites = decoded.map((item) => Map<String, String>.from(item)).toList();
      });
    }
  }

  Future<void> _saveFavoritesLocally() async {
    final p = await prefs;
    final String encoded = jsonEncode(favorites);
    await p.setString('favorites', encoded);
  }

  Future<void> _syncFavoritesFromServerIfLoggedIn() async {
    final email = (await prefs).getString('email');

    if (email != null && email.isNotEmpty) {
      try {
        final serverFavorites = await getFavoriteCities(email);
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
          favorites = adapted;
        });
        await _saveFavoritesLocally();
      } catch (e) {
        debugPrint('Erreur chargement favoris serveur : $e');
      }
    }
  }

  Future<void> addToFavorites(
      BuildContext context,
      City name, 
      String cityUrl, 
      Region villeRegionNom, 
      Country villePaysNom
  ) async {
    final email = (await prefs).getString('email');
    final bool alreadyExists = favorites.any((item) => item['url'] == cityUrl);

    if (!alreadyExists) {
      setState(() {
        favorites.add({
          'name': name.value,
          'url': cityUrl,
          'region': villeRegionNom.value,
          'country': villePaysNom.value,
        });
      });
      await _saveFavoritesLocally();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${name.value} a été ajouté(e) aux favoris !')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${name.value} est déjà dans vos favoris.')),
      );
    }

    // Envoi au serveur si connecté
    if (email != null && email.isNotEmpty) {
      try {
        await addFavoriteCity(email, cityUrl, name, villeRegionNom, villePaysNom);
      } catch (e) {
        debugPrint('Erreur côté serveur : $e');
      }
    }
  }

  Future<void> removeFromFavorites(BuildContext context, String cityUrl) async {
    final email = (await prefs).getString('email');
    setState(() {
      favorites.removeWhere((item) => item['url'] == cityUrl);
    });
    await _saveFavoritesLocally();

    if (email != null && email.isNotEmpty) {
      try {
        await removeFavoriteCity(email, cityUrl);
      } catch (e) {
        debugPrint('Erreur côté serveur : $e');
      }
    }
  }

  Future<void> showFavoritesDialog(BuildContext context) async {
    final email = (await prefs).getString('email');
    if (email == null || email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vous devez être connecté pour accéder à vos favoris.'),
        ),
      );
      return;
    }
    await _syncFavoritesFromServerIfLoggedIn();

    // Ici, on peut soit construire le Dialog directement, soit l’extraire
    // dans un widget séparé (ex: favorites_dialog.dart).
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Mes favoris'),
          content: (favorites.isEmpty)
              ? const Text('Vous n\'avez pas encore de favoris.')
              : SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: favorites.map((fav) {
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
                            Navigator.of(context).pop(); // Ferme le dialog
                            await removeFromFavorites(context, cityUrl);
                            showFavoritesDialog(context); // Pour recharger le dialog
                          },
                        ),
                        onTap: () async {
                          Navigator.of(context).pop();
                          await onCitySelected(cityUrl);
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
  Future<void> onCitySelected(String cityUrl) async {
    final currentData = await weatherService.fetchCurrentWeatherByUrl(cityUrl);
    final forecastData = await weatherService.fetchWeeklyForecastByUrl(cityUrl);
    if (currentData == null || forecastData == null) {
      debugPrint('Données météo introuvables pour $cityUrl.');
      return;
    }
    setState(() {
      location = currentData.location;
      weatherData = currentData.current;
      weeklyForecast = forecastData.forecast;
      isCustomCity = true;
    });

    final city = currentData.location.city;
    final cityRegion = currentData.location.region;
    final cityCountry = currentData.location.country;
    if (await isUserLoggedIn()) {
      // Propose d'ajouter aux favoris
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Ajouter aux favoris ?'),
            content: Text('Voulez-vous ajouter ${city.value} à vos favoris ?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Non'),
              ),
              ElevatedButton(
                onPressed: () async {
                  Navigator.of(context).pop();
                  await addToFavorites(context, city, cityUrl, cityRegion, cityCountry);
                },
                child: const Text('Oui'),
              ),
            ],
          );
        },
      );
    }
  }

  Future<bool> isUserLoggedIn() async {
    final email = (await prefs).getString('email');
    return (email != null && email.isNotEmpty);
  }

  void checkLoginStatus(BuildContext context) async {
    if (await isUserLoggedIn()) {
      Navigator.push(context, MaterialPageRoute(builder: (context) => const UserPage()));
    } else {
      Navigator.push(context, MaterialPageRoute(builder: (context) => const LSPage()));
    }
  }

  Future<void> getWeatherData() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.deniedForever) {
          debugPrint('Les permissions de localisation sont refusées de façon permanente.');
          return;
        }
      }
      if (permission == LocationPermission.always ||
          permission == LocationPermission.whileInUse) {
        final position = await locationService.getUserLocation();
        final currentData = await weatherService.fetchCurrentWeather(position);
        final forecastData = await weatherService.fetchWeeklyForecast(position);
        if (currentData == null || forecastData == null) {
          debugPrint('Données météo non disponibles.');
          return;
        }
        setState(() {
          location = currentData.location;
          weatherData = currentData.current;
          weeklyForecast = forecastData.forecast;
        });
        // Sauvegarde en local
        final p = await prefs;
        final Map<String, dynamic> weatherMap = {
          'location': currentData.location.toJson(),
          'current': currentData.current.toJson(),
        };
        final Map<String, dynamic> forecastMap = {
          'location': forecastData.location.toJson(),
          'current': forecastData.current.toJson(),
          'forecast': forecastData.forecast?.toJson(),
        };
        await p.setString('currentWeather', jsonEncode(weatherMap));
        await p.setString('forecastWeather', jsonEncode(forecastMap));
      }
    } catch (e) {
      debugPrint('Erreur inattendue : $e');
    }
  }

  Future<void> loadSavedWeatherData() async {
    final p = await prefs;
    final String? weatherString = p.getString('currentWeather');
    final String? forecastString = p.getString('forecastWeather');
    if (weatherString != null && forecastString != null) {
      final decodedJson = jsonDecode(weatherString) as Map<String, dynamic>;
      final decodedForecastJson = jsonDecode(forecastString) as Map<String, dynamic>;
      final locationObj = Location.fromJson(decodedJson['location']);
      final currentObj = CurrentWeather.fromJson(decodedJson['current']);
      final weeklyForecastObj = ForecastWeather.fromJson(decodedForecastJson['forecast']);
      setState(() {
        location = locationObj;
        weatherData = currentObj;
        weeklyForecast = weeklyForecastObj;
      });
      debugPrint('Données météo chargées depuis les SharedPreferences.');
    } else {
      debugPrint('Aucune donnée météo sauvegardée.');
    }
  }
}
