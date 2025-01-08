import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Types
import '../../types/password_type.dart';

// Page d'authentification
import 'LogInSignUp_page.dart';

// UserPreferences
import '../../utils/user_preferences.dart';

// Services (optionnel si vous gérez changement de mdp, suppression de compte, etc.)
import '../../services/account_service.dart';

// Dialogs
import '../dialogs/editPreferences_dialog.dart';
import '../dialogs/changePassword_dialog.dart';
import '../dialogs/deleteAccount_dialog.dart';

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

  // ==============================
  // Changement de mot de passe
  // ==============================
  void _showChangePasswordDialog(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    late Password oldPassword;
    late Password newPassword;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Changer le mot de passe'),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  TextFormField(
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Ancien mot de passe',
                    ),
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
                    decoration: const InputDecoration(
                      labelText: 'Nouveau mot de passe',
                      errorMaxLines: 3,
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Veuillez entrer un nouveau mot de passe';
                      } else if (!Password.isValidPassword(Password(value))) {
                        return 'Le mot de passe doit contenir au moins 8 caractères, '
                            'dont une majuscule, une minuscule, un chiffre et un caractère spécial.';
                      }
                      return null;
                    },
                    onChanged: (value) {
                      newPassword = Password(value);
                    },
                  ),
                  TextFormField(
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Confirmer le nouveau mot de passe',
                      errorMaxLines: 3,
                    ),
                    validator: (value) {
                      if (value == null || value != newPassword) {
                        return 'Les mots de passe ne correspondent pas';
                      } else if (!Password.isValidPassword(Password(value))) {
                        return 'Le mot de passe doit contenir au moins 8 caractères, '
                            'dont une majuscule, une minuscule, un chiffre et un caractère spécial.';
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
              child: const Text('Annuler'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text('Enregistrer'),
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  try {
                    final userPrefs = Provider.of<UserPreferences>(context, listen: false);
                    // email actuel
                    final userEmail = userPrefs.email;

                    await updatePassword(
                      userEmail,
                      oldPassword,
                      newPassword,
                    );
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Mot de passe mis à jour avec succès')),
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

  // ==============================
  // Suppression du compte
  // ==============================
  void _confirmDeleteAccount(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Supprimer le compte'),
          content: const Text(
            'Êtes-vous sûr de vouloir supprimer votre compte ? '
            'Cette action est irréversible.',
          ),
          actions: [
            TextButton(
              child: const Text('Annuler'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text('Supprimer'),
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
          title: const Text('Confirmer avec le mot de passe'),
          content: Form(
            key: formKey,
            child: TextFormField(
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Mot de passe'),
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
              child: const Text('Annuler'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text('Confirmer'),
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  try {
                    final userPrefs = Provider.of<UserPreferences>(context, listen: false);
                    final userEmail = userPrefs.email;

                    await deleteUser(userEmail, password);
                    // On efface tout localement
                    await userPrefs.clearAll();

                    // On quitte la page
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (context) => const LSPage()),
                      (route) => false,
                    );
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Compte supprimé avec succès')),
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
            onPressed: () => _confirmLogout(context),
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
                    _buildInfoRow('Température min/max',
                        '$temperatureMin / $temperatureMax', Icons.thermostat),
                    _buildInfoRow('Humidité min/max',
                        '$humidityMin / $humidityMax', Icons.water),
                    _buildInfoRow('Précipitations min/max',
                        '${userPrefs.precipMin?.value ?? 0} / ${userPrefs.precipMax?.value ?? 100}',
                        Icons.water_drop),
                    _buildInfoRow('Vent min/max', '$windMin / $windMax',
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
