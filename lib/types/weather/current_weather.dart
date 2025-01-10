import '../../utils/value_object.dart';
import 'temperature.dart';
import 'wind_speed.dart';
import 'precipitation.dart';
import 'humidity.dart';
import 'condition.dart';
import 'uv.dart';

class CurrentWeather extends ValueObject<Map<String, dynamic>> {
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
  }) : super({
          'temp': temp,
          'wind': wind,
          'precipitation': precipitation,
          'humidity': humidity,
          'condition': condition,
          'uv': uv,
        });

  factory CurrentWeather.fromJson(Map<String, dynamic> json) {
    return CurrentWeather(
      temp: Temperature(json['temp_c'].toInt(), TemperatureUnit.celsius),
      wind: WindSpeed(json['wind_kph'].toInt(), WindUnit.kmh),
      precipitation: Precipitation(json['precip_mm'].toInt(), PrecipitationUnit.mm),
      humidity: Humidity(json['humidity'].toInt(), HumidityUnit.relative),
      uv: UV(json['uv'].toInt()),
      condition: Condition.fromJson(json['condition']),
    );
  }

  @override
  bool isValid() {
    return temp.isValid() &&
        wind.isValid() &&
        precipitation.isValid() &&
        humidity.isValid() &&
        condition.isValid() &&
        uv.isValid();
  }

  @override
  String toString() {
    return 'Temp: ${temp.toString()}, Wind: ${wind.toString()}, Precipitation: ${precipitation.toString()}, Humidity: ${humidity.toString()}, UV: ${uv.toString()}';
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
