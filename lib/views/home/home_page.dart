import 'package:AtmoPulse/models/types/weather/humidity.dart';
import 'package:AtmoPulse/models/types/weather/precipitation.dart';
import 'package:AtmoPulse/models/types/weather/temperature.dart';
import 'package:AtmoPulse/models/types/weather/wind_speed.dart';
import 'package:AtmoPulse/models/types/weather/uv.dart';
import 'package:AtmoPulse/views/dialogs/contact_dialog.dart';
import 'package:AtmoPulse/views/dialogs/about_dialog.dart' as custom;
import 'package:AtmoPulse/views/settings/preferences_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:convert';

import '../../../utils/user_preferences.dart';
import 'home_controller.dart';
import 'city_search_delegate.dart';
import 'widgets/weather_info_widget.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with HomePageController {
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
                icon: const Icon(Icons.search),
                onPressed: () async {
                  final cityUrl = await showSearch<String>(
                    context: context,
                    delegate:
                        CitySearchDelegate(weatherService: weatherService),
                  );
                  if (cityUrl != null && cityUrl.isNotEmpty) {
                    await onCitySelected(cityUrl);
                  }
                },
              ),
              IconButton(
                icon: const Icon(Icons.star),
                onPressed: () => showFavoritesDialog(context),
              ),
              if (isCustomCity)
                IconButton(
                  icon: const Icon(Icons.home),
                  onPressed: () async {
                    await getWeatherData();
                    setState(() {
                      isCustomCity = false;
                    });
                  },
                ),
              PopupMenuButton<String>(
                icon: const Icon(Icons.menu),
                onSelected: (String value) {
                  switch (value) {
                    case 'compte':
                      checkLoginStatus(context);
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
                            _loadTemperatureText(
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
                            WeatherInfoWidget(
                              icon: Icons.air,
                              value: _loadWindText(
                                weatherData!.wind,
                                userPreferences.preferredWindUnit,
                              ),
                              label: 'Vent',
                            ),
                            WeatherInfoWidget(
                              icon: Icons.water,
                              value: _loadHumidityText(
                                weatherData!.humidity,
                                userPreferences.preferredHumidityUnit,
                              ),
                              label: 'Humidité',
                            ),
                            WeatherInfoWidget(
                              icon: Icons.opacity,
                              value: _loadPrecipitationText(
                                weatherData!.precipitation,
                                userPreferences.preferredPrecipitationUnit,
                              ),
                              label: 'Précipitations',
                            ),
                            WeatherInfoWidget(
                              icon: Icons.wb_sunny,
                              value: _loadUVText(
                                weatherData!.uv,
                              ),
                              label: 'UV',
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
                              final String minMaxTemp =
                                  '${_loadTemperatureText(day.minTemp, userPreferences.preferredTemperatureUnit)} / '
                                  '${_loadTemperatureText(day.maxTemp, userPreferences.preferredTemperatureUnit)}';

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
                                            minMaxTemp,
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

  String _loadTemperatureText(Temperature temperature, TemperatureUnit unit) {
    return Temperature.loadTemperatureText(temperature, unit);
  }

  String _loadWindText(WindSpeed wind, WindUnit unit) {
    return WindSpeed.loadWindText(wind, unit);
  }

  String _loadHumidityText(Humidity humidity, HumidityUnit unit) {
    return Humidity.loadHumidityText(humidity, unit);
  }

  String _loadPrecipitationText(Precipitation precipitation, PrecipitationUnit unit) {
    return Precipitation.loadPrecipitationText(precipitation, unit);
  }

  String _loadUVText(UV uv) {
    return UV.loadUVText(uv);
  }
}
