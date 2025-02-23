import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Utils
import '../../utils/user_preferences.dart';

// Types - Weather
import '../../models/types/weather/humidity.dart';
import '../../models/types/weather/precipitation.dart';
import '../../models/types/weather/temperature.dart';
import '../../models/types/weather/wind_speed.dart';

// Controller
import '../../controllers/preferences_controller.dart';

class PreferencesPage extends StatefulWidget {
  const PreferencesPage({super.key});

  @override
  State<PreferencesPage> createState() => _PreferencesPageState();
}

class _PreferencesPageState extends State<PreferencesPage>
    with PreferencesController {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Préférences',
          style: TextStyle(
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      extendBodyBehindAppBar: true,
      body: Consumer<UserPreferences>(
        builder: (context, prefs, child) {
          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.blue.shade700, Colors.blue.shade200],
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: ListView(
                children: [
                  buildDropdownSection<TemperatureUnit>(
                    title: 'Unité de Température',
                    currentValue: prefs.preferredTemperatureUnit,
                    items: PreferencesController.temperatureUnits,
                    unitToString: Temperature.unitToString,
                    onValueChanged: (newValue) async {
                      prefs.setPreferredTemperatureUnit(newValue);

                      if (prefs.isLogged) {
                        await handleUnitChange(
                          prefs,
                          temperature: newValue,
                          wind: prefs.preferredWindUnit,
                          humidity: prefs.preferredHumidityUnit,
                          precipitation: prefs.preferredPrecipitationUnit,
                        );
                      }
                    },
                  ),

                  buildDropdownSection<WindUnit>(
                    title: 'Unité de Vitesse du Vent',
                    currentValue: prefs.preferredWindUnit,
                    items: PreferencesController.windSpeedUnits,
                    unitToString: WindSpeed.unitToString,
                    onValueChanged: (newValue) async {
                      prefs.setPreferredWindUnit(newValue);

                      if (prefs.isLogged) {
                        await handleUnitChange(
                          prefs,
                          temperature: prefs.preferredTemperatureUnit,
                          wind: newValue,
                          humidity: prefs.preferredHumidityUnit,
                          precipitation: prefs.preferredPrecipitationUnit,
                        );
                      }
                    },
                  ),

                  buildDropdownSection<PrecipitationUnit>(
                    title: 'Unité de Précipitations',
                    currentValue: prefs.preferredPrecipitationUnit,
                    items: PreferencesController.precipitationUnits,
                    unitToString: Precipitation.unitToString,
                    onValueChanged: (newValue) async {
                      prefs.setPreferredPrecipitationUnit(newValue);
                      if (prefs.isLogged) {
                        await handleUnitChange(
                          prefs,
                          temperature: prefs.preferredTemperatureUnit,
                          wind: prefs.preferredWindUnit,
                          humidity: prefs.preferredHumidityUnit,
                          precipitation: newValue,
                        );
                      }
                    },
                  ),

                  buildDropdownSection<HumidityUnit>(
                    title: 'Unité d\'Humidité',
                    currentValue: prefs.preferredHumidityUnit,
                    items: PreferencesController.humidityUnits,
                    unitToString: Humidity.unitToString,
                    onValueChanged: (newValue) async {
                      prefs.setPreferredHumidityUnit(newValue);
                      if (prefs.isLogged) {
                        await handleUnitChange(
                          prefs,
                          temperature: prefs.preferredTemperatureUnit,
                          wind: prefs.preferredWindUnit,
                          humidity: newValue,
                          precipitation: prefs.preferredPrecipitationUnit,
                        );
                      }
                    },
                  ),

                  if (prefs.isLogged)
                    buildDropdownSection<int>(
                      title: "Fréquence de mise à jour",
                      currentValue: prefs.fetchIntervalInMinutes,
                      items: PreferencesController.intervalsMap.keys.toList(),
                      unitToString: (value) => PreferencesController.intervalsMap[value] ?? '',
                      onValueChanged: (newVal) async {
                        await prefs.setFetchIntervalInMinutes(newVal);
                      },
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
