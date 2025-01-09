import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../utils/user_preferences.dart';
import '../../services/account_service.dart';

class EditPreferencesDialog extends StatefulWidget {
  const EditPreferencesDialog({super.key});

  @override
  State<EditPreferencesDialog> createState() => _EditPreferencesDialogState();
}

class _EditPreferencesDialogState extends State<EditPreferencesDialog> {
  final _editPrefsFormKey = GlobalKey<FormState>();

  final tempMinController = TextEditingController();
  final tempMaxController = TextEditingController();
  final humidityMinController = TextEditingController();
  final humidityMaxController = TextEditingController();
  final precipitationMinController = TextEditingController();
  final precipitationMaxController = TextEditingController();
  final windMinController = TextEditingController();
  final windMaxController = TextEditingController();
  final uvMinController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final userPrefs = Provider.of<UserPreferences>(context, listen: false);
    tempMinController.text = userPrefs.tempMin?.value.toString() ?? '';
    tempMaxController.text = userPrefs.tempMax?.value.toString() ?? '';
    humidityMinController.text = userPrefs.humidityMin?.value.toString() ?? '';
    humidityMaxController.text = userPrefs.humidityMax?.value.toString() ?? '';
    precipitationMinController.text = userPrefs.precipMin?.value.toString() ?? '';
    precipitationMaxController.text = userPrefs.precipMax?.value.toString() ?? '';
    windMinController.text = userPrefs.windMin?.value.toString() ?? '';
    windMaxController.text = userPrefs.windMax?.value.toString() ?? '';
    uvMinController.text = userPrefs.uvValue?.value.toString() ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: Colors.transparent,
      child: contentBox(context),
    );
  }

  Widget contentBox(BuildContext context) {
    final userPrefs = Provider.of<UserPreferences>(context, listen: false);

    return Stack(
      children: [
        Container(
          padding: const EdgeInsets.only(left: 20, top: 65, right: 20, bottom: 20),
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
          child: Form(
            key: _editPrefsFormKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Modifier mes préférences',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Montserrat',
                    ),
                  ),
                  const SizedBox(height: 15),
                  // Ex. Température min
                  TextFormField(
                    controller: tempMinController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Temp. min',
                      prefixIcon: Icon(Icons.thermostat),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Requis';
                      }
                      final val = int.tryParse(value);
                      if (val == null) {
                        return 'Valeur invalide';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 10),
                  // Température max
                  TextFormField(
                    controller: tempMaxController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Temp. max',
                      prefixIcon: Icon(Icons.thermostat),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Requis';
                      }
                      final val = int.tryParse(value);
                      if (val == null) {
                        return 'Valeur invalide';
                      }
                      // Vérifier que val >= min ?
                      final minVal = int.tryParse(tempMinController.text);
                      if (minVal != null && val < minVal) {
                        return 'Max doit être >= min';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 10),
                  // Humidité min
                  TextFormField(
                    controller: humidityMinController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Humidité min',
                      prefixIcon: Icon(Icons.water),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Requis';
                      }
                      final val = int.tryParse(value);
                      if (val == null) {
                        return 'Valeur invalide';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 10),
                  // Humidité max
                  TextFormField(
                    controller: humidityMaxController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Humidité max',
                      prefixIcon: Icon(Icons.water),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Requis';
                      }
                      final val = int.tryParse(value);
                      if (val == null) {
                        return 'Valeur invalide';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 10),
                  // Précipitations min
                  TextFormField(
                    controller: precipitationMinController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Précipitations min',
                      prefixIcon: Icon(Icons.umbrella),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Requis';
                      }
                      final val = int.tryParse(value);
                      if (val == null) {
                        return 'Valeur invalide';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 10),
                  // Précipitations max
                  TextFormField(
                    controller: precipitationMaxController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Précipitations max',
                      prefixIcon: Icon(Icons.umbrella),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Requis';
                      }
                      final val = int.tryParse(value);
                      if (val == null) {
                        return 'Valeur invalide';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 10),
                  // Vitesse du vent min
                  TextFormField(
                    controller: windMinController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Vent min',
                      prefixIcon: Icon(Icons.air),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Requis';
                      }
                      final val = int.tryParse(value);
                      if (val == null) {
                        return 'Valeur invalide';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 10),
                  // Vitesse du vent max
                  TextFormField(
                    controller: windMaxController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Vent max',
                      prefixIcon: Icon(Icons.air),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Requis';
                      }
                      final val = int.tryParse(value);
                      if (val == null) {
                        return 'Valeur invalide';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 10),
                  // Indice UV
                  TextFormField(
                    controller: uvMinController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'UV',
                      prefixIcon: Icon(Icons.wb_sunny),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Requis';
                      }
                      final val = int.tryParse(value);
                      if (val == null) {
                        return 'Valeur invalide';
                      }
                      return null;
                    },
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
                        onPressed: () async {
                          if (_editPrefsFormKey.currentState!.validate()) {
                            final newTempMin = int.parse(tempMinController.text);
                            final newTempMax = int.parse(tempMaxController.text);
                            final newHumidityMin = double.parse(humidityMinController.text);
                            final newHumidityMax = double.parse(humidityMaxController.text);
                            final newPrecipMin = int.parse(precipitationMinController.text);
                            final newPrecipMax = int.parse(precipitationMaxController.text);
                            final newWindMin = int.parse(windMinController.text);
                            final newWindMax = int.parse(windMaxController.text);
                            final newUvValue = int.parse(uvMinController.text);

                            await userPrefs.setTempMin(newTempMin);
                            await userPrefs.setTempMax(newTempMax);
                            await userPrefs.setHumidityMin(newHumidityMin);
                            await userPrefs.setHumidityMax(newHumidityMax);
                            await userPrefs.setPrecipMin(newPrecipMin);
                            await userPrefs.setPrecipMax(newPrecipMax);
                            await userPrefs.setWindMin(newWindMin);
                            await userPrefs.setWindMax(newWindMax);
                            await userPrefs.setUV(newUvValue);

                            try {
                              final userEmail = userPrefs.email;
                              await updateSensibilites(
                                userEmail,
                                humiditeMin: newHumidityMin,
                                humiditeMax: newHumidityMax,
                                precipitationsMin: newPrecipMin,
                                precipitationsMax: newPrecipMax,
                                temperatureMin: newTempMin,
                                temperatureMax: newTempMax,
                                ventMin: newWindMin,
                                ventMax: newWindMax,
                                uv: newUvValue,
                              );

                              Navigator.of(context).pop();
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Erreur lors de la mise à jour: $e')),
                              );
                            }
                          }
                        },
                        child: const Text('Enregistrer'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
        Positioned(
          left: 20,
          right: 20,
          child: CircleAvatar(
            backgroundColor: Colors.blueAccent,
            radius: 45,
            child: const Icon(
              Icons.edit,
              color: Colors.white,
              size: 50,
            ),
          ),
        ),
      ],
    );
  }
}
