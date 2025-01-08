import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../types/password_type.dart';
import '../../utils/user_preferences.dart';
import '../../services/account_service.dart';

class ChangePasswordDialog extends StatefulWidget {
  const ChangePasswordDialog({super.key});

  @override
  _ChangePasswordDialogState createState() => _ChangePasswordDialogState();
}

class _ChangePasswordDialogState extends State<ChangePasswordDialog> {
  final _formKey = GlobalKey<FormState>();
  late Password _oldPassword;
  late Password _newPassword;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Changer le mot de passe'),
      content: Form(
        key: _formKey,
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
                  _oldPassword = Password(value);
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
                  _newPassword = Password(value);
                },
              ),
              TextFormField(
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Confirmer le nouveau mot de passe',
                  errorMaxLines: 3,
                ),
                validator: (value) {
                  if (value == null || Password(value).value != _newPassword.value) {
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
            if (_formKey.currentState!.validate()) {
              try {
                final userPrefs = Provider.of<UserPreferences>(context, listen: false);
                final userEmail = userPrefs.email;

                await updatePassword(
                  userEmail,
                  _oldPassword,
                  _newPassword,
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
  }
}
