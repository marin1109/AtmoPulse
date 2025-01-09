import 'package:geolocator/geolocator.dart';
import 'package:flutter/foundation.dart';
import '../services/weather_service.dart';
import '../services/notification_service.dart';
import '../utils/user_preferences.dart';
import '../types/weather_type.dart';

// --- 1. Enum pour le niveau de sévérité ---
enum WeatherSeverity {
  low,
  moderate,
  critical,
}

// --- 2. Fonctions d’évaluation par paramètre ---

WeatherSeverity evaluateTemperature({
  required int actualTemp,
  required int minTemp,
  required int maxTemp,
}) {
  if (actualTemp < minTemp) {
    final diff = (minTemp - actualTemp).abs();
    if (diff > 5) {
      return WeatherSeverity.critical;
    } else {
      return WeatherSeverity.moderate;
    }
  } else if (actualTemp > maxTemp) {
    final diff = (actualTemp - maxTemp).abs();
    if (diff > 5) {
      return WeatherSeverity.critical;
    } else {
      return WeatherSeverity.moderate;
    }
  }
  return WeatherSeverity.low;
}

WeatherSeverity evaluateHumidity({
  required double actualHumidity,
  required double minHum,
  required double maxHum,
}) {
  if (actualHumidity < minHum) {
    final diff = (minHum - actualHumidity).abs();
    if (diff > 20) {
      return WeatherSeverity.critical;
    } else {
      return WeatherSeverity.moderate;
    }
  } else if (actualHumidity > maxHum) {
    final diff = (actualHumidity - maxHum).abs();
    if (diff > 20) {
      return WeatherSeverity.critical;
    } else {
      return WeatherSeverity.moderate;
    }
  }
  return WeatherSeverity.low;
}

WeatherSeverity evaluateWind({
  required int actualWind,
  required int minWind,
  required int maxWind,
}) {
  if (actualWind < minWind) {
    final diff = (minWind - actualWind).abs();
    if (diff > 10) { // Exemple: marge arbitraire
      return WeatherSeverity.critical;
    } else {
      return WeatherSeverity.moderate;
    }
  } else if (actualWind > maxWind) {
    final diff = (actualWind - maxWind).abs();
    if (diff > 10) {
      return WeatherSeverity.critical;
    } else {
      return WeatherSeverity.moderate;
    }
  }
  return WeatherSeverity.low;
}

WeatherSeverity evaluatePrecipitation({
  required int actualPrecipitation,
  required int minPrecipitation,
  required int maxPrecipitation,
}) {
  if (actualPrecipitation < minPrecipitation) {
    final diff = (minPrecipitation - actualPrecipitation).abs();
    if (diff > 5) {
      return WeatherSeverity.critical;
    } else {
      return WeatherSeverity.moderate;
    }
  } else if (actualPrecipitation > maxPrecipitation) {
    final diff = (actualPrecipitation - maxPrecipitation).abs();
    if (diff > 5) {
      return WeatherSeverity.critical;
    } else {
      return WeatherSeverity.moderate;
    }
  }
  return WeatherSeverity.low;
}

WeatherSeverity evaluateUV({
  required int actualUV,
  required int maxUV,
}) {
  if (actualUV > maxUV) {
    final diff = (actualUV - maxUV).abs();
    if (diff > 2) {
      return WeatherSeverity.critical;
    } else {
      return WeatherSeverity.moderate;
    }
  }
  return WeatherSeverity.low;
}

// --- 3. Fonction pour fusionner les sévérités ---
WeatherSeverity combineSeverities(List<WeatherSeverity> severities) {
  // Si au moins un paramètre est Critical, on renvoie Critical
  if (severities.contains(WeatherSeverity.critical)) {
    return WeatherSeverity.critical;
  }
  // Si pas de Critical, mais un paramètre est Moderate, on renvoie Moderate
  if (severities.contains(WeatherSeverity.moderate)) {
    return WeatherSeverity.moderate;
  }
  // Sinon => Low
  return WeatherSeverity.low;
}

// --- 4. Evaluation globale de la météo ---
WeatherSeverity evaluateWeatherSeverity(WeatherData weatherData, UserPreferences prefs) {
  // Vous avez un objet WeatherData. 
  // On suppose qu’il contient un "current" (temp, humidity, wind, etc.)
  final current = weatherData.current; // selon votre structure

  // Récupération des valeurs *actuelles* (selon votre type).
  final int currentTemp = current.temp.value;       // ex: 23.0
  final double currentHum  = current.humidity.value;   // ex: 55.0
  final int currentWind = current.wind.value;       // ex: 12.0
  final int currentPrecip = current.precipitation.value; // ex: 0.0
  final int currentUV = current.uv.value;       // ex: 5.0

  // Récupération des min/max de l’utilisateur (déjà chargés via userPrefs)
  final int userTempMin  = prefs.tempMin?.value ?? -50;
  final int userTempMax  = prefs.tempMax?.value ?? 50;
  final double userHumMin   = prefs.humidityMin?.value ?? 0;
  final double userHumMax   = prefs.humidityMax?.value ?? 100;
  final int userWindMin  = prefs.windMin?.value ?? 0;
  final int userWindMax  = prefs.windMax?.value ?? 200;
  final int userPrecipMin = prefs.precipMin?.value ?? 100;
  final int userPrecipMax = prefs.precipMax?.value ?? 0;
  final int userUVMax = prefs.uvValue?.value ?? 10;
  
  // Evaluation séparée
  final tempSeverity = evaluateTemperature(
    actualTemp: currentTemp,
    minTemp: userTempMin,
    maxTemp: userTempMax,
  );
  final humSeverity = evaluateHumidity(
    actualHumidity: currentHum,
    minHum: userHumMin,
    maxHum: userHumMax,
  );
  final windSeverity = evaluateWind(
    actualWind: currentWind,
    minWind: userWindMin,
    maxWind: userWindMax,
  );
  final precipSeverity = evaluatePrecipitation(
    actualPrecipitation: currentPrecip,
    minPrecipitation: userPrecipMin,
    maxPrecipitation: userPrecipMax,
  );
  final uvSeverity = evaluateUV(
    actualUV: currentUV,
    maxUV: userUVMax,
  );

  // Fusion
  return combineSeverities([tempSeverity, humSeverity, windSeverity, precipSeverity, uvSeverity]);
}

// --- 5. La fonction fetchAndNotify ---

Future<void> fetchAndNotify() async {
  try {
    // 1) Charger les préférences
    final userPrefs = UserPreferences();
    await userPrefs.loadPreferences(); 
    // (ou si vous avez un provider, assurez-vous d'avoir l'instance à jour)

    // 2) Récupérer la position utilisateur (ou la ville par défaut, etc.)
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    // 3) Récupérer la météo via WeatherService
    final weatherService = WeatherService();
    final WeatherData? currentData = await weatherService.fetchCurrentWeather(position);

    if (currentData == null) {
      debugPrint("fetchAndNotify: pas de données météo reçues.");
      return;
    }

    // 4) Évaluer la sévérité
    final severity = evaluateWeatherSeverity(currentData, userPrefs);

    // 5) Si >= Moderate, on notifie
    if (severity == WeatherSeverity.moderate || severity == WeatherSeverity.critical) {
      final String title = (severity == WeatherSeverity.critical)
          ? "Alerte Météo Critique"
          : "Alerte Météo Modérée";

      final String body = "Les conditions dépassent vos seuils configurés.";

      await NotificationService().showNotification(
        title: title,
        body: body,
        id: 1234, // un ID arbitraire
      );
      debugPrint("Notification envoyée : $title");
    } else {
      debugPrint("fetchAndNotify: Sévérité basse (Low), pas de notification.");
    }
  } catch (e, stackTrace) {
    debugPrint("Erreur dans fetchAndNotify: $e\n$stackTrace");
  }
}
