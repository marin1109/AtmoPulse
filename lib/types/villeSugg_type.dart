import 'city_type.dart';
import 'region_type.dart';
import 'country_type.dart';

class VS {
  final City _city;
  final Region _region;
  final Country _country;
  final String _url;

  VS(String city, String region, String country, String url)
      : _city = City(city),
        _region = Region(region),
        _country = Country(country),
        _url = url
        ;

  City get city => _city;
  Region get region => _region;
  Country get country => _country;
  String get url => _url;

  @override
  String toString() {
    return '${_city.name}, ${_region.name}, ${_country.name}';
  }
}