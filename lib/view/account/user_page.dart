import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';

// Importer vos services et types
import '../../services/account_service.dart';

import '../../types/fname_type.dart';
import '../../types/lname_type.dart';
import '../../types/email_type.dart';
import '../../types/password_type.dart';
import '../../types/age_type.dart';

import '../../utils/user_preferences.dart';

// Import supplémentaire pour valider et gérer les types (humidity, etc.)
import '../../types/humidity_type.dart';
import '../../types/temperature_type.dart';
import '../../types/pressure_type.dart';
import '../../types/precipitation_type.dart';
import '../../types/wind_type.dart';
import '../../types/uv_type.dart';

import 'LogInSignUp_page.dart';

class UserPage extends StatefulWidget {
  const UserPage({super.key});

  @override
  _UserPageState createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  // Infos utilisateur de base
  FName prenom = FName('Non spécifié');
  LName nom = LName('Non spécifié');
  Age age = Age(0);
  Email email = Email('Non spécifié');
  
  // Champs de sensibilité
  double humidityMin = 0;
  double humidityMax = 0;
  double precipitationMin = 0;
  double precipitationMax = 0;
  double pressureMin = 0;
  double pressureMax = 0;
  int temperatureMin = 0;
  int temperatureMax = 0;
  double windMin = 0;
  double windMax = 0;
  int uvValue = 0; // si besoin d'affichage / modification

  // Contrôleurs pour l'édition
  final _tempMinController = TextEditingController();
  final _tempMaxController = TextEditingController();
  final _humidityMinController = TextEditingController();
  final _humidityMaxController = TextEditingController();
  final _pressureMinController = TextEditingController();
  final _pressureMaxController = TextEditingController();
  final _precipitationMinController = TextEditingController();
  final _precipitationMaxController = TextEditingController();
  final _windMinController = TextEditingController();
  final _windMaxController = TextEditingController();
  final _uvController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  void dispose() {
    _tempMinController.dispose();
    _tempMaxController.dispose();
    _humidityMinController.dispose();
    _humidityMaxController.dispose();
    _pressureMinController.dispose();
    _pressureMaxController.dispose();
    _precipitationMinController.dispose();
    _precipitationMaxController.dispose();
    _windMinController.dispose();
    _windMaxController.dispose();
    _uvController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      prenom = FName(prefs.getString('prenom') ?? 'Non spécifié');
      nom = LName(prefs.getString('nom') ?? 'Non spécifié');
      age = Age(prefs.getInt('age') ?? 0);
      email = Email(prefs.getString('email') ?? 'Non spécifié');

      // Chargement des sensibilités
      humidityMin = prefs.getDouble('humidite_min') ?? 0;
      humidityMax = prefs.getDouble('humidite_max') ?? 0;
      precipitationMin = prefs.getDouble('precipitations_min') ?? 0;
      precipitationMax = prefs.getDouble('precipitations_max') ?? 0;
      pressureMin = prefs.getDouble('pression_min') ?? 0;
      pressureMax = prefs.getDouble('pression_max') ?? 0;
      temperatureMin = prefs.getInt('temperature_min') ?? 0;
      temperatureMax = prefs.getInt('temperature_max') ?? 0;
      windMin = prefs.getDouble('vent_min') ?? 0;
      windMax = prefs.getDouble('vent_max') ?? 0;
      uvValue = prefs.getInt('uv') ?? 0;
    });
  }

  void _logout(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LSPage()),
    );
  }

  void _confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          backgroundColor: Colors.transparent,
          child: contentBox(context),
        );
      },
    );
  }

  Widget contentBox(BuildContext context) {
    return Stack(
      children: [
        Container(
          padding:
              const EdgeInsets.only(left: 20, top: 65, right: 20, bottom: 20),
          margin: const EdgeInsets.only(top: 45),
          decoration: BoxDecoration(
            shape: BoxShape.rectangle,
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black45,
                offset: const Offset(0, 10),
                blurRadius: 10,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Déconnexion',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Montserrat',
                ),
              ),
              SizedBox(height: 15),
              Text(
                'Êtes-vous sûr de vouloir vous déconnecter ?',
                style: TextStyle(
                  fontSize: 16,
                  fontFamily: 'Montserrat',
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 22),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text(
                      'Annuler',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.blueAccent,
                        fontFamily: 'Montserrat',
                      ),
                    ),
                  ),
                  SizedBox(width: 10),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      _logout(context);
                    },
                    child: Text(
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
            child: Icon(
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
        _showChangePasswordDialog(context);
        break;
      case 1:
        _confirmDeleteAccount(context);
        break;
    }
  }

  void _showChangePasswordDialog(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    late Password oldPassword;
    late Password newPassword;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Changer le mot de passe'),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  TextFormField(
                    obscureText: true,
                    decoration:
                        InputDecoration(labelText: 'Ancien mot de passe'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Veuillez entrer votre ancien mot de passe';
                      }
                      return null;
                    },
                    onChanged: (value) {
                      oldPassword = Password(value);
                    },
                  ),
                  TextFormField(
                    obscureText: true,
                    decoration: InputDecoration(
                        labelText: 'Nouveau mot de passe', errorMaxLines: 3),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Veuillez entrer un nouveau mot de passe';
                      } else if (!Password.isValidPassword(Password(value))) {
                        return 'Le mot de passe doit contenir au moins 8 caractères, dont une majuscule, une minuscule, un chiffre et un caractère spécial.';
                      }
                      return null;
                    },
                    onChanged: (value) {
                      newPassword = Password(value);
                    },
                  ),
                  TextFormField(
                    obscureText: true,
                    decoration: InputDecoration(
                        labelText: 'Confirmer le nouveau mot de passe',
                        errorMaxLines: 3),
                    validator: (value) {
                      if (value == null || value != newPassword) {
                        return 'Les mots de passe ne correspondent pas';
                      } else if (!Password.isValidPassword(Password(value))) {
                        return 'Le mot de passe doit contenir au moins 8 caractères, dont une majuscule, une minuscule, un chiffre et un caractère spécial.';
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              child: Text('Annuler'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Enregistrer'),
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  try {
                    await updatePassword(
                      email,
                      oldPassword,
                      newPassword,
                    );
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content: Text('Mot de passe mis à jour avec succès')),
                    );
                  } catch (e) {
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Erreur : ${e.toString()}')),
                    );
                  }
                }
              },
            ),
          ],
        );
      },
    );
  }

  void _confirmDeleteAccount(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Supprimer le compte'),
          content: Text(
              'Êtes-vous sûr de vouloir supprimer votre compte ? Cette action est irréversible.'),
          actions: [
            TextButton(
              child: Text('Annuler'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Supprimer'),
              onPressed: () async {
                Navigator.of(context).pop();
                await _showPasswordConfirmationDialog(context);
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _showPasswordConfirmationDialog(BuildContext context) async {
    late Password password;
    final formKey = GlobalKey<FormState>();

    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirmer avec le mot de passe'),
          content: Form(
            key: formKey,
            child: TextFormField(
              obscureText: true,
              decoration: InputDecoration(labelText: 'Mot de passe'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Veuillez entrer votre mot de passe';
                }
                return null;
              },
              onChanged: (value) {
                password = Password(value);
              },
            ),
          ),
          actions: [
            TextButton(
              child: Text('Annuler'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Confirmer'),
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  try {
                    await deleteUser(email, password);
                    SharedPreferences prefs =
                        await SharedPreferences.getInstance();
                    await prefs.clear();
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (context) => LSPage()),
                      (route) => false,
                    );
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Compte supprimé avec succès')),
                    );
                  } catch (e) {
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Erreur : ${e.toString()}')),
                    );
                  }
                }
              },
            ),
          ],
        );
      },
    );
  }

  // Méthode pour afficher la boîte de dialogue d'édition des préférences
  void _showEditPreferencesDialog(BuildContext context) {
    _tempMinController.text = temperatureMin.toString();
    _tempMaxController.text = temperatureMax.toString();
    _humidityMinController.text = humidityMin.toString();
    _humidityMaxController.text = humidityMax.toString();
    _pressureMinController.text = pressureMin.toString();
    _pressureMaxController.text = pressureMax.toString();
    _precipitationMinController.text = precipitationMin.toString();
    _precipitationMaxController.text = precipitationMax.toString();
    _windMinController.text = windMin.toString();
    _windMaxController.text = windMax.toString();
    _uvController.text = uvValue.toString();

    final formKey = GlobalKey<FormState>();

    final userPrefs = Provider.of<UserPreferences>(context, listen: false);
    
    late String tempUnit = Temperature.unitToString(userPrefs.preferredTemperatureUnit);
    late String windUnit = WindSpeed.unitToString(userPrefs.preferredWindUnit);
    late String pressureUnit = Pressure.unitToString(userPrefs.preferredPressureUnit);
    late String humidityUnit = Humidity.unitToString(userPrefs.preferredHumidityUnit);
    late String precipitationUnit = Precipitation.unitToString(userPrefs.preferredPrecipitationUnit);  
    

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Modifier vos sensibilités'),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                children: [
                  _buildNumericField('Température min ($tempUnit)', _tempMinController,
                      (val) => Temperature.isValidTemperature(int.tryParse(val) ?? -999, userPrefs.preferredTemperatureUnit),),
                  _buildNumericField('Température max ($tempUnit)', _tempMaxController,
                      (val) => Temperature.isValidTemperature(int.tryParse(val) ?? -999, userPrefs.preferredTemperatureUnit),
                      minController: _tempMinController),
                  _buildNumericField('Humidité min ($humidityUnit)', _humidityMinController,
                      (val) => Humidity.isValidHumidity(double.tryParse(val) ?? -1, userPrefs.preferredHumidityUnit, 25)),
                  _buildNumericField('Humidité max ($humidityUnit)', _humidityMaxController,
                      (val) => Humidity.isValidHumidity(double.tryParse(val) ?? -1, userPrefs.preferredHumidityUnit, 25),
                      minController: _humidityMinController),
                  _buildNumericField('Pression min ($pressureUnit)', _pressureMinController,
                      (val) => Pressure.isValidPressure(double.tryParse(val) ?? -1, userPrefs.preferredPressureUnit)),
                  _buildNumericField('Pression max ($pressureUnit)', _pressureMaxController,
                      (val) => Pressure.isValidPressure(double.tryParse(val) ?? -1, userPrefs.preferredPressureUnit),
                      minController: _pressureMinController),
                  _buildNumericField('Précipitations min ($precipitationUnit)', _precipitationMinController,
                      (val) => Precipitation.isValidPrecipitation(double.tryParse(val) ?? -1, userPrefs.preferredPrecipitationUnit)),
                  _buildNumericField('Précipitations max ($precipitationUnit)', _precipitationMaxController,
                      (val) => Precipitation.isValidPrecipitation(double.tryParse(val) ?? -1, userPrefs.preferredPrecipitationUnit),
                      minController: _precipitationMinController),
                  _buildNumericField('Vent min ($windUnit)', _windMinController,
                      (val) => WindSpeed.isValidWindSpeed(int.tryParse(val) ?? -1, userPrefs.preferredWindUnit)),
                  _buildNumericField('Vent max ($windUnit)', _windMaxController,
                      (val) => WindSpeed.isValidWindSpeed(int.tryParse(val) ?? -1, userPrefs.preferredWindUnit),
                      minController: _windMinController),
                  _buildNumericField('UV', _uvController,
                      (val) => UV.isValidUV(int.tryParse(val) ?? -1)),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              child: Text('Annuler'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: Text('Enregistrer'),
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  // Mise à jour des valeurs
                  setState(() {
                    temperatureMin = int.parse(_tempMinController.text);
                    temperatureMax = int.parse(_tempMaxController.text);
                    humidityMin = double.parse(_humidityMinController.text);
                    humidityMax = double.parse(_humidityMaxController.text);
                    pressureMin = double.parse(_pressureMinController.text);
                    pressureMax = double.parse(_pressureMaxController.text);
                    precipitationMin =
                        double.parse(_precipitationMinController.text);
                    precipitationMax =
                        double.parse(_precipitationMaxController.text);
                    windMin = double.parse(_windMinController.text);
                    windMax = double.parse(_windMaxController.text);
                    uvValue = int.parse(_uvController.text);
                  });

                  // Sauvegarde dans les préférences
                  SharedPreferences prefs = await SharedPreferences.getInstance();
                  await prefs.setDouble('humidite_min', humidityMin);
                  await prefs.setDouble('humidite_max', humidityMax);
                  await prefs.setDouble('precipitations_min', precipitationMin);
                  await prefs.setDouble('precipitations_max', precipitationMax);
                  await prefs.setDouble('pression_min', pressureMin);
                  await prefs.setDouble('pression_max', pressureMax);
                  await prefs.setInt('temperature_min', temperatureMin);
                  await prefs.setInt('temperature_max', temperatureMax);
                  await prefs.setDouble('vent_min', windMin);
                  await prefs.setDouble('vent_max', windMax);
                  await prefs.setInt('uv', uvValue);

                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Préférences mises à jour !')),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildNumericField(String label, TextEditingController controller, bool Function(String) validator, {TextEditingController? minController}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: Colors.blue.shade50,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
        ),
        keyboardType: TextInputType.number,
        validator: (value) {
          if (value == null || value.isEmpty) return 'Requis';
          if (!validator(value)) return '$label invalide';
          // Si minController est fourni, on vérifie que max >= min
          if (minController != null && minController.text.isNotEmpty) {
            final minVal = double.tryParse(minController.text);
            final currVal = double.tryParse(value);
            if (minVal != null && currVal != null && currVal < minVal) {
              return 'La valeur max doit être >= à la valeur min';
            }
          }
          return null;
        },
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    final userPrefs = Provider.of<UserPreferences>(context);
    late String tempUnit = Temperature.unitToString(userPrefs.preferredTemperatureUnit);
    late String windUnit = WindSpeed.unitToString(userPrefs.preferredWindUnit);
    late String pressureUnit = Pressure.unitToString(userPrefs.preferredPressureUnit);
    late String humidityUnit = Humidity.unitToString(userPrefs.preferredHumidityUnit);
    late String precipitationUnit = Precipitation.unitToString(userPrefs.preferredPrecipitationUnit);  

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Bienvenue, ${prenom.toString() != 'Non spécifié' ? prenom : email}',
          style: TextStyle(
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.blueAccent,
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () => _confirmLogout(context),
            tooltip: 'Déconnexion',
          ),
          PopupMenuButton<int>(
            onSelected: (item) => _onSelected(context, item),
            itemBuilder: (context) => [
              PopupMenuItem<int>(
                  value: 0, child: Text('Changer le mot de passe')),
              PopupMenuItem<int>(value: 1, child: Text('Supprimer le compte')),
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
            margin: EdgeInsets.all(20),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
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
                        prenom.toString() != 'Non spécifié' ? prenom.toString().substring(0, 1).toUpperCase() : 'U',
                        style: TextStyle(
                          fontSize: 50,
                          color: Colors.white,
                          fontFamily: 'Montserrat',
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    Text(
                      '$prenom $nom',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Montserrat',
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      email.toString(),
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.grey.shade600,
                        fontFamily: 'Montserrat',
                      ),
                    ),
                    SizedBox(height: 20),
                    Divider(),
                    SizedBox(height: 10),
                    _buildInfoRow('Âge', '${age.toString()} ans', Icons.cake),
                    SizedBox(height: 20),
                    Divider(),
                    SizedBox(height: 10),
                    // Section préférences
                    Text(
                      'Vos préférences',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Montserrat',
                      ),
                    ),
                    SizedBox(height: 20),

                    _buildInfoRow('Température min/max', '$temperatureMin$tempUnit / $temperatureMax$tempUnit', Icons.thermostat),
                    _buildInfoRow('Humidité min/max', '$humidityMin$humidityUnit / $humidityMax$humidityUnit', Icons.water),
                    _buildInfoRow('Pression min/max', '$pressureMin $pressureUnit / $pressureMax $pressureUnit', Icons.speed),
                    _buildInfoRow('Précipitations min/max', '$precipitationMin $precipitationUnit / $precipitationMax $precipitationUnit', Icons.water_drop),
                    _buildInfoRow('Vent min/max', '$windMin $windUnit / $windMax $windUnit', Icons.air),
                    _buildInfoRow('UV', '$uvValue', Icons.wb_sunny),

                    SizedBox(height: 20),
                    ElevatedButton.icon(
                      icon: Icon(Icons.edit),
                      label: Text('Modifier mes préférences'),
                      onPressed: () => _showEditPreferencesDialog(context),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
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
          Icon(
            icon,
            color: Colors.blueAccent,
          ),
          SizedBox(width: 10),
          Text(
            '$label : ',
            style: TextStyle(
              fontSize: 18,
              fontFamily: 'Montserrat',
              fontWeight: FontWeight.bold,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
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
