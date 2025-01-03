// preferences_page.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Imports
import '../../utils/user_preferences.dart';

// Types
import '../../types/humidity_type.dart';
import '../../types/precipitation_type.dart';
import '../../types/pressure_type.dart';
import '../../types/temperature_type.dart';
import '../../types/wind_type.dart';

class PreferencesPage extends StatelessWidget {
  const PreferencesPage({super.key});

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
  static const List<PressureUnit> _pressureUnits = [
    PressureUnit.hPa,
    PressureUnit.atm,
    PressureUnit.psi,
    PressureUnit.Pa,
    PressureUnit.mmHg,
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
                      onChanged: (TemperatureUnit? newValue) {
                        if (newValue != null) {
                          prefs.setPreferredTemperatureUnit(newValue);
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
                      onChanged: (WindUnit? newValue) {
                        if (newValue != null) {
                          prefs.setPreferredWindUnit(newValue);
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
                    title: 'Unité de Pression',
                    child: DropdownButton<PressureUnit>(
                      value: prefs.preferredPressureUnit,
                      onChanged: (PressureUnit? newValue) {
                        if (newValue != null) {
                          prefs.setPreferredPressureUnit(newValue);
                        }
                      },
                      items: _pressureUnits.map((PressureUnit value) {
                        return DropdownMenuItem<PressureUnit>(
                          value: value,
                          child: Text(
                            Pressure.unitToString(value),
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
                      onChanged: (PrecipitationUnit? newValue) {
                        if (newValue != null) {
                          prefs.setPreferredPrecipitationUnit(newValue);
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
                      onChanged: (HumidityUnit? newValue) {
                        if (newValue != null) {
                          prefs.setPreferredHumidityUnit(newValue);
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
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPreferenceSection({required String title, required Widget child}) {
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
