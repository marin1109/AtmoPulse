// deleteAccount_dialog.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../types/password_type.dart';
import '../../utils/user_preferences.dart';
import '../../services/account_service.dart';
import '../account/LogInSignUp_page.dart';

class DeleteAccountDialog extends StatefulWidget {
  const DeleteAccountDialog({Key? key}) : super(key: key);

  @override
  _DeleteAccountDialogState createState() => _DeleteAccountDialogState();

  // Méthode statique pour afficher la boîte de dialogue de confirmation
  static void showConfirmDialog(BuildContext context) {
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
              onPressed: () {
                Navigator.of(context).pop();
                showDialog(
                  context: context,
                  builder: (context) => const DeleteAccountDialog(),
                );
              },
            ),
          ],
        );
      },
    );
  }
}

class _DeleteAccountDialogState extends State<DeleteAccountDialog> {
  final _formKey = GlobalKey<FormState>();
  late Password _password;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Confirmer avec le mot de passe'),
      content: Form(
        key: _formKey,
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
            _password = Password(value);
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
            if (_formKey.currentState!.validate()) {
              try {
                final userPrefs =
                    Provider.of<UserPreferences>(context, listen: false);
                final userEmail = userPrefs.email;

                await deleteUser(userEmail, _password);
                // Effacer toutes les préférences locales
                await userPrefs.clearAll();

                // Rediriger vers la page de connexion
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
  }
}
