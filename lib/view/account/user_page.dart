// Flutter imports
import 'package:flutter/material.dart';

// Package imports
import 'package:provider/provider.dart';

// Utils
import '../../utils/user_preferences.dart';
import '../../types/weather/temperature.dart';
import '../../types/weather/wind_speed.dart';
import '../../types/weather/precipitation.dart';
import '../../types/weather/humidity.dart';

// Pages
import 'log_in_sign_up_page.dart';

// Dialogs
import '../dialogs/editPreferences_dialog.dart';
import '../dialogs/changePassword_dialog.dart';
import '../dialogs/deleteAccount_dialog.dart';
import '../dialogs/logout_dialog.dart';

import 'info_row.dart';

class UserPage extends StatefulWidget {
  const UserPage({super.key});

  @override
  _UserPageState createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  @override
  void initState() {
    super.initState();
  }

  // ==============================
  // Déconnexion
  // ==============================
  void _logout(BuildContext context) async {
    final userPrefs = Provider.of<UserPreferences>(context, listen: false);
    await userPrefs.clearAll();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LSPage()),
    );
  }

  void _onSelected(BuildContext context, int item) {
    switch (item) {
      case 0:
        showDialog(
          context: context,
          builder: (context) => const ChangePasswordDialog(),
        );
        break;
      case 1:
        DeleteAccountDialog.showConfirmDialog(context);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Récupération via Provider
    final userPrefs = Provider.of<UserPreferences>(context);

    final prenom = userPrefs.prenom; // Prénom
    final nom = userPrefs.nom;       // Nom
    final age = userPrefs.age;       // Âge
    final email = userPrefs.email;   // Email

    // Récupération des sensibilités
    final humidityMin = userPrefs.humidityMin?.value ?? 0.0;
    final humidityMax = userPrefs.humidityMax?.value ?? 100.0;
    final temperatureMin = userPrefs.tempMin?.value ?? -50;
    final temperatureMax = userPrefs.tempMax?.value ?? 50;
    final windMin = userPrefs.windMin?.value ?? 0; 
    final windMax = userPrefs.windMax?.value ?? 200;
    final uvValue = userPrefs.uvValue?.value.toInt() ?? 0;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Bienvenue, ${prenom.toString().isNotEmpty ? prenom : email}',
          style: const TextStyle(
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.blueAccent,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return const LogoutDialog();
                },
              );
            },
            tooltip: 'Déconnexion',
          ),
          PopupMenuButton<int>(
            onSelected: (item) => _onSelected(context, item),
            itemBuilder: (context) => [
              const PopupMenuItem<int>(
                  value: 0, child: Text('Changer le mot de passe')),
              const PopupMenuItem<int>(
                  value: 1, child: Text('Supprimer le compte')),
            ],
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue.shade100, Colors.blue.shade300],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: Card(
            margin: const EdgeInsets.all(20),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            elevation: 8,
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 30.0, horizontal: 20.0),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.blueAccent,
                      child: Text(
                        prenom.toString().isNotEmpty
                            ? prenom.toString().substring(0, 1).toUpperCase()
                            : 'U', // 'U' pour User si prénom vide
                        style: const TextStyle(
                          fontSize: 50,
                          color: Colors.white,
                          fontFamily: 'Montserrat',
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      '$prenom $nom',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Montserrat',
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      email.toString(),
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.grey.shade600,
                        fontFamily: 'Montserrat',
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Divider(),
                    const SizedBox(height: 10),
                    InfoRow(label: 'Âge', value: '${age.toString()} ans', icon: Icons.cake),
                    const SizedBox(height: 20),
                    const Divider(),
                    const SizedBox(height: 10),
                    const Text(
                      'Vos préférences',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Montserrat',
                      ),
                    ),
                    const SizedBox(height: 20),
                    InfoRow(
                      label: 'Température min/max ${Temperature.unitToString(userPrefs.preferredTemperatureUnit)}',
                      value: '$temperatureMin / $temperatureMax',
                      icon: Icons.thermostat,
                    ),
                    InfoRow(
                      label: 'Humidité min/max ${Humidity.unitToString(userPrefs.preferredHumidityUnit)}',
                      value: '$humidityMin / $humidityMax',
                      icon: Icons.water,
                    ),
                    InfoRow(
                      label: 'Précipitations min/max ${Precipitation.unitToString(userPrefs.preferredPrecipitationUnit)}',
                      value: '${userPrefs.precipMin?.value ?? 0} / ${userPrefs.precipMax?.value ?? 100}',
                      icon: Icons.water_drop,
                    ),
                    InfoRow(
                      label: 'Vent min/max ${WindSpeed.unitToString(userPrefs.preferredWindUnit)}',
                      value: '$windMin / $windMax',
                      icon: Icons.air,
                    ),
                    InfoRow(label: 'UV', value: '$uvValue', icon: Icons.wb_sunny),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.edit),
                      label: const Text('Modifier mes préférences'),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (_) => const EditPreferencesDialog(),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        backgroundColor: Colors.blueAccent,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
