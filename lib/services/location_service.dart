// Package imports
import 'package:geolocator/geolocator.dart';


class LocationService {
  // Fonction pour obtenir la position de l'utilisateur
  Future<Position> getUserLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      print('Erreur: Les services de localisation sont désactivés.');
      return Future.error('Les services de localisation sont désactivés.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      print('Permission de localisation initialement refusée. Demande de permission...');
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        print('Erreur: Permission de localisation refusée par l\'utilisateur.');
        return Future.error('Permission de localisation refusée.');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      print('Erreur: Permission de localisation refusée de manière permanente.');
      return Future.error(
          'Permission de localisation refusée de manière permanente. Veuillez l\'activer dans les paramètres de l\'appareil.');
    }

    try {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      print('Position obtenue: Latitude ${position.latitude}, Longitude ${position.longitude}');
      return position;
    } catch (e) {
      print('Erreur lors de la récupération de la position: $e');
      return Future.error('Erreur lors de la récupération de la position.');
    }
  }
}
