import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../utils/user_preferences.dart';
import '../account/log_in_sign_up_page.dart';

class LogoutDialog extends StatelessWidget {
  const LogoutDialog({super.key});

  void _logout(BuildContext context) async {
    final userPrefs = Provider.of<UserPreferences>(context, listen: false);

    await userPrefs.clearAll();

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LSPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: Colors.transparent,
      child: Stack(
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
      ),
    );
  }
}
