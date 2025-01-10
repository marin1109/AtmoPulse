import '../types/common/city.dart';
import '../types/common/region.dart';
import '../types/common/country.dart';
import '../types/common/latitude.dart';
import '../types/common/longitude.dart';
import '../types/common/timezone.dart';
import '../types/common/localtime.dart';
import '../types/weather/current_weather.dart';
import '../types/weather/forecast_weather.dart';
import '../utils/value_object.dart';

class WeatherData extends ValueObject<Map<String, dynamic>> {
  final Location location;
  final CurrentWeather current;
  final ForecastWeather? forecast;

  WeatherData({
    required this.location,
    required this.current,
    this.forecast,
  }) : super({
          'location': location,
          'current': current,
          'forecast': forecast,
        });

  factory WeatherData.fromJson(Map<String, dynamic> json) {
    return WeatherData(
      location: Location.fromJson(json['location']),
      current: CurrentWeather.fromJson(json['current']),
      forecast: json['forecast'] != null ? ForecastWeather.fromJson(json['forecast']) : null,
    );
  }

  @override
  bool isValid() {
    return location.isValid() &&
        current.isValid() &&
        (forecast == null || forecast!.isValid());
  }

  @override
  String toString() {
    return 'Location: ${location.toString()}, Current: ${current.toString()}, Forecast: ${forecast?.toString() ?? 'N/A'}';
  }

  Map<String, dynamic> toJson() {
    return {
      'location': location.toJson(),
      'current': current.toJson(),
      'forecast': forecast?.toJson(),
    };
  }
}

class Location extends ValueObject<Map<String, dynamic>> {
  final City city;
  final Region region;
  final Country country;
  final Latitude latitude;
  final Longitude longitude;
  final Timezone timezone;
  final Localtime localtime;

  Location({
    required this.city,
    required this.region,
    required this.country,
    required this.latitude,
    required this.longitude,
    required this.timezone,
    required this.localtime,
  }) : super({
          'city': city,
          'region': region,
          'country': country,
          'latitude': latitude,
          'longitude': longitude,
          'timezone': timezone,
          'localtime': localtime,
        });

  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      city: City(json['name']),
      region: Region(json['region']),
      country: Country(json['country']),
      latitude: Latitude(json['lat'].toDouble()),
      longitude: Longitude(json['lon'].toDouble()),
      timezone: Timezone(json['tz_id']),
      localtime: Localtime(json['localtime']),
    );
  }

  @override
  bool isValid() {
    return city.isValid() &&
        region.isValid() &&
        country.isValid() &&
        latitude.isValid() &&
        longitude.isValid() &&
        timezone.isValid() &&
        localtime.isValid();
  }

  @override
  String toString() {
    return '${city.value}, ${region.value}, ${country.value}';
  }

  Map<String, dynamic> toJson() {
    return {
      'name': city.value,
      'region': region.value,
      'country': country.value,
      'lat': latitude.value,
      'lon': longitude.value,
      'tz_id': timezone.value,
      'localtime': localtime.value,
    };
  }
}
