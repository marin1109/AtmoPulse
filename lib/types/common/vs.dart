import 'city.dart';
import 'region.dart';
import 'country.dart';
import '../../utils/value_object.dart';

class VS extends ValueObject<Map<String, dynamic>> {
  final City city;
  final Region region;
  final Country country;
  final String url;

  VS({
    required this.city,
    required this.region,
    required this.country,
    required this.url,
  }) : super({
          'city': city,
          'region': region,
          'country': country,
          'url': url,
        });

  /// Constructeur simplifié à partir de chaînes de caractères.
  factory VS.fromValues(String cityName, String regionName, String countryName, String url) {
    return VS(
      city: City(cityName),
      region: Region(regionName),
      country: Country(countryName),
      url: url,
    );
  }

  @override
  bool isValid() {
    return city.isValid() && region.isValid() && country.isValid() && url.isNotEmpty;
  }
}
