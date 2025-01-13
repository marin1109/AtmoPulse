// Flutter imports
import 'package:flutter/material.dart';

// Package imports
import 'package:provider/provider.dart';

// Utils
import '../../utils/user_preferences.dart';
import '../../services/account_service.dart';

// Types - Weather
import '../../types/weather/humidity.dart';
import '../../types/weather/precipitation.dart';
import '../../types/weather/temperature.dart';
import '../../types/weather/wind_speed.dart';

class PreferencesPage extends StatelessWidget {
  const PreferencesPage({super.key});

  static const Map<int, String> intervalsMap = {
    15: '15 minutes',
    30: '30 minutes',
    60: '1 heure',
    120: '2 heures',
    240: '4 heures',
    480: '8 heures',
  };
  static const List<TemperatureUnit> _temperatureUnits = [
    TemperatureUnit.celsius,
    TemperatureUnit.fahrenheit,
    TemperatureUnit.kelvin,
  ];
  static const List<WindUnit> _windSpeedUnits = [
    WindUnit.kmh,
    WindUnit.ms,
    WindUnit.mph,
    WindUnit.fts,
    WindUnit.knots,
  ];
  static const List<PrecipitationUnit> _precipitationUnits = [
    PrecipitationUnit.inches,
    PrecipitationUnit.litersPerSquareMeter,
    PrecipitationUnit.mm,
  ];
  static const List<HumidityUnit> _humidityUnits = [
    HumidityUnit.relative,
    HumidityUnit.absolute,
  ];

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
                  _buildPreferenceSection(
                    title: 'Unité de Température',
                    child: DropdownButton<TemperatureUnit>(
                      value: prefs.preferredTemperatureUnit,
                      onChanged: (TemperatureUnit? newValue) async {
                        if (newValue != null) {
                          prefs.setPreferredTemperatureUnit(newValue);

                          await updatePreferencesUnit(
                            prefs.email,
                            newValue,
                            prefs.preferredWindUnit,
                            prefs.preferredHumidityUnit,
                            prefs.preferredPrecipitationUnit,
                          );

                          await updateSensibilites(
                            prefs.email,

                            humiditeMin: prefs.humidityMin!.value,
                            humiditeMax: prefs.humidityMax!.value,

                            precipitationsMin: prefs.precipMin!.value,
                            precipitationsMax: prefs.precipMax!.value,
                            
                            temperatureMin: prefs.tempMin!.value,
                            temperatureMax: prefs.tempMax!.value,
                            
                            ventMin: prefs.windMin!.value,
                            ventMax: prefs.windMax!.value,
                            
                            uv: prefs.uvValue!.value,
                          );
                        }
                      },
                      items: _temperatureUnits.map((TemperatureUnit value) {
                        return DropdownMenuItem<TemperatureUnit>(
                          value: value,
                          child: Text(
                            Temperature.unitToString(value),
                            style: const TextStyle(
                              fontFamily: 'Montserrat',
                              fontSize: 16,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  _buildPreferenceSection(
                    title: 'Unité de Vitesse du Vent',
                    child: DropdownButton<WindUnit>(
                      value: prefs.preferredWindUnit,
                      onChanged: (WindUnit? newValue) async {
                        if (newValue != null) {
                          prefs.setPreferredWindUnit(newValue);

                          await updatePreferencesUnit(
                            prefs.email,
                            prefs.preferredTemperatureUnit,
                            newValue,
                            prefs.preferredHumidityUnit,
                            prefs.preferredPrecipitationUnit,
                          );

                          await updateSensibilites(
                            prefs.email,

                            humiditeMin: prefs.humidityMin!.value,
                            humiditeMax: prefs.humidityMax!.value,

                            precipitationsMin: prefs.precipMin!.value,
                            precipitationsMax: prefs.precipMax!.value,
                            
                            temperatureMin: prefs.tempMin!.value,
                            temperatureMax: prefs.tempMax!.value,
                            
                            ventMin: prefs.windMin!.value,
                            ventMax: prefs.windMax!.value,
                            
                            uv: prefs.uvValue!.value,
                          );
                        }
                      },
                      items: _windSpeedUnits.map((WindUnit value) {
                        return DropdownMenuItem<WindUnit>(
                          value: value,
                          child: Text(
                            WindSpeed.unitToString(value),
                            style: const TextStyle(
                              fontFamily: 'Montserrat',
                              fontSize: 16,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  _buildPreferenceSection(
                    title: 'Unité de Précipitations',
                    child: DropdownButton<PrecipitationUnit>(
                      value: prefs.preferredPrecipitationUnit,
                      onChanged: (PrecipitationUnit? newValue) async {
                        if (newValue != null) {
                          prefs.setPreferredPrecipitationUnit(newValue);

                          await updatePreferencesUnit(
                            prefs.email,
                            prefs.preferredTemperatureUnit,
                            prefs.preferredWindUnit,
                            prefs.preferredHumidityUnit,
                            newValue,
                          );
                          
                          await updateSensibilites(
                            prefs.email,

                            humiditeMin: prefs.humidityMin!.value,
                            humiditeMax: prefs.humidityMax!.value,

                            precipitationsMin: prefs.precipMin!.value,
                            precipitationsMax: prefs.precipMax!.value,
                            
                            temperatureMin: prefs.tempMin!.value,
                            temperatureMax: prefs.tempMax!.value,
                            
                            ventMin: prefs.windMin!.value,
                            ventMax: prefs.windMax!.value,
                            
                            uv: prefs.uvValue!.value,
                          );
                        }
                      },
                      items: _precipitationUnits.map((PrecipitationUnit value) {
                        return DropdownMenuItem<PrecipitationUnit>(
                          value: value,
                          child: Text(
                            Precipitation.unitToString(value),
                            style: const TextStyle(
                              fontFamily: 'Montserrat',
                              fontSize: 16,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  _buildPreferenceSection(
                    title: 'Unité d\'Humidité',
                    child: DropdownButton<HumidityUnit>(
                      value: prefs.preferredHumidityUnit,
                      onChanged: (HumidityUnit? newValue) async {
                        if (newValue != null) {
                          prefs.setPreferredHumidityUnit(newValue);

                          await updatePreferencesUnit(
                            prefs.email,
                            prefs.preferredTemperatureUnit,
                            prefs.preferredWindUnit,
                            newValue,
                            prefs.preferredPrecipitationUnit,
                          );

                          await updateSensibilites(
                            prefs.email,

                            humiditeMin: prefs.humidityMin!.value,
                            humiditeMax: prefs.humidityMax!.value,

                            precipitationsMin: prefs.precipMin!.value,
                            precipitationsMax: prefs.precipMax!.value,
                            
                            temperatureMin: prefs.tempMin!.value,
                            temperatureMax: prefs.tempMax!.value,
                            
                            ventMin: prefs.windMin!.value,
                            ventMax: prefs.windMax!.value,
                            
                            uv: prefs.uvValue!.value,
                          );
                        }
                      },
                      items: _humidityUnits.map((HumidityUnit value) {
                        return DropdownMenuItem<HumidityUnit>(
                          value: value,
                          child: Text(
                            Humidity.unitToString(value),
                            style: const TextStyle(
                              fontFamily: 'Montserrat',
                              fontSize: 16,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  if (prefs.isLogged)
                    _buildPreferenceSection(
                      title: "Fréquence de mise à jour",
                      child: DropdownButton<int>(
                        value: prefs.fetchIntervalInMinutes,
                        onChanged: (int? newVal) async {
                          if (newVal != null) {
                            await prefs.setFetchIntervalInMinutes(newVal);
                          }
                        },
                        items: intervalsMap.entries.map((entry) {
                          return DropdownMenuItem<int>(
                            value: entry.key,
                            child: Text(entry.value),
                          );
                        }).toList(),
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPreferenceSection(
      {required String title, required Widget child}) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      elevation: 5,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontFamily: 'Montserrat',
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.blueAccent,
              ),
            ),
            const SizedBox(height: 10),
            child,
          ],
        ),
      ),
    );
  }
}
