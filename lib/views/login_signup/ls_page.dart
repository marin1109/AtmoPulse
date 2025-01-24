import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Packages externes
import 'package:flip_card/flip_card.dart';
import 'package:flip_card/flip_card_controller.dart';

// Contrôleur
import '../../../controllers/ls_controller.dart';

// Utils
import '../../../utils/user_preferences.dart';

// Types
import '../../../types/common/email.dart';
import '../../../types/common/password.dart';
import '../../../types/common/lname.dart';
import '../../../types/common/fname.dart';
import '../../../types/common/age.dart';
import '../../../types/weather/temperature.dart';
import '../../../types/weather/humidity.dart';
import '../../../types/weather/precipitation.dart';
import '../../../types/weather/wind_speed.dart';
import '../../../types/weather/uv.dart';

class LSPage extends StatefulWidget {
  const LSPage({super.key});

  @override
  _LSPageState createState() => _LSPageState();
}

class _LSPageState extends State<LSPage> with SingleTickerProviderStateMixin {
  // Clés de formulaire
  final _loginFormKey = GlobalKey<FormState>();
  final _signUpFormKey = GlobalKey<FormState>();

  // Contrôleur dédié au login/signup
  late LSController _lsController;

  // Contrôleur pour la flip card
  final FlipCardController _cardController = FlipCardController();

  // Contrôleurs de texte pour les sensibilités
  final _tempMinController = TextEditingController();
  final _tempMaxController = TextEditingController();
  final _humidityMinController = TextEditingController();
  final _humidityMaxController = TextEditingController();
  final _precipitationMinController = TextEditingController();
  final _precipitationMaxController = TextEditingController();
  final _windMinController = TextEditingController();
  final _windMaxController = TextEditingController();
  final _uvController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // On instancie ici le contrôleur
    _lsController = LSController(
      loginFormKey: _loginFormKey,
      signUpFormKey: _signUpFormKey,
    );
  }

  @override
  void dispose() {
    _tempMinController.dispose();
    _tempMaxController.dispose();
    _humidityMinController.dispose();
    _humidityMaxController.dispose();
    _precipitationMinController.dispose();
    _precipitationMaxController.dispose();
    _windMinController.dispose();
    _windMaxController.dispose();
    _uvController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userPrefs = Provider.of<UserPreferences>(context);
    final size = MediaQuery.of(context).size;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text(
          'Compte Utilisateur',
          style: TextStyle(
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Container(
        // Un simple dégradé en fond
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

  // =============================
  //            LOGIN
  // =============================
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
                children: [
                  _buildFormTitle('Connexion'),
                  const SizedBox(height: 30),
                  _buildEmailField(isLogin: true),
                  const SizedBox(height: 15),
                  _buildPasswordField(isLogin: true),
                  const SizedBox(height: 40),
                  _buildSubmitButton(
                    'Connexion',
                    () => _lsController.loginUser(context),
                  ),
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

  // =============================
  //          INSCRIPTION
  // =============================
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
                Center(
                  child: _buildSubmitButton(
                    'Inscription',
                    () => _lsController.registerUser(context),
                  ),
                ),
                const SizedBox(height: 20),
                Center(
                  child: _buildToggleFormButton(
                    'Déjà un compte ? Connectez-vous',
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // =============================
  //         FACTORISATION
  // =============================
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

  // =============================
  //       CHAMP GÉNÉRIQUE
  // =============================
  Widget _buildFormTextField({
    required String labelText,
    required IconData prefixIcon,
    required String? Function(String?) validator,
    required void Function(String?) onSaved,
    TextEditingController? controller,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: labelText,
        errorMaxLines: 3,
        prefixIcon: Icon(prefixIcon, color: Colors.blueAccent),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
        filled: true,
        fillColor: Colors.blue.shade50,
      ),
      obscureText: obscureText,
      keyboardType: keyboardType,
      validator: validator,
      onSaved: onSaved,
    );
  }

  // =============================
  //      CHAMPS SPÉCIFIQUES
  // =============================
  Widget _buildEmailField({bool isLogin = false}) {
    return _buildFormTextField(
      labelText: 'Email',
      prefixIcon: Icons.email,
      keyboardType: TextInputType.emailAddress,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Veuillez entrer un email';
        }
        if (!Email(value).isValid()) {
          return 'Format d\'email invalide (ex: exemple@domaine.com)';
        }
        return null;
      },
      onSaved: (value) {
        if (value == null) return;
        _lsController.email = Email(value);
      },
    );
  }

  Widget _buildPasswordField({bool isLogin = false}) {
    return _buildFormTextField(
      labelText: 'Mot de passe',
      prefixIcon: Icons.lock,
      obscureText: true,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Veuillez entrer un mot de passe';
        }
        if (!Password(value).isValid()) {
          return 'Le mot de passe doit contenir au moins 8 caractères, '
              'dont une majuscule, une minuscule, un chiffre et un caractère spécial.';
        }
        return null;
      },
      onSaved: (value) {
        if (value == null) return;
        _lsController.password = Password(value);
      },
    );
  }

  Widget _buildNameField() {
    return _buildFormTextField(
      labelText: 'Prénom',
      prefixIcon: Icons.person,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Veuillez entrer un prénom';
        }
        if (!FName(value).isValid()) {
          return 'Le prénom doit comporter au moins 2 lettres';
        }
        return null;
      },
      onSaved: (value) {
        if (value == null) return;
        _lsController.name = FName(value);
      },
    );
  }

  Widget _buildSurnameField() {
    return _buildFormTextField(
      labelText: 'Nom',
      prefixIcon: Icons.person,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Veuillez entrer un nom';
        }
        if (!LName(value).isValid()) {
          return 'Le nom doit comporter au moins 2 lettres';
        }
        return null;
      },
      onSaved: (value) {
        if (value == null) return;
        _lsController.surname = LName(value);
      },
    );
  }

  Widget _buildAgeField() {
    return _buildFormTextField(
      labelText: 'Âge',
      prefixIcon: Icons.cake,
      keyboardType: TextInputType.number,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Veuillez entrer un âge';
        }
        final ageInt = int.tryParse(value);
        if (ageInt == null || !Age(ageInt).isValid()) {
          return 'Âge doit être entre ${Age.minAge} et ${Age.maxAge}';
        }
        return null;
      },
      onSaved: (value) {
        if (value == null) return;
        _lsController.ageValue = Age(int.parse(value));
      },
    );
  }

  // =============================
  //   SENSIBILITÉS (signup)
  // =============================
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

  Widget _buildTemperatureFields(UserPreferences userPrefs) {
    final tempUnit = userPrefs.preferredTemperatureUnit;
    final tempUnitLabel = Temperature.unitToString(tempUnit);

    return Column(
      children: [
        _buildFormTextField(
          labelText: 'Température min ($tempUnitLabel)',
          prefixIcon: Icons.thermostat,
          keyboardType: TextInputType.number,
          controller: _tempMinController,
          validator: (value) {
            if (value == null || value.isEmpty) return 'Requis';
            final val = int.tryParse(value);
            if (val == null || !Temperature.isValidTemperature(val, tempUnit)) {
              return 'Entre ${Temperature.minTemperature} et ${Temperature.maxTemperature}';
            }
            return null;
          },
          onSaved: (value) {
            if (value == null) return;
            _lsController.temperatureMin = Temperature(int.parse(value), tempUnit);
          },
        ),
        const SizedBox(height: 10),
        _buildFormTextField(
          labelText: 'Température max ($tempUnitLabel)',
          prefixIcon: Icons.thermostat,
          keyboardType: TextInputType.number,
          controller: _tempMaxController,
          validator: (value) {
            if (value == null || value.isEmpty) return 'Requis';
            final maxVal = int.tryParse(value);
            if (maxVal == null || !Temperature.isValidTemperature(maxVal, tempUnit)) {
              return 'Entre ${Temperature.minTemperature} et ${Temperature.maxTemperature}';
            }
            // Vérifie min < max
            if (_tempMinController.text.isNotEmpty) {
              final minVal = int.tryParse(_tempMinController.text);
              if (minVal != null && maxVal < minVal) {
                return 'La température max doit être >= min';
              }
            }
            return null;
          },
          onSaved: (value) {
            if (value == null) return;
            _lsController.temperatureMax = Temperature(int.parse(value), tempUnit);
          },
        ),
      ],
    );
  }

  Widget _buildHumidityFields(UserPreferences userPrefs) {
    final humidityUnit = userPrefs.preferredHumidityUnit;
    final humidityUnitLabel = Humidity.unitToString(humidityUnit);

    return Column(
      children: [
        _buildFormTextField(
          labelText: 'Humidité min ($humidityUnitLabel)',
          prefixIcon: Icons.water,
          keyboardType: TextInputType.number,
          controller: _humidityMinController,
          validator: (value) {
            if (value == null || value.isEmpty) return 'Requis';
            final val = int.tryParse(value);
            if (val == null || !Humidity.isValidHumidity(val, humidityUnit, 25)) {
              return 'Entre ${Humidity.minHumidity} et ${Humidity.maxHumidity}';
            }
            return null;
          },
          onSaved: (value) {
            if (value == null) return;
            _lsController.humidityMin = Humidity(int.parse(value), humidityUnit);
          },
        ),
        const SizedBox(height: 10),
        _buildFormTextField(
          labelText: 'Humidité max ($humidityUnitLabel)',
          prefixIcon: Icons.water,
          keyboardType: TextInputType.number,
          controller: _humidityMaxController,
          validator: (value) {
            if (value == null || value.isEmpty) return 'Requis';
            final maxVal = int.tryParse(value);
            if (maxVal == null || !Humidity.isValidHumidity(maxVal, humidityUnit, 25)) {
              return 'Entre ${Humidity.minHumidity} et ${Humidity.maxHumidity}';
            }
            // Vérifie min < max
            if (_humidityMinController.text.isNotEmpty) {
              final minVal = int.tryParse(_humidityMinController.text);
              if (minVal != null && maxVal < minVal) {
                return 'L\'humidité max doit être >= min';
              }
            }
            return null;
          },
          onSaved: (value) {
            if (value == null) return;
            _lsController.humidityMax = Humidity(int.parse(value), humidityUnit);
          },
        ),
      ],
    );
  }

  Widget _buildPrecipitationFields(UserPreferences userPrefs) {
    final precipitationUnit = userPrefs.preferredPrecipitationUnit;
    final precipitationUnitLabel = Precipitation.unitToString(precipitationUnit);

    return Column(
      children: [
        _buildFormTextField(
          labelText: 'Précipitations min ($precipitationUnitLabel)',
          prefixIcon: Icons.water,
          keyboardType: TextInputType.number,
          controller: _precipitationMinController,
          validator: (value) {
            if (value == null || value.isEmpty) return 'Requis';
            final val = int.tryParse(value);
            if (val == null || !Precipitation.isValidPrecipitation(val, precipitationUnit)) {
              return 'Entre ${Precipitation.minPrecipitation} et ${Precipitation.maxPrecipitation}';
            }
            return null;
          },
          onSaved: (value) {
            if (value == null) return;
            _lsController.precipitationMin = Precipitation(int.parse(value), precipitationUnit);
          },
        ),
        const SizedBox(height: 10),
        _buildFormTextField(
          labelText: 'Précipitations max ($precipitationUnitLabel)',
          prefixIcon: Icons.water,
          keyboardType: TextInputType.number,
          controller: _precipitationMaxController,
          validator: (value) {
            if (value == null || value.isEmpty) return 'Requis';
            final maxVal = int.tryParse(value);
            if (maxVal == null || !Precipitation.isValidPrecipitation(maxVal, precipitationUnit)) {
              return 'Entre ${Precipitation.minPrecipitation} et ${Precipitation.maxPrecipitation}';
            }
            // Vérifie min < max
            if (_precipitationMinController.text.isNotEmpty) {
              final minVal = int.tryParse(_precipitationMinController.text);
              if (minVal != null && maxVal < minVal) {
                return 'La précipitation max doit être >= min';
              }
            }
            return null;
          },
          onSaved: (value) {
            if (value == null) return;
            _lsController.precipitationMax = Precipitation(int.parse(value), precipitationUnit);
          },
        ),
      ],
    );
  }

  Widget _buildWindFields(UserPreferences userPrefs) {
    final windUnit = userPrefs.preferredWindUnit;
    final windUnitLabel = WindSpeed.unitToString(windUnit);

    return Column(
      children: [
        _buildFormTextField(
          labelText: 'Vitesse du vent min ($windUnitLabel)',
          prefixIcon: Icons.air,
          keyboardType: TextInputType.number,
          controller: _windMinController,
          validator: (value) {
            if (value == null || value.isEmpty) return 'Requis';
            final val = int.tryParse(value);
            if (val == null || !WindSpeed.isValidWindSpeed(val, windUnit)) {
              return 'Entre ${WindSpeed.minWindSpeed} et ${WindSpeed.maxWindSpeed}';
            }
            return null;
          },
          onSaved: (value) {
            if (value == null) return;
            _lsController.windMin = WindSpeed(int.parse(value), windUnit);
          },
        ),
        const SizedBox(height: 10),
        _buildFormTextField(
          labelText: 'Vitesse du vent max ($windUnitLabel)',
          prefixIcon: Icons.air,
          keyboardType: TextInputType.number,
          controller: _windMaxController,
          validator: (value) {
            if (value == null || value.isEmpty) return 'Requis';
            final maxVal = int.tryParse(value);
            if (maxVal == null || !WindSpeed.isValidWindSpeed(maxVal, windUnit)) {
              return 'Entre ${WindSpeed.minWindSpeed} et ${WindSpeed.maxWindSpeed}';
            }
            // Vérifie min < max
            if (_windMinController.text.isNotEmpty) {
              final minVal = int.tryParse(_windMinController.text);
              if (minVal != null && maxVal < minVal) {
                return 'La vitesse du vent max doit être >= min';
              }
            }
            return null;
          },
          onSaved: (value) {
            if (value == null) return;
            _lsController.windMax = WindSpeed(int.parse(value), windUnit);
          },
        ),
      ],
    );
  }

  Widget _buildUVField() {
    return _buildFormTextField(
      labelText: 'UV',
      prefixIcon: Icons.wb_sunny,
      keyboardType: TextInputType.number,
      controller: _uvController,
      validator: (value) {
        if (value == null || value.isEmpty) return 'Requis';
        final uv = UV(int.parse(value));
        if (!uv.isValid()) {
          return 'UV doit être compris entre ${UV.minUV} et ${UV.maxUV}';
        }
        return null;
      },
      onSaved: (value) {
        if (value == null) return;
        _lsController.uvValue = UV(int.parse(value));
      },
    );
  }
}
