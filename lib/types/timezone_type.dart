class Timezone {
  final String timezone;

  Timezone(this.timezone);

  // Méthode statique pour valider un fuseau horaire
  static bool isValidTimezone(String timezone) {
    final timezoneRegex = RegExp(r"^(?:[A-Za-z_]+(?:\/[A-Za-z_]+)*(?:\/[A-Za-z_]+)*|UTC|GMT(?:[+-]\d{1,2})?)$");
    return timezoneRegex.hasMatch(timezone);
  }

  // Renvoie le fuseau horaire
  @override
  String toString() => timezone;
  
}