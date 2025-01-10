// lib/models/user.dart
import '../types/common/email.dart';
import '../types/common/password.dart';
import '../types/common/age.dart';
import '../types/common/lname.dart';
import '../types/common/fname.dart';
import '../types/weather/humidity.dart';
import '../types/weather/precipitation.dart';
import '../types/weather/temperature.dart';
import '../types/weather/uv.dart';
import '../types/weather/wind_speed.dart';

class User {
  final Email email;
  final Password password;
  final Age age;
  final LName lname;
  final FName fname;
  final Humidity humidityMax;
  final Humidity humidityMin;
  final Precipitation precipitationMax;
  final Precipitation precipitationMin;
  final Temperature temperatureMax;
  final Temperature temperatureMin;
  final UV uvMax;
  final WindSpeed windSpeedMax;
  final WindSpeed windSpeedMin;

  User({
    required this.email,
    required this.password,
    required this.age,
    required this.lname,
    required this.fname,
    required this.humidityMax,
    required this.humidityMin,
    required this.precipitationMax,
    required this.precipitationMin,
    required this.temperatureMax,
    required this.temperatureMin,
    required this.uvMax,
    required this.windSpeedMax,
    required this.windSpeedMin,
  });
}
