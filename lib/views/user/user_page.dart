import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Contrôleur
import '../../../controllers/user_controller.dart';

// Utils
import '../../../utils/user_preferences.dart';

// Types
import '../../../types/weather/temperature.dart';
import '../../../types/weather/humidity.dart';
import '../../../types/weather/precipitation.dart';
import '../../../types/weather/wind_speed.dart';

// Dialog pour modifier les préférences
import '../dialogs/editPreferences_dialog.dart';

// Widget InfoRow
import 'info_row.dart';

class UserPage extends StatefulWidget {
  const UserPage({super.key});

  @override
  _UserPageState createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  @override
  Widget build(BuildContext context) {
    // Récupère les préférences utilisateur
    final userPrefs = Provider.of<UserPreferences>(context);

    final prenom = userPrefs.prenom;
    final nom = userPrefs.nom;
    final age = userPrefs.age;
    final email = userPrefs.email;

    // Sensibilités
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
          'Bienvenue, $prenom',
          style: const TextStyle(
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.blueAccent,
        actions: [
          // Bouton logout
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => UserController.showLogoutDialog(context),
            tooltip: 'Déconnexion',
          ),
          // Menu déroulant (changer MDP, supprimer compte)
          PopupMenuButton<int>(
            onSelected: (item) => UserController.onSelected(context, item),
            itemBuilder: (_) => [
              const PopupMenuItem(value: 0, child: Text('Changer le mot de passe')),
              const PopupMenuItem(value: 1, child: Text('Supprimer le compte')),
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
              padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Avatar
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.blueAccent,
                      child: Text(
                        prenom.value.substring(0, 1).toUpperCase(),
                        style: const TextStyle(
                          fontSize: 50,
                          color: Colors.white,
                          fontFamily: 'Montserrat',
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Nom complet
                    Text(
                      '$prenom $nom',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Montserrat',
                      ),
                    ),
                    const SizedBox(height: 10),
                    // Email
                    Text(
                      email.value,
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.grey.shade600,
                        fontFamily: 'Montserrat',
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Divider(),
                    const SizedBox(height: 10),
                    // Age
                    InfoRow(
                      label: 'Âge',
                      value: '${age.toString()} ans',
                      icon: Icons.cake,
                    ),
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
                    // Températures
                    InfoRow(
                      label: 'Température min/max '
                          '${Temperature.unitToString(userPrefs.preferredTemperatureUnit)}',
                      value: '$temperatureMin / $temperatureMax',
                      icon: Icons.thermostat,
                    ),
                    // Humidité
                    InfoRow(
                      label: 'Humidité min/max '
                          '${Humidity.unitToString(userPrefs.preferredHumidityUnit)}',
                      value: '$humidityMin / $humidityMax',
                      icon: Icons.water,
                    ),
                    // Précipitations
                    InfoRow(
                      label: 'Précipitations min/max '
                          '${Precipitation.unitToString(userPrefs.preferredPrecipitationUnit)}',
                      value:
                          '${userPrefs.precipMin?.value ?? 0} / ${userPrefs.precipMax?.value ?? 100}',
                      icon: Icons.water_drop,
                    ),
                    // Vent
                    InfoRow(
                      label: 'Vent min/max '
                          '${WindSpeed.unitToString(userPrefs.preferredWindUnit)}',
                      value: '$windMin / $windMax',
                      icon: Icons.air,
                    ),
                    // UV
                    InfoRow(
                      label: 'UV',
                      value: '$uvValue',
                      icon: Icons.wb_sunny,
                    ),
                    const SizedBox(height: 20),
                    // Bouton modifier préférences
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
                          horizontal: 20,
                          vertical: 15,
                        ),
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
