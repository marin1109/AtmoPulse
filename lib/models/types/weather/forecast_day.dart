import '../../../utils/value_object.dart';
import 'temperature.dart';
import 'wind_speed.dart';
import 'precipitation.dart';
import 'humidity.dart';
import 'condition.dart';
import 'uv.dart';

class ForecastDay extends ValueObject<Map<String, dynamic>> {
  final String date;
  final Temperature maxTemp;
  final Temperature minTemp;
  final WindSpeed maxWind;
  final Precipitation totalPrecipitation;
  final Humidity avgHumidity;
  final Condition condition;
  final UV uv;

  ForecastDay({
    required this.date,
    required this.maxTemp,
    required this.minTemp,
    required this.maxWind,
    required this.totalPrecipitation,
    required this.avgHumidity,
    required this.condition,
    required this.uv,
  }) : super({
          'date': date,
          'maxTemp': maxTemp,
          'minTemp': minTemp,
          'maxWind': maxWind,
          'totalPrecipitation': totalPrecipitation,
          'avgHumidity': avgHumidity,
          'condition': condition,
          'uv': uv,
        });

  factory ForecastDay.fromJson(Map<String, dynamic> json) {
    return ForecastDay(
      date: json['date'],
      maxTemp: Temperature(json['day']['maxtemp_c'].round(), TemperatureUnit.celsius),
      minTemp: Temperature(json['day']['mintemp_c'].round(), TemperatureUnit.celsius),
      maxWind: WindSpeed(json['day']['maxwind_kph'].round(), WindUnit.kmh),
      totalPrecipitation: Precipitation(json['day']['totalprecip_mm'].round(), PrecipitationUnit.mm),
      avgHumidity: Humidity(json['day']['avghumidity'].round(), HumidityUnit.relative),
      condition: Condition.fromJson(json['day']['condition']),
      uv: UV(json['day']['uv'].round()),
    );
  }

  @override
  bool isValid() {
    return date.isNotEmpty &&
        maxTemp.isValid() &&
        minTemp.isValid() &&
        maxWind.isValid() &&
        totalPrecipitation.isValid() &&
        avgHumidity.isValid() &&
        condition.isValid() &&
        uv.isValid();
  }

  @override
  String toString() {
    return 'Date: $date, Max Temp: ${maxTemp.toString()}, Min Temp: ${minTemp.toString()}, Max Wind: ${maxWind.toString()}, Total Precipitation: ${totalPrecipitation.toString()}, Avg Humidity: ${avgHumidity.toString()}, Condition: ${condition.toString()}, UV: ${uv.toString()}';
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date,
      'day': {
        'maxtemp_c': maxTemp.value,
        'mintemp_c': minTemp.value,
        'maxwind_kph': maxWind.value,
        'totalprecip_mm': totalPrecipitation.value,
        'avghumidity': avgHumidity.value,
        'condition': condition.toJson(),
        'uv': uv.value,
      }
    };
  }
}
