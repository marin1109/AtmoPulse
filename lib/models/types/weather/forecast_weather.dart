import '../../../utils/value_object.dart';
import 'forecast_day.dart';

class ForecastWeather extends ValueObject<Map<String, dynamic>> {
  final List<ForecastDay> forecastDays;

  ForecastWeather({required this.forecastDays}) : super({
        'forecastDays': forecastDays,
      });

  factory ForecastWeather.fromJson(Map<String, dynamic> json) {
    return ForecastWeather(
      forecastDays: (json['forecastday'] as List)
          .map((day) => ForecastDay.fromJson(day))
          .toList(),
    );
  }

  @override
  bool isValid() {
    return forecastDays.every((day) => day.isValid());
  }

  @override
  String toString() {
    return forecastDays.map((day) => day.toString()).join(', ');
  }

  Map<String, dynamic> toJson() {
    return {
      'forecastday': forecastDays.map((fd) => fd.toJson()).toList(),
    };
  }
}
