// Flutter imports
import 'package:flutter/material.dart';

// Package imports
import 'package:flip_card/flip_card.dart';
import 'package:flip_card/flip_card_controller.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Service imports
import '../../services/account_service.dart';

// Type imports
import '../../types/email_type.dart';
import '../../types/password_type.dart';
import '../../types/lname_type.dart';
import '../../types/fname_type.dart';
import '../../types/age_type.dart';
import '../../types/temperature_type.dart';
import '../../types/humidity_type.dart';
import '../../types/pressure_type.dart';
import '../../types/precipitation_type.dart';
import '../../types/wind_type.dart';
import '../../types/uv_type.dart';


// Page imports
import 'user_page.dart';

import '../../utils/user_preferences.dart';

class LSPage extends StatefulWidget {
  const LSPage({super.key});

  @override
  _LSPageState createState() => _LSPageState();
}

class _LSPageState extends State<LSPage> with SingleTickerProviderStateMixin {
  final _loginFormKey = GlobalKey<FormState>();
  final _signUpFormKey = GlobalKey<FormState>();
  late Email _email;
  late Password _password;
  late FName _name;
  late LName _surname;
  late Age _age;
  late Humidity _humidity_min;
  late Humidity _humidity_max;
  late Precipitation _precipitation_min;
  late Precipitation _precipitation_max;
  late Pressure _pressure_min;
  late Pressure _pressure_max;
  late Temperature _temperature_min;
  late Temperature _temperature_max;
  late WindSpeed _wind_min;
  late WindSpeed _wind_max;
  late UV _uvValue;
  final FlipCardController _cardController = FlipCardController();

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

    super.dispose();
  }

  // Navigation vers UserPage
  void _navigateToUserPage() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => UserPage()),
    );
  }

  // Sauvegarde des données utilisateur dans les préférences partagées
  Future<void> _saveUserDataToPrefs(SharedPreferences prefs, Map<String, dynamic> userData) async {
    print("userData: $userData");
    await prefs.setString('email', userData['email']);
    if (userData['nom'] != null) await prefs.setString('nom', userData['nom']);
    if (userData['prenom'] != null) await prefs.setString('prenom', userData['prenom']);
    if (userData['age'] != null) await prefs.setInt('age', userData['age']);
    
    if (userData['humidite_min'] != null) await prefs.setDouble('humidite_min', userData['humidite_min']);
    if (userData['humidite_max'] != null) await prefs.setDouble('humidite_max', userData['humidite_max']);

    if (userData['precipitations_min'] != null) await prefs.setDouble('precipitations_min', userData['precipitations_min']);
    if (userData['precipitations_max'] != null) await prefs.setDouble('precipitations_max', userData['precipitations_max']);

    if (userData['pression_min'] != null) await prefs.setDouble('pression_min', userData['pression_min']);
    if (userData['pression_max'] != null) await prefs.setDouble('pression_max', userData['pression_max']);

    if (userData['temperature_min'] != null) await prefs.setInt('temperature_min', userData['temperature_min']);
    if (userData['temperature_max'] != null) await prefs.setInt('temperature_max', userData['temperature_max']);

    if (userData['vent_min'] != null) await prefs.setDouble('vent_min', userData['vent_min']);
    if (userData['vent_max'] != null) await prefs.setDouble('vent_max', userData['vent_max']);

    if (userData['uv'] != null) await prefs.setInt('uv', userData['uv']);
  }

  // Gestion de la connexion utilisateur
  void _loginUser() async {
    if (_loginFormKey.currentState!.validate()) {
      _loginFormKey.currentState!.save();
      SharedPreferences prefs = await SharedPreferences.getInstance();

      try {
        final userData = await loginUser(_email, _password);
        
        final data = await getPreferencesUnit(_email);

        // Récupération de l'instance de UserPreferences fournie par le Provider
        final userPrefs = Provider.of<UserPreferences>(context, listen: false);
        userPrefs.setPreferredTemperatureUnit(
          Temperature.stringToTemperatureUnit(data['unite_temperature'])
        );
        userPrefs.setPreferredWindUnit(
          WindSpeed.stringToWindUnit(data['unite_vent'])
        );
        userPrefs.setPreferredHumidityUnit(
          Humidity.stringToHumidityUnit(data['unite_humidite'])
        );
        userPrefs.setPreferredPressureUnit(
          Pressure.stringToPressureUnit(data['unite_pression'])
        );
        userPrefs.setPreferredPrecipitationUnit(
          Precipitation.stringToPrecipitationUnit(data['unite_precipitations'])
        );

        await _saveUserDataToPrefs(prefs, userData);
        _navigateToUserPage();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Email ou mot de passe incorrect')),
        );
      }
    }
  }

  // Gestion de l'inscription utilisateur
  void _registerUser() async {
    if (_signUpFormKey.currentState!.validate()) {
      _signUpFormKey.currentState!.save();
      SharedPreferences prefs = await SharedPreferences.getInstance();

      try {
        await addUser(
          _name,
          _surname,
          _email,
          _password,
          _age,
          humidity_min: _humidity_min,
          humidity_max: _humidity_max,
          precipitation_min: _precipitation_min,
          precipitation_max: _precipitation_max,
          pressure_min: _pressure_min,
          pressure_max: _pressure_max,
          temperature_min: _temperature_min,
          temperature_max: _temperature_max,
          wind_min: _wind_min,
          wind_max: _wind_max,
          uv: _uvValue,
        );

        final userPrefs = Provider.of<UserPreferences>(context, listen: false);

        await updatePreferencesUnit(_email,
          userPrefs.preferredTemperatureUnit,
          userPrefs.preferredWindUnit,
          userPrefs.preferredHumidityUnit,
          userPrefs.preferredPressureUnit,
          userPrefs.preferredPrecipitationUnit,
        );

        final userData = await loginUser(_email, _password);
        await _saveUserDataToPrefs(prefs, userData);
        _navigateToUserPage();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erreur lors de l\'inscription')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {

    // Récupération de l'instance de UserPreferences fournie par le Provider
    final userPrefs = Provider.of<UserPreferences>(context);

    // Taille de l'écran
    final size = MediaQuery.of(context).size;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text(
          'Compte Utilisateur',
          style:
              TextStyle(fontFamily: 'Montserrat', fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue.shade700, Colors.blue.shade200],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: SizedBox(
              width: size.width * 0.85,
              height: size.height * 0.85,
              child: FlipCard(
                controller: _cardController,
                flipOnTouch: false,
                front: _buildLoginForm(),
                back: _buildSignUpForm(userPrefs),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Construction du formulaire de connexion
  Widget _buildLoginForm() {
    return Container(
      height: MediaQuery.of(context).size.height,
      alignment: Alignment.center,
      child: Card(
        elevation: 12,
        shadowColor: Colors.black38,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 36),
            child: Form(
              key: _loginFormKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildFormTitle('Connexion'),
                  const SizedBox(height: 30),
                  _buildEmailField(),
                  const SizedBox(height: 15),
                  _buildPasswordField(),
                  const SizedBox(height: 40),
                  _buildSubmitButton('Connexion', _loginUser),
                  const SizedBox(height: 20),
                  _buildToggleFormButton('Pas de compte ? Inscrivez-vous'),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Construction du formulaire d'inscription
  Widget _buildSignUpForm(UserPreferences userPrefs) {
    return Card(
      elevation: 12,
      shadowColor: Colors.black38,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 36),
          child: Form(
            key: _signUpFormKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(child: _buildFormTitle('Inscription')),
                const SizedBox(height: 30),
                _buildNameField(),
                const SizedBox(height: 20),
                _buildSurnameField(),
                const SizedBox(height: 20),
                _buildAgeField(),
                const SizedBox(height: 20),
                _buildEmailField(),
                const SizedBox(height: 20),
                _buildPasswordField(),
                const SizedBox(height: 30),
                _buildSensibilityFields(userPrefs), 
                const SizedBox(height: 30),
                Center(child: _buildSubmitButton('Inscription', _registerUser)),
                const SizedBox(height: 20),
                Center(
                  child: _buildToggleFormButton(
                    'Déjà un compte ? Connectez-vous'
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Construction des champs de sensibilité
  Widget _buildSensibilityFields(UserPreferences userPrefs) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Sensibilité aux conditions météorologiques',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.blueAccent,
          ),
        ),
        const SizedBox(height: 20),
        _buildTemperatureFields(userPrefs),
        const SizedBox(height: 20),
        _buildHumidityFields(userPrefs),
        const SizedBox(height: 20),
        _buildPressureFields(userPrefs),
        const SizedBox(height: 20),
        _buildPrecipitationFields(userPrefs),
        const SizedBox(height: 20),
        _buildWindFields(userPrefs),
        const SizedBox(height: 20),
        _buildUVField(),
      ],
    );
  }

  // Construction des champs de température
  Widget _buildTemperatureFields(UserPreferences userPrefs) {
    final tempUnit = userPrefs.preferredTemperatureUnit;
    late String tempUnitLabel;
    switch (tempUnit) {
      case TemperatureUnit.celsius:
        tempUnitLabel = '°C';
        break;
      case TemperatureUnit.fahrenheit:
        tempUnitLabel = '°F';
        break;
      case TemperatureUnit.kelvin:
        tempUnitLabel = 'K';
        break;
    }
    return Row(
      children: [
        Expanded(
          child: TextFormField(
            controller: _tempMinController,
            decoration: InputDecoration(
              labelText: 'Température min ($tempUnitLabel)',
              prefixIcon: const Icon(Icons.thermostat, color: Colors.blueAccent),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
              filled: true,
              fillColor: Colors.blue.shade50,
            ),
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value == null || value.isEmpty) return 'Requis';
              final val = int.tryParse(value);
              if (val == null || !Temperature.isValidTemperature(val, tempUnit)) {
                return 'Température invalide';
              }
              return null;
            },
            onSaved: (value) => _temperature_min = Temperature(int.parse(value!), tempUnit),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: TextFormField(
            controller: _tempMaxController,
            decoration: InputDecoration(
              labelText: 'Température max ($tempUnitLabel)',
              prefixIcon: const Icon(Icons.thermostat, color: Colors.blueAccent),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
              filled: true,
              fillColor: Colors.blue.shade50,
            ),
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value == null || value.isEmpty) return 'Requis';
              final maxVal = int.tryParse(value);
              if (maxVal == null || !Temperature.isValidTemperature(maxVal, tempUnit)) {
                return 'Température invalide';
              }

              if (_tempMinController.text.isNotEmpty) {
                final minVal = int.tryParse(_tempMinController.text);
                if (minVal != null && maxVal < minVal) {
                  return 'La température maximale doit être >= à la minimale';
                }
              }

              return null;
            },
            onSaved: (value) => _temperature_max = Temperature(int.parse(value!), tempUnit),
          ),
        ),
      ],
    );
  }

  // Construction des champs d'humidité
  Widget _buildHumidityFields(UserPreferences userPrefs) {
    final humidityUnit = userPrefs.preferredHumidityUnit;
    late String humidityUnitLabel;
    switch (humidityUnit) {
      case HumidityUnit.relative:
        humidityUnitLabel = '%';
        break;
      case HumidityUnit.absolute:
        humidityUnitLabel = 'g/m³';
        break;
    }

    return Row(
      children: [
        Expanded(
          child: TextFormField(
            controller: _humidityMinController,
            decoration: InputDecoration(
              labelText: 'Humidité min ($humidityUnitLabel)',
              prefixIcon: const Icon(Icons.water, color: Colors.blueAccent),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
              filled: true,
              fillColor: Colors.blue.shade50,
            ),
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value == null || value.isEmpty) return 'Requis';
              final val = double.tryParse(value);
              if (val == null || !Humidity.isValidHumidity(val, humidityUnit, 25)) {
                return 'Humidité invalide';
              }
              return null;
            },
            onSaved: (value) => _humidity_min = Humidity(double.parse(value!), humidityUnit),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: TextFormField(
            controller: _humidityMaxController,
            decoration: InputDecoration(
              labelText: 'Humidité max ($humidityUnitLabel)',
              prefixIcon: const Icon(Icons.water, color: Colors.blueAccent),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
              filled: true,
              fillColor: Colors.blue.shade50,
            ),
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value == null || value.isEmpty) return 'Requis';
              final maxVal = double.tryParse(value);
              if (maxVal == null || !Humidity.isValidHumidity(maxVal, humidityUnit, 25)) {
                return 'Humidité invalide';
              }

              if (_humidityMinController.text.isNotEmpty) {
                final minVal = double.tryParse(_humidityMinController.text);
                if (minVal != null && maxVal < minVal) {
                  return 'L\'humidité maximale doit être >= à la minimale';
                }
              }

              return null;
            },
            onSaved: (value) => _humidity_max = Humidity(double.parse(value!), humidityUnit),
          ),
        ),
      ],
    );
  }

  // Construction des champs de pression
  Widget _buildPressureFields(UserPreferences userPrefs) {
    final pressureUnit = userPrefs.preferredPressureUnit;
    late String pressureUnitLabel;
    switch (pressureUnit) {
      case PressureUnit.hPa:
        pressureUnitLabel = 'hPa';
        break;
      case PressureUnit.atm:
        pressureUnitLabel = 'atm';
        break;
      case PressureUnit.psi:
        pressureUnitLabel = 'psi';
        break;
      case PressureUnit.Pa:
        pressureUnitLabel = 'Pa';
        break;
      case PressureUnit.mmHg:
        pressureUnitLabel = 'mmHg';
        break;
    }

    return Row(
      children: [
        Expanded(
          child: TextFormField(
            controller: _pressureMinController,
            decoration: InputDecoration(
              labelText: 'Pression min ($pressureUnitLabel)',
              prefixIcon: const Icon(Icons.speed, color: Colors.blueAccent),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
              filled: true,
              fillColor: Colors.blue.shade50,
            ),
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value == null || value.isEmpty) return 'Requis';
              final val = double.tryParse(value);
              if (val == null || !Pressure.isValidPressure(val, pressureUnit)) {
                return 'Pression invalide';
              }
              return null;
            },
            onSaved: (value) => _pressure_min = Pressure(double.parse(value!), pressureUnit),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: TextFormField(
            controller: _pressureMaxController,
            decoration: InputDecoration(
              labelText: 'Pression max ($pressureUnitLabel)',
              prefixIcon: const Icon(Icons.speed, color: Colors.blueAccent),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
              filled: true,
              fillColor: Colors.blue.shade50,
            ),
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value == null || value.isEmpty) return 'Requis';
              final maxVal = double.tryParse(value);
              if (maxVal == null || !Pressure.isValidPressure(maxVal, pressureUnit)) {
                return 'Pression invalide';
              }

              if (_pressureMinController.text.isNotEmpty) {
                final minVal = double.tryParse(_pressureMinController.text);
                if (minVal != null && maxVal < minVal) {
                  return 'La pression maximale doit être >= à la minimale';
                }
              }

              return null;
            },
            onSaved: (value) => _pressure_max = Pressure(double.parse(value!), pressureUnit),
          ),
        ),
      ],
    );
  }

  // Construction des champs de précipitations
  Widget _buildPrecipitationFields(UserPreferences userPrefs) {
    final precipitationUnit = userPrefs.preferredPrecipitationUnit;
    late String precipitationUnitLabel;
    switch (precipitationUnit) {
      case PrecipitationUnit.mm:
        precipitationUnitLabel = 'mm';
        break;
      case PrecipitationUnit.inches:
        precipitationUnitLabel = 'inches';
        break;
      case PrecipitationUnit.litersPerSquareMeter:
        precipitationUnitLabel = 'l/m²';
        break;
    }
    return Row(
      children: [
        Expanded(
          child: TextFormField(
            controller: _precipitationMinController,
            decoration: InputDecoration(
              labelText: 'Précipitations min ($precipitationUnitLabel)',
              prefixIcon: const Icon(Icons.water, color: Colors.blueAccent),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
              filled: true,
              fillColor: Colors.blue.shade50,
            ),
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value == null || value.isEmpty) return 'Requis';
              final val = double.tryParse(value);
              if (val == null || !Precipitation.isValidPrecipitation(val, precipitationUnit)) {
                return 'Précipitations invalide';
              }
              return null;
            },
            onSaved: (value) => _precipitation_min = Precipitation(double.parse(value!), precipitationUnit),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: TextFormField(
            controller: _precipitationMaxController,
            decoration: InputDecoration(
              labelText: 'Précipitations max ($precipitationUnitLabel)',
              prefixIcon: const Icon(Icons.water, color: Colors.blueAccent),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
              filled: true,
              fillColor: Colors.blue.shade50,
            ),
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value == null || value.isEmpty) return 'Requis';
              final maxVal = double.tryParse(value);
              if (maxVal == null || !Precipitation.isValidPrecipitation(maxVal, precipitationUnit)) {
                return 'Précipitations invalide';
              }

              if (_precipitationMinController.text.isNotEmpty) {
                final minVal = double.tryParse(_precipitationMinController.text);
                if (minVal != null && maxVal < minVal) {
                  return 'Les précipitations maximales doivent être >= aux minimales';
                }
              }

              return null;
            },
            onSaved: (value) => _precipitation_max = Precipitation(double.parse(value!), precipitationUnit),
          ),
        ),
      ],
    );
  }

  // Construction des champs de vent
  Widget _buildWindFields(UserPreferences userPrefs) {
    final windUnit = userPrefs.preferredWindUnit;
    late String windUnitLabel;
    switch (windUnit) {
      case WindUnit.kmh:
        windUnitLabel = 'km/h';
        break;
      case WindUnit.ms:
        windUnitLabel = 'm/s';
        break;
      case WindUnit.mph:
        windUnitLabel = 'mph';
        break;
      case WindUnit.fts:
        windUnitLabel = 'ft/s';
        break;
      case WindUnit.knots:
        windUnitLabel = 'nœuds';
        break;
    }
    return Row(
      children: [
        Expanded(
          child: TextFormField(
            controller: _windMinController,
            decoration: InputDecoration(
              labelText: 'Vitesse du vent min ($windUnitLabel)',
              prefixIcon: const Icon(Icons.air, color: Colors.blueAccent),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
              filled: true,
              fillColor: Colors.blue.shade50,
            ),
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value == null || value.isEmpty) return 'Requis';
              final val = int.tryParse(value);
              if (val == null || !WindSpeed.isValidWindSpeed(val, windUnit)) {
                return 'Vitesse du vent invalide';
              }
              return null;
            },
            onSaved: (value) => _wind_min = WindSpeed(int.parse(value!), windUnit),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: TextFormField(
            controller: _windMaxController,
            decoration: InputDecoration(
              labelText: 'Vitesse du vent max ($windUnitLabel)',
              prefixIcon: const Icon(Icons.air, color: Colors.blueAccent),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
              filled: true,
              fillColor: Colors.blue.shade50,
            ),
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value == null || value.isEmpty) return 'Requis';
              final maxVal = int.tryParse(value);
              if (maxVal == null || !WindSpeed.isValidWindSpeed(maxVal, windUnit)) {
                return 'Vitesse du vent invalide';
              }

              if (_windMinController.text.isNotEmpty) {
                final minVal = double.tryParse(_windMinController.text);
                if (minVal != null && maxVal < minVal) {
                  return 'La vitesse du vent maximale doit être >= à la minimale';
                }
              }

              return null;
            },
            onSaved: (value) => _wind_max = WindSpeed(int.parse(value!), windUnit),
          ),
        ),
      ],
    );
  }

  // Construction du champ d'UV
  Widget _buildUVField() {
    return TextFormField(
      decoration: InputDecoration(
        labelText: 'UV',
        errorMaxLines: 2,
        prefixIcon: const Icon(Icons.wb_sunny, color: Colors.blueAccent),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
        filled: true,
        fillColor: Colors.blue.shade50,
      ),
      keyboardType: TextInputType.number,
      validator: (value) {
        if (value == null || value.isEmpty) return 'Requis';
        if (!UV.isValidUV(int.parse(value))) {
          return 'UV invalide';
        }
        return null;
      },
      onSaved: (value) => _uvValue = UV(double.parse(value!)),
    );
  }

  // Fonctions communes pour le formulaire de connexion et d'inscription
  Widget _buildAgeField() {
    return TextFormField(
      decoration: InputDecoration(
        labelText: 'Âge',
        errorMaxLines: 2,
        prefixIcon: const Icon(Icons.cake, color: Colors.blueAccent),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
        filled: true,
        fillColor: Colors.blue.shade50,
      ),
      validator: (value) {
        if (value == null || value.isEmpty) return 'Veuillez entrer un âge';
        if (!Age.isValidAge(int.parse(value))) {
          return 'L\'âge doit être compris entre 0 et 120 ans';
        }
        return null;
      },
      onSaved: (value) => _age = Age(int.parse(value!)),
    );
  }

  Widget _buildFormTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        fontFamily: 'Montserrat',
        color: Colors.blueAccent,
      ),
    );
  }

  Widget _buildEmailField() {
    return TextFormField(
      decoration: InputDecoration(
        labelText: 'Email',
        errorMaxLines: 2,
        prefixIcon: const Icon(Icons.email, color: Colors.blueAccent),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
        filled: true,
        fillColor: Colors.blue.shade50,
      ),
      validator: (value) {
        if (value == null || value.isEmpty) return 'Veuillez entrer un email';
        if (!Email.isValidEmail(Email(value))) {
          return 'Format d\'email invalide. Exemple : exemple@domaine.com';
        }
        return null;
      },
      onSaved: (value) => _email = Email(value!),
    );
  }

  Widget _buildPasswordField() {
    return TextFormField(
      decoration: InputDecoration(
        labelText: 'Mot de passe',
        errorMaxLines: 3,
        prefixIcon: const Icon(Icons.lock, color: Colors.blueAccent),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
        filled: true,
        fillColor: Colors.blue.shade50,
      ),
      obscureText: true,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Veuillez entrer un mot de passe';
        }
        if (!Password.isValidPassword(Password(value))) {
          return 'Le mot de passe doit comporter au moins 8 caractères, une majuscule, une minuscule, un chiffre et un caractère spécial.\nExemple : Abcdef1!';
        }
        return null;
      },
      onSaved: (value) => _password = Password(value!),
    );
  }

  Widget _buildNameField() {
    return TextFormField(
      decoration: InputDecoration(
        labelText: 'Prénom',
        errorMaxLines: 2,
        prefixIcon: const Icon(Icons.person, color: Colors.blueAccent),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
        filled: true,
        fillColor: Colors.blue.shade50,
      ),
      validator: (value) {
        if (value == null || value.isEmpty) return 'Veuillez entrer un prénom';
        if (!FName.isValidFName(value)) {
          return 'Le prénom doit comporter au moins 2 lettres';
        }
        return null;
      },
      onSaved: (value) => _name = FName(value!),
    );
  }

  Widget _buildSurnameField() {
    return TextFormField(
      decoration: InputDecoration(
        labelText: 'Nom',
        errorMaxLines: 2,
        prefixIcon: const Icon(Icons.person, color: Colors.blueAccent),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
        filled: true,
        fillColor: Colors.blue.shade50,
      ),
      validator: (value) {
        if (value == null || value.isEmpty) return 'Veuillez entrer un nom';
        if (!LName.isValidLName(value)) {
          return 'Le nom doit comporter au moins 2 lettres';
        }
        return null;
      },
      onSaved: (value) => _surname = LName(value!),
    );
  }

  Widget _buildSubmitButton(String label, VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 80, vertical: 18),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
        backgroundColor: Colors.blueAccent,
        elevation: 5,
        shadowColor: Colors.black38,
      ),
      child: Text(
        label,
        style: const TextStyle(
            fontSize: 20, fontFamily: 'Montserrat', color: Colors.white),
      ),
    );
  }

  Widget _buildToggleFormButton(String label) {
    return TextButton(
      onPressed: () => _cardController.toggleCard(),
      child: Text(
        label,
        style: const TextStyle(
            fontSize: 16, color: Colors.blueAccent, fontFamily: 'Montserrat'),
      ),
    );
  }
}
