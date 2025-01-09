// Type imports
import 'package:AtmoPulse/types/uv_type.dart';

import 'humidity_type.dart';
import 'precipitation_type.dart';
import 'temperature_type.dart';
import 'wind_type.dart';
import 'latitude_type.dart';
import 'longitude_type.dart';
import 'city_type.dart';
import 'region_type.dart';
import 'country_type.dart';
import 'timezone_type.dart';
import 'localtime_type.dart';


class WeatherData {
  final Location location;
  final CurrentWeather current;
  final ForecastWeather? forecast;

  WeatherData({
    required this.location,
    required this.current,
    this.forecast,
  });
  
  factory WeatherData.fromJson(Map<String, dynamic> json) {
    return WeatherData(
      location: Location.fromJson(json['location']),
      current: CurrentWeather.fromJson(json['current']),
      forecast: json['forecast'] != null
          ? ForecastWeather.fromJson(json['forecast'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'location': location.toJson(),
      'current': current.toJson(),
      // attention : forecast peut être null
      'forecast': forecast?.toJson(),
    };
  }

}

class Location {
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

  Map<String, dynamic> toJson() {
    return {
      'name': city.name,
      'region': region.name,
      'country': country.name,
      'lat': latitude.latitude,
      'lon': longitude.value,
      'tz_id': timezone.timezone,
      'localtime': localtime.localtime,
    };
  }

  @override
  String toString() {
    return '${city.name}, ${region.name}, ${country.name}';
  }
}

class CurrentWeather {
  final Temperature temp;
  final WindSpeed wind;
  final Precipitation precipitation;
  final Humidity humidity;
  final Condition condition;
  final UV uv;

  CurrentWeather({
    required this.temp,
    required this.wind,
    required this.precipitation,
    required this.humidity,
    required this.condition,
    required this.uv,
  });

  factory CurrentWeather.fromJson(Map<String, dynamic> json) {
    return CurrentWeather(
      temp: Temperature(json['temp_c'].toInt(), TemperatureUnit.celsius),
      wind: WindSpeed(json['wind_kph'].toInt(), WindUnit.kmh),
      precipitation:
          Precipitation(json['precip_mm'].toInt(), PrecipitationUnit.mm),
      humidity: Humidity(json['humidity'].toDouble(), HumidityUnit.relative),
      uv: UV(json['uv'].toInt()),
      condition: Condition.fromJson(json['condition']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'temp_c': temp.value,
      'wind_kph': wind.value,
      'precip_mm': precipitation.value,
      'humidity': humidity.value,
      'uv': uv.value,
      'condition': condition.toJson(),
    };
  }

}

class ForecastWeather {
  final List<ForecastDay> forecastDays;

  ForecastWeather({required this.forecastDays});

  factory ForecastWeather.fromJson(Map<String, dynamic> json) {
    return ForecastWeather(
      forecastDays: (json['forecastday'] as List)
          .map((day) => ForecastDay.fromJson(day))
          .toList(),
    );
  }

    Map<String, dynamic> toJson() {
    return {
      'forecastday': forecastDays.map((fd) => fd.toJson()).toList(),
    };
  }

}

class ForecastDay {
  final String date;
  final Temperature maxTemp;
  final Temperature minTemp;
  final Temperature avgTemp;
  final WindSpeed maxWind;
  final Precipitation totalPrecipitation;
  final Humidity avgHumidity;
  final Condition condition;
  final UV uv;

  ForecastDay({
    required this.date,
    required this.maxTemp,
    required this.minTemp,
    required this.avgTemp,
    required this.maxWind,
    required this.totalPrecipitation,
    required this.avgHumidity,
    required this.condition,
    required this.uv,
  });

  factory ForecastDay.fromJson(Map<String, dynamic> json) {
    return ForecastDay(
      date: json['date'],
      maxTemp: Temperature(json['day']['maxtemp_c'].toInt(), TemperatureUnit.celsius),
      minTemp: Temperature(json['day']['mintemp_c'].toInt(), TemperatureUnit.celsius),
      avgTemp: Temperature(json['day']['avgtemp_c'].toInt(), TemperatureUnit.celsius),
      maxWind: WindSpeed(json['day']['maxwind_kph'].toInt(), WindUnit.kmh),
      totalPrecipitation: Precipitation(json['day']['totalprecip_mm'].toInt(), PrecipitationUnit.mm),
      avgHumidity: Humidity(json['day']['avghumidity'].toDouble(), HumidityUnit.relative),
      condition: Condition.fromJson(json['day']['condition']),
      uv: UV(json['day']['uv'].toInt()),
      );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date,
      'day': {
        'maxtemp_c': maxTemp.value,
        'mintemp_c': minTemp.value,
        'avgtemp_c': avgTemp.value,
        'maxwind_kph': maxWind.value,
        'totalprecip_mm': totalPrecipitation.value,
        'avghumidity': avgHumidity.value,
        'condition': condition.toJson(),
        'uv': uv.value,
      }
    };
  }
  
}

class Condition {
  final String text;
  final String icon;
  final int code;

  Condition({
    required this.text,
    required this.icon,
    required this.code,
  });

  factory Condition.fromJson(Map<String, dynamic> json) {
    return Condition(
      text: json['text'],
      icon: json['icon'],
      code: json['code'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'text': text,
      'icon': icon,
      'code': code,
    };
  }

}
