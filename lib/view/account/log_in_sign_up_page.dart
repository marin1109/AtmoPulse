import 'package:flutter/material.dart';
import 'package:flip_card/flip_card.dart';
import 'package:flip_card/flip_card_controller.dart';
import 'package:provider/provider.dart';

import '../../services/account_service.dart';

// Types (email, password, etc.)
import '../../types/common/email.dart';
import '../../types/common/password.dart';
import '../../types/common/lname.dart';
import '../../types/common/fname.dart';
import '../../types/common/age.dart';
import '../../types/weather/temperature.dart';
import '../../types/weather/humidity.dart';
import '../../types/weather/precipitation.dart';
import '../../types/weather/wind_speed.dart';
import '../../types/weather/uv.dart';

// Page imports
import 'user_page.dart';

// UserPreferences
import '../../utils/user_preferences.dart';

class LSPage extends StatefulWidget {
  const LSPage({super.key});

  @override
  _LSPageState createState() => _LSPageState();
}

class _LSPageState extends State<LSPage> with SingleTickerProviderStateMixin {
  // ================
  // Clés des formulaires
  // ================
  final _loginFormKey = GlobalKey<FormState>();
  final _signUpFormKey = GlobalKey<FormState>();

  // ================
  // Données pour le login
  // ================
  late Email _email;
  late Password _password;

  // ================
  // Données pour le signup
  // ================
  late FName _name;
  late LName _surname;
  late Age _age;

  // Sensibilités (signup)
  late Humidity _humidity_min;
  late Humidity _humidity_max;
  late Precipitation _precipitation_min;
  late Precipitation _precipitation_max;
  late Temperature _temperature_min;
  late Temperature _temperature_max;
  late WindSpeed _wind_min;
  late WindSpeed _wind_max;
  late UV _uvValue;

  final FlipCardController _cardController = FlipCardController();

  // Contrôleurs de texte pour la saisie de valeurs
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

  // ==============================
  // Navigation vers UserPage
  // ==============================
  void _navigateToUserPage() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const UserPage()),
    );
  }

  // ==============================
  // Connexion utilisateur
  // ==============================
  void _loginUser() async {
    if (_loginFormKey.currentState!.validate()) {
      _loginFormKey.currentState!.save();

      final userPrefs = Provider.of<UserPreferences>(context, listen: false);

      try {
        final userData = await loginUser(_email, _password);

        final data = await getPreferencesUnit(_email);

        await userPrefs.setPreferredTemperatureUnit(
          Temperature.stringToTemperatureUnit(data['unite_temperature']),
        );
        await userPrefs.setPreferredWindUnit(
          WindSpeed.stringToWindUnit(data['unite_vent']),
        );
        await userPrefs.setPreferredHumidityUnit(
          Humidity.stringToHumidityUnit(data['unite_humidite']),
        );
        await userPrefs.setPreferredPrecipitationUnit(
          Precipitation.stringToPrecipitationUnit(data['unite_precipitations']),
        );

        // 4. Mémoriser qu'on est loggé
        await userPrefs.setIsLogged(true);

        // 5. Sauvegarde des infos perso
        await userPrefs.setEmail(userData['email']);
        if (userData['nom'] != null) {
          await userPrefs.setNom(userData['nom']);
        }
        if (userData['prenom'] != null) {
          await userPrefs.setPrenom(userData['prenom']);
        }
        if (userData['age'] != null) {
          await userPrefs.setAge(userData['age']);
        }

        if (userData['temperature_min'] != null) {
          await userPrefs.setTempMin(userData['temperature_min'].toInt());
        }
        if (userData['temperature_max'] != null) {
          await userPrefs.setTempMax(userData['temperature_max'].toInt());
        }
        if (userData['humidite_min'] != null) {
          await userPrefs.setHumidityMin(userData['humidite_min'].toDouble());
        }
        if (userData['humidite_max'] != null) {
          await userPrefs.setHumidityMax(userData['humidite_max'].toDouble());
        }
        if (userData['precipitations_min'] != null) {
          await userPrefs
              .setPrecipMin(userData['precipitations_min'].toDouble());
        }
        if (userData['precipitations_max'] != null) {
          await userPrefs
              .setPrecipMax(userData['precipitations_max'].toDouble());
        }
        if (userData['vent_min'] != null) {
          await userPrefs.setWindMin(userData['vent_min'].toInt());
        }
        if (userData['vent_max'] != null) {
          await userPrefs.setWindMax(userData['vent_max'].toInt());
        }
        if (userData['uv'] != null) {
          await userPrefs.setUV(userData['uv'].toDouble());
        }

        _navigateToUserPage();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Email ou mot de passe incorrect')),
        );
      }
    }
  }

  // ==============================
  // Inscription utilisateur
  // ==============================
  void _registerUser() async {
    if (_signUpFormKey.currentState!.validate()) {
      _signUpFormKey.currentState!.save();

      final userPrefs = Provider.of<UserPreferences>(context, listen: false);

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
          temperature_min: _temperature_min,
          temperature_max: _temperature_max,
          wind_min: _wind_min,
          wind_max: _wind_max,
          uv: _uvValue,
        );

        await updatePreferencesUnit(
          _email,
          userPrefs.preferredTemperatureUnit,
          userPrefs.preferredWindUnit,
          userPrefs.preferredHumidityUnit,
          userPrefs.preferredPrecipitationUnit,
        );

        final userData = await loginUser(_email, _password);

        await userPrefs.setEmail(userData['email'] ?? '');
        await userPrefs.setNom(userData['nom'] ?? '');
        await userPrefs.setPrenom(userData['prenom'] ?? '');
        await userPrefs.setAge(userData['age'] ?? 0);
        await userPrefs.setIsLogged(true);

        if (userData['temperature_min'] != null) {
          await userPrefs.setTempMin(userData['temperature_min'].toInt());
        }
        if (userData['temperature_max'] != null) {
          await userPrefs.setTempMax(userData['temperature_max'].toInt());
        }
        if (userData['humidite_min'] != null) {
          await userPrefs.setHumidityMin(userData['humidite_min'].toDouble());
        }
        if (userData['humidite_max'] != null) {
          await userPrefs.setHumidityMax(userData['humidite_max'].toDouble());
        }
        if (userData['precipitations_min'] != null) {
          await userPrefs
              .setPrecipMin(userData['precipitations_min'].toDouble());
        }
        if (userData['precipitations_max'] != null) {
          await userPrefs
              .setPrecipMax(userData['precipitations_max'].toDouble());
        }
        if (userData['vent_min'] != null) {
          await userPrefs.setWindMin(userData['vent_min'].toInt());
        }
        if (userData['vent_max'] != null) {
          await userPrefs.setWindMax(userData['vent_max'].toInt());
        }
        if (userData['uv'] != null) {
          await userPrefs.setUV(userData['uv'].toDouble());
        }

        // 6. Navigation
        _navigateToUserPage();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erreur lors de l\'inscription')),
        );
      }
    }
  }

  // ==============================
  // UI
  // ==============================
  @override
  Widget build(BuildContext context) {
    final userPrefs = Provider.of<UserPreferences>(context);

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

  // ==============================
  // Formulaire de connexion
  // ==============================
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

  // ==============================
  // Formulaire d'inscription
  // ==============================
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
                  child:
                      _buildToggleFormButton('Déjà un compte ? Connectez-vous'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ==============================
  // Sensibilité
  // ==============================
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
        _buildPrecipitationFields(userPrefs),
        const SizedBox(height: 20),
        _buildWindFields(userPrefs),
        const SizedBox(height: 20),
        _buildUVField(),
      ],
    );
  }

  // ==============================
  // Champs de température
  // ==============================
  Widget _buildTemperatureFields(UserPreferences userPrefs) {
    final tempUnit = userPrefs.preferredTemperatureUnit;
    final tempUnitLabel = Temperature.unitToString(tempUnit);

    return Column(
      children: [
        TextFormField(
          controller: _tempMinController,
          decoration: InputDecoration(
            labelText: 'Température min ($tempUnitLabel)',
            prefixIcon: const Icon(Icons.thermostat, color: Colors.blueAccent),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            filled: true,
            fillColor: Colors.blue.shade50,
          ),
          keyboardType: TextInputType.number,
          validator: (value) {
            if (value == null || value.isEmpty) return 'Requis';
            final val = int.tryParse(value);
            if (val == null || !Temperature.isValidTemperature(val, tempUnit)) {
              return 'Température comprise entre ${Temperature.minTemperature} et ${Temperature.maxTemperature}';
            }
            return null;
          },
          onSaved: (value) {
            if (value != null) {
              _temperature_min = Temperature(int.parse(value), tempUnit);
            }
          },
        ),
        const SizedBox(height: 10),
        TextFormField(
          controller: _tempMaxController,
          decoration: InputDecoration(
            labelText: 'Température max ($tempUnitLabel)',
            prefixIcon: const Icon(Icons.thermostat, color: Colors.blueAccent),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            filled: true,
            fillColor: Colors.blue.shade50,
          ),
          keyboardType: TextInputType.number,
          validator: (value) {
            if (value == null || value.isEmpty) return 'Requis';
            final maxVal = int.tryParse(value);
            if (maxVal == null || !Temperature.isValidTemperature(maxVal, tempUnit)) {
              return 'Température comprise entre ${Temperature.minTemperature} et ${Temperature.maxTemperature}';
            }
            if (_tempMinController.text.isNotEmpty) {
              final minVal = int.tryParse(_tempMinController.text);
              if (minVal != null && maxVal < minVal) {
                return 'La température max doit être >= à la min';
              }
            }
            return null;
          },
          onSaved: (value) {
            if (value != null) {
              _temperature_max = Temperature(int.parse(value), tempUnit);
            }
          },
        ),
      ],
    );
  }

  // ==============================
  // Champs d'humidité
  // ==============================
  Widget _buildHumidityFields(UserPreferences userPrefs) {
    final humidityUnit = userPrefs.preferredHumidityUnit;
    final humidityUnitLabel = Humidity.unitToString(humidityUnit);

    return Column(
      children: [
        TextFormField(
          controller: _humidityMinController,
          decoration: InputDecoration(
            labelText: 'Humidité min ($humidityUnitLabel)',
            prefixIcon: const Icon(Icons.water, color: Colors.blueAccent),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            filled: true,
            fillColor: Colors.blue.shade50,
          ),
          keyboardType: TextInputType.number,
          validator: (value) {
            if (value == null || value.isEmpty) return 'Requis';
            final intVal = int.tryParse(value);
            if (intVal == null ||
                !Humidity.isValidHumidity(intVal, humidityUnit, 25)) {
              return 'Humidité comprise entre ${Humidity.minHumidity} et ${Humidity.maxHumidity}';
            }
            return null;
          },
          onSaved: (value) {
            if (value != null) {
              _humidity_min = Humidity(int.parse(value), humidityUnit);
            }
          },
        ),
        const SizedBox(height: 10),
        TextFormField(
          controller: _humidityMaxController,
          decoration: InputDecoration(
            labelText: 'Humidité max ($humidityUnitLabel)',
            prefixIcon: const Icon(Icons.water, color: Colors.blueAccent),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            filled: true,
            fillColor: Colors.blue.shade50,
          ),
          keyboardType: TextInputType.number,
          validator: (value) {
            if (value == null || value.isEmpty) return 'Requis';
            final maxVal = int.tryParse(value);
            if (maxVal == null ||
                !Humidity.isValidHumidity(maxVal, humidityUnit, 25)) {
              return 'Humidité comprise entre ${Humidity.minHumidity} et ${Humidity.maxHumidity}';
            }
            if (_humidityMinController.text.isNotEmpty) {
              final minVal = int.tryParse(_humidityMinController.text);
              if (minVal != null && maxVal < minVal) {
                return 'L\'humidité max doit être >= à la min';
              }
            }
            return null;
          },
          onSaved: (value) {
            if (value != null) {
              _humidity_max = Humidity(int.parse(value), humidityUnit);
            }
          },
        ),
      ],
    );
  }

  // ==============================
  // Champs de précipitations
  // ==============================
  Widget _buildPrecipitationFields(UserPreferences userPrefs) {
    final precipitationUnit = userPrefs.preferredPrecipitationUnit;
    final precipitationUnitLabel = Precipitation.unitToString(precipitationUnit);

    return Column(
      children: [
        TextFormField(
          controller: _precipitationMinController,
          decoration: InputDecoration(
            labelText: 'Précipitations min ($precipitationUnitLabel)',
            prefixIcon: const Icon(Icons.water, color: Colors.blueAccent),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            filled: true,
            fillColor: Colors.blue.shade50,
          ),
          keyboardType: TextInputType.number,
          validator: (value) {
            if (value == null || value.isEmpty) return 'Requis';
            final val = int.tryParse(value);
            if (val == null || 
                !Precipitation.isValidPrecipitation(val, precipitationUnit)) {
              return 'Compris entre ${Precipitation.minPrecipitation} et ${Precipitation.maxPrecipitation}';
            }
            return null;
          },
          onSaved: (value) {
            if (value != null) {
              _precipitation_min = Precipitation(int.parse(value), precipitationUnit);
            }
          },
        ),
        const SizedBox(height: 10),
        TextFormField(
          controller: _precipitationMaxController,
          decoration: InputDecoration(
            labelText: 'Précipitations max ($precipitationUnitLabel)',
            prefixIcon: const Icon(Icons.water, color: Colors.blueAccent),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            filled: true,
            fillColor: Colors.blue.shade50,
          ),
          keyboardType: TextInputType.number,
          validator: (value) {
            if (value == null || value.isEmpty) return 'Requis';
            final maxVal = int.tryParse(value);
            if (maxVal == null ||
                !Precipitation.isValidPrecipitation(maxVal, precipitationUnit)) {
              return 'Compris entre ${Precipitation.minPrecipitation} et ${Precipitation.maxPrecipitation}';
            }
            if (_precipitationMinController.text.isNotEmpty) {
              final minVal = double.tryParse(_precipitationMinController.text);
              if (minVal != null && maxVal <= minVal) {
                return 'Les précipitations max doivent être > min';
              }
            }
            return null;
          },
          onSaved: (value) {
            if (value != null) {
              _precipitation_max = Precipitation(int.parse(value), precipitationUnit);
            }
          },
        ),
      ],
    );
  }

  // ==============================
  // Champs de vent
  // ==============================
  Widget _buildWindFields(UserPreferences userPrefs) {
    final windUnit = userPrefs.preferredWindUnit;
    final windUnitLabel = WindSpeed.unitToString(windUnit);

    return Column(
      children: [
        TextFormField(
          controller: _windMinController,
          decoration: InputDecoration(
            labelText: 'Vitesse du vent min ($windUnitLabel)',
            prefixIcon: const Icon(Icons.air, color: Colors.blueAccent),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            filled: true,
            fillColor: Colors.blue.shade50,
          ),
          keyboardType: TextInputType.number,
          validator: (value) {
            if (value == null || value.isEmpty) return 'Requis';
            final val = int.tryParse(value);
            if (val == null || !WindSpeed.isValidWindSpeed(val, windUnit)) {
              return 'Vitesse du vent comprise entre ${WindSpeed.minWindSpeed} et ${WindSpeed.maxWindSpeed}';
            }
            return null;
          },
          onSaved: (value) {
            if (value != null) {
              _wind_min = WindSpeed(int.parse(value), windUnit);
            }
          },
        ),
        const SizedBox(height: 10),
        TextFormField(
          controller: _windMaxController,
          decoration: InputDecoration(
            labelText: 'Vitesse du vent max ($windUnitLabel)',
            prefixIcon: const Icon(Icons.air, color: Colors.blueAccent),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            filled: true,
            fillColor: Colors.blue.shade50,
          ),
          keyboardType: TextInputType.number,
          validator: (value) {
            if (value == null || value.isEmpty) return 'Requis';
            final maxVal = int.tryParse(value);
            if (maxVal == null || !WindSpeed.isValidWindSpeed(maxVal, windUnit)) {
              return 'Vitesse du vent comprise entre ${WindSpeed.minWindSpeed} et ${WindSpeed.maxWindSpeed}';
            }
            if (_windMinController.text.isNotEmpty) {
              final minVal = int.tryParse(_windMinController.text);
              if (minVal != null && maxVal < minVal) {
                return 'La vitesse du vent max doit être >= à la min';
              }
            }
            return null;
          },
          onSaved: (value) {
            if (value != null) {
              _wind_max = WindSpeed(int.parse(value), windUnit);
            }
          },
        ),
      ],
    );
  }

  // ==============================
  // Champ d'UV
  // ==============================
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

        final uv = UV(int.parse(value));
        if (!uv.isValid()) {
          return 'UV doit être compris entre ${UV.minUV} et ${UV.maxUV}';
        }
        return null;
      },
      onSaved: (value) => _uvValue = UV(int.parse(value!)),
    );
  }

  // ==============================
  // Champs communs
  // ==============================
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
        if (!Age(int.parse(value)).isValid()) {
          return 'L\'âge doit être entre ${Age.minAge} et ${Age.maxAge}';
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

        final email = Email(value);
        if (!email.isValid()) {
          return 'Format d\'email invalide (ex: exemple@domaine.com)';
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

        final password = Password(value);
        if (!password.isValid()) {
          return 'Le mot de passe doit contenir au moins 8 caractères, '
              'dont une majuscule, une minuscule, un chiffre et un caractère spécial.';
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

        if (!FName(value).isValid()) {
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

        if (!LName(value).isValid()) {
          return 'Le nom doit comporter au moins 2 lettres';
        }
        return null;
      },
      onSaved: (value) => _surname = LName(value!),
    );
  }

  // ==============================
  // Boutons
  // ==============================
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
          fontSize: 20,
          fontFamily: 'Montserrat',
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildToggleFormButton(String label) {
    return TextButton(
      onPressed: () => _cardController.toggleCard(),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 16,
          color: Colors.blueAccent,
          fontFamily: 'Montserrat',
        ),
      ),
    );
  }
}
