import 'email_type.dart';
import 'password_type.dart';
import 'age_type.dart';
import 'lname_type.dart';
import 'fname_type.dart';
import 'humidity_type.dart';
import 'precipitation_type.dart';
import 'temperature_type.dart';
import 'uv_type.dart';
import 'wind_type.dart';

class User {
  final Email _email;
  final Password _password;
  final Age _age;
  final LName _lname;
  final FName _fname;
  final Humidity _humidity_max;
  final Humidity _humidity_min;
  final Precipitation _precipitation_max;
  final Precipitation _precipitation_min;
  final Temperature _temperature_max;
  final Temperature _temperature_min;
  final UV _uv_max;
  final WindSpeed _windSpeed_max;
  final WindSpeed _windSpeed_min;

  User(
      this._email,
      this._password,
      this._age,
      this._lname,
      this._fname,
      this._humidity_max,
      this._humidity_min,
      this._precipitation_max,
      this._precipitation_min,
      this._temperature_max,
      this._temperature_min,
      this._uv_max,
      this._windSpeed_max,
      this._windSpeed_min);

  Email get email => _email;
  Password get password => _password;
  Age get age => _age;
  LName get lname => _lname;
  FName get fname => _fname;
  Humidity get humidity_max => _humidity_max;
  Humidity get humidity_min => _humidity_min;
  Precipitation get precipitation_max => _precipitation_max;
  Precipitation get precipitation_min => _precipitation_min;
  Temperature get temperature_max => _temperature_max;
  Temperature get temperature_min => _temperature_min;
  UV get uv_max => _uv_max;
  WindSpeed get windSpeed_max => _windSpeed_max;
  WindSpeed get windSpeed_min => _windSpeed_min;

}
