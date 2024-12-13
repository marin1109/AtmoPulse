import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import './view/home/home_page.dart';
import './utils/user_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

// Import des types
import 'types/temperature_type.dart';
import 'types/wind_type.dart';
import 'types/pressure_type.dart';
import 'types/precipitation_type.dart';
import 'types/humidity_type.dart';

void main() async {
  await dotenv.load(fileName: "assets/.env");
  
  WidgetsFlutterBinding.ensureInitialized();

  SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.setString('unite_temperature', TemperatureUnit.celsius.name);
  prefs.setString('unite_vitesse', WindUnit.kmh.name);
  prefs.setString('unite_pression', PressureUnit.hPa.name);
  prefs.setString('unite_precipitations', PrecipitationUnit.mm.name);
  prefs.setString('unite_humidite', HumidityUnit.relative.name);

  runApp(
    ChangeNotifierProvider(
      create: (_) => UserPreferences(),
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AtmoPulse',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => HomePage(),
      },
    );
  }
}
