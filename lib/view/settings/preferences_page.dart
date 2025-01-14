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
                  _buildDropdownSection<TemperatureUnit>(
                    title: 'Unité de Température',
                    currentValue: prefs.preferredTemperatureUnit,
                    items: _temperatureUnits,
                    unitToString: Temperature.unitToString,
                    onValueChanged: (newValue) async {
                      prefs.setPreferredTemperatureUnit(newValue);
                      await _handleUnitChange(
                        prefs,
                        temperature: newValue,
                        wind: prefs.preferredWindUnit,
                        humidity: prefs.preferredHumidityUnit,
                        precipitation: prefs.preferredPrecipitationUnit,
                      );
                    },
                  ),
                  _buildDropdownSection<WindUnit>(
                    title: 'Unité de Vitesse du Vent',
                    currentValue: prefs.preferredWindUnit,
                    items: _windSpeedUnits,
                    unitToString: WindSpeed.unitToString,
                    onValueChanged: (newValue) async {
                      prefs.setPreferredWindUnit(newValue);
                      await _handleUnitChange(
                        prefs,
                        temperature: prefs.preferredTemperatureUnit,
                        wind: newValue,
                        humidity: prefs.preferredHumidityUnit,
                        precipitation: prefs.preferredPrecipitationUnit,
                      );
                    },
                  ),
                  _buildDropdownSection<PrecipitationUnit>(
                    title: 'Unité de Précipitations',
                    currentValue: prefs.preferredPrecipitationUnit,
                    items: _precipitationUnits,
                    unitToString: Precipitation.unitToString,
                    onValueChanged: (newValue) async {
                      prefs.setPreferredPrecipitationUnit(newValue);
                      await _handleUnitChange(
                        prefs,
                        temperature: prefs.preferredTemperatureUnit,
                        wind: prefs.preferredWindUnit,
                        humidity: prefs.preferredHumidityUnit,
                        precipitation: newValue,
                      );
                    },
                  ),
                  _buildDropdownSection<HumidityUnit>(
                    title: 'Unité d\'Humidité',
                    currentValue: prefs.preferredHumidityUnit,
                    items: _humidityUnits,
                    unitToString: Humidity.unitToString,
                    onValueChanged: (newValue) async {
                      prefs.setPreferredHumidityUnit(newValue);
                      await _handleUnitChange(
                        prefs,
                        temperature: prefs.preferredTemperatureUnit,
                        wind: prefs.preferredWindUnit,
                        humidity: newValue,
                        precipitation: prefs.preferredPrecipitationUnit,
                      );
                    },
                  ),
                  if (prefs.isLogged)
                    _buildDropdownSection<int>(
                      title: "Fréquence de mise à jour",
                      currentValue: prefs.fetchIntervalInMinutes,
                      items: intervalsMap.keys.toList(),
                      unitToString: (int value) => intervalsMap[value] ?? '',
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

  Future<void> _handleUnitChange(
    UserPreferences prefs, {
    required TemperatureUnit temperature,
    required WindUnit wind,
    required HumidityUnit humidity,
    required PrecipitationUnit precipitation,
  }) async {
    await updatePreferencesUnit(
      prefs.email,
      temperature,
      wind,
      humidity,
      precipitation,
    );

    await _updateSensibilities(prefs);
  }

  Future<void> _updateSensibilities(UserPreferences prefs) async {
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

  Widget _buildDropdownSection<T>({
    required String title,
    required T currentValue,
    required List<T> items,
    required String Function(T) unitToString,
    required Future<void> Function(T) onValueChanged,
  }) {
    return _buildPreferenceSection(
      title: title,
      child: DropdownButton<T>(
        value: currentValue,
        onChanged: (T? newValue) async {
          if (newValue != null) {
            await onValueChanged(newValue);
          }
        },
        items: items.map((T value) {
          return DropdownMenuItem<T>(
            value: value,
            child: Text(
              unitToString(value),
              style: const TextStyle(
                fontFamily: 'Montserrat',
                fontSize: 16,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildPreferenceSection({
    required String title,
    required Widget child,
  }) {
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
