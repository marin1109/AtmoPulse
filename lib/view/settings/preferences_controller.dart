import 'package:flutter/material.dart';

import '../../utils/user_preferences.dart';
import '../../services/account_service.dart';

// Types - Weather
import '../../types/weather/humidity.dart';
import '../../types/weather/precipitation.dart';
import '../../types/weather/temperature.dart';
import '../../types/weather/wind_speed.dart';

mixin PreferencesController<T extends StatefulWidget> on State<T> {
  static const Map<int, String> intervalsMap = {
    15: '15 minutes',
    30: '30 minutes',
    60: '1 heure',
    120: '2 heures',
    240: '4 heures',
    480: '8 heures',
  };

  static const List<TemperatureUnit> temperatureUnits = [
    TemperatureUnit.celsius,
    TemperatureUnit.fahrenheit,
    TemperatureUnit.kelvin,
  ];

  static const List<WindUnit> windSpeedUnits = [
    WindUnit.kmh,
    WindUnit.ms,
    WindUnit.mph,
    WindUnit.fts,
    WindUnit.knots,
  ];

  static const List<PrecipitationUnit> precipitationUnits = [
    PrecipitationUnit.inches,
    PrecipitationUnit.litersPerSquareMeter,
    PrecipitationUnit.mm,
  ];

  static const List<HumidityUnit> humidityUnits = [
    HumidityUnit.relative,
    HumidityUnit.absolute,
  ];

  // -- Méthodes de gestion des unités --
  Future<void> handleUnitChange(
    UserPreferences prefs, {
    required TemperatureUnit temperature,
    required WindUnit wind,
    required HumidityUnit humidity,
    required PrecipitationUnit precipitation,
  }) async {
    // Met à jour côté serveur (ou autre source)
    await updatePreferencesUnit(
      prefs.email,
      temperature,
      wind,
      humidity,
      precipitation,
    );

    // Met à jour les sensibilités côté serveur
    await updateSensibilities(prefs);
  }

  Future<void> updateSensibilities(UserPreferences prefs) async {
    await updateSensibilites(
      prefs.email,
      humiditeMin: prefs.humidityMin?.value ?? 0,
      humiditeMax: prefs.humidityMax?.value ?? 100,
      precipitationsMin: prefs.precipMin?.value ?? 0,
      precipitationsMax: prefs.precipMax?.value ?? 100,
      temperatureMin: prefs.tempMin?.value ?? -50,
      temperatureMax: prefs.tempMax?.value ?? 50,
      ventMin: prefs.windMin?.value ?? 0,
      ventMax: prefs.windMax?.value ?? 200,
      uv: prefs.uvValue?.value ?? 0,
    );
  }

  // -- Méthodes de construction de sections UI (facultatif) --
  // Si vous préférez, vous pouvez laisser ces "builders" directement
  // dans la page, mais il est parfois pratique de les externaliser ici.

  /// Construit une section avec un [DropdownButton] réutilisable.
  Widget buildDropdownSection<T>({
    required String title,
    required T currentValue,
    required List<T> items,
    required String Function(T) unitToString,
    required Future<void> Function(T) onValueChanged,
  }) {
    return buildPreferenceSection(
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

  /// Construit un bloc d’UI (Card + Titre + child).
  Widget buildPreferenceSection({
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
