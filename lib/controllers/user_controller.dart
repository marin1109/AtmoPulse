import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Pages
import '../views/login_signup/ls_page.dart';

// Utils
import '../utils/user_preferences.dart';

// Dialogs
import '../views/dialogs/changePassword_dialog.dart';
import '../views/dialogs/deleteAccount_dialog.dart';
import '../views/dialogs/logout_dialog.dart';

/// Contrôleur pour la [UserPage].
class UserController {
  /// Déconnexion + reset des préférences
  static Future<void> logout(BuildContext context) async {
    final userPrefs = Provider.of<UserPreferences>(context, listen: false);
    await userPrefs.clearAll();

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LSPage()),
    );
  }

  /// Gère les sélections du PopupMenu (changer MDP, supprimer compte)
  static void onSelected(BuildContext context, int item) {
    switch (item) {
      case 0:
        // Changer mot de passe
        showDialog(
          context: context,
          builder: (_) => const ChangePasswordDialog(),
        );
        break;
      case 1:
        // Supprimer le compte
        DeleteAccountDialog.showConfirmDialog(context);
        break;
    }
  }

  /// Ouvre la boîte de dialogue de logout
  static void showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => const LogoutDialog(),
    );
  }
}
