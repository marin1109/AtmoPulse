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

  Widget contentBox(BuildContext context) {
    return Stack(
      children: [
        Container(
          padding: const EdgeInsets.only(
              left: 20, top: 65, right: 20, bottom: 20),
          margin: const EdgeInsets.only(top: 45),
          decoration: BoxDecoration(
            shape: BoxShape.rectangle,
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: const [
              BoxShadow(
                color: Colors.black45,
                offset: Offset(0, 10),
                blurRadius: 10,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Déconnexion',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Montserrat',
                ),
              ),
              const SizedBox(height: 15),
              const Text(
                'Êtes-vous sûr de vouloir vous déconnecter ?',
                style: TextStyle(
                  fontSize: 16,
                  fontFamily: 'Montserrat',
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 22),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text(
                      'Annuler',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.blueAccent,
                        fontFamily: 'Montserrat',
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      _logout(context);
                    },
                    child: const Text(
                      'Oui',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.blueAccent,
                        fontFamily: 'Montserrat',
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        Positioned(
          left: 20,
          right: 20,
          child: CircleAvatar(
            backgroundColor: Colors.blueAccent,
            radius: 45,
            child: const Icon(
              Icons.logout,
              color: Colors.white,
              size: 50,
            ),
          ),
        ),
      ],
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

    final prenom = userPrefs.prenom; // FName
    final nom = userPrefs.nom;       // LName
    final age = userPrefs.age;       // Age
    final email = userPrefs.email;   // Email

    // Exemple de récupération de vos sensibilités (valeurs brutes)
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
              const PopupMenuItem<int>(value: 0, child: Text('Changer le mot de passe')),
              const PopupMenuItem<int>(value: 1, child: Text('Supprimer le compte')),
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
              padding: const EdgeInsets.symmetric(
                  vertical: 30.0, horizontal: 20.0),
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
                            : 'U', // 'U' pour user
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
                    _buildInfoRow('Âge', '${age.toString()} ans', Icons.cake),
                    const SizedBox(height: 20),
                    const Divider(),
                    const SizedBox(height: 10),
                    // Section préférences
                    const Text(
                      'Vos préférences',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Montserrat',
                      ),
                    ),
                    const SizedBox(height: 20),
                    _buildInfoRow('Température min/max ${Temperature.unitToString(userPrefs.preferredTemperatureUnit)}',
                        '$temperatureMin / $temperatureMax', Icons.thermostat),
                    _buildInfoRow('Humidité min/max ${Humidity.unitToString(userPrefs.preferredHumidityUnit)}',
                        '$humidityMin / $humidityMax', Icons.water),
                    _buildInfoRow('Précipitations min/max ${Precipitation.unitToString(userPrefs.preferredPrecipitationUnit)}',
                        '${userPrefs.precipMin?.value ?? 0} / ${userPrefs.precipMax?.value ?? 100}',
                        Icons.water_drop),
                    _buildInfoRow('Vent min/max ${WindSpeed.unitToString(userPrefs.preferredWindUnit)}', '$windMin / $windMax',
                        Icons.air),
                    _buildInfoRow('UV', '$uvValue', Icons.wb_sunny),
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

  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.blueAccent),
          const SizedBox(width: 10),
          Text(
            '$label : ',
            style: const TextStyle(
              fontSize: 18,
              fontFamily: 'Montserrat',
              fontWeight: FontWeight.bold,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 18,
                fontFamily: 'Montserrat',
              ),
            ),
          ),
        ],
      ),
    );
  }
}
