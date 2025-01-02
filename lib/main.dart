import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:background_fetch/background_fetch.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' show Platform;

// Import de mes fichiers
import 'services/notification_service.dart';
import 'utils/user_preferences.dart';
import 'view/home/home_page.dart';

// Import des types
import 'types/temperature_type.dart';
import 'types/wind_type.dart';
import 'types/pressure_type.dart';
import 'types/precipitation_type.dart';
import 'types/humidity_type.dart';

/// 1. Callback "headless" pour background_fetch (Android lorsque l’appli est tuée).
@pragma('vm:entry-point')
Future<void> backgroundFetchHeadlessTask(HeadlessTask task) async {
  final taskId = task.taskId;
  final timeout = task.timeout;

  if (timeout) {
    BackgroundFetch.finish(taskId);
    return;
  }

  // TODO: Votre logique de background
  // Ex.: NotificationService().showNotification(
  //   title: "Météo",
  //   body: "Limites dépassées !",
  // );

  BackgroundFetch.finish(taskId);
}

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: "assets/.env");

  SharedPreferences prefs = await SharedPreferences.getInstance();

  if (!prefs.containsKey('unite_temperature')) {
    prefs.setString('unite_temperature', TemperatureUnit.celsius.name);
  }
  if (!prefs.containsKey('unite_vitesse')) {
    prefs.setString('unite_vitesse', WindUnit.kmh.name);
  }
  if (!prefs.containsKey('unite_pression')) {
    prefs.setString('unite_pression', PressureUnit.hPa.name);
  }
  if (!prefs.containsKey('unite_precipitations')) {
    prefs.setString('unite_precipitations', PrecipitationUnit.mm.name);
  }
  if (!prefs.containsKey('unite_humidite')) {
    prefs.setString('unite_humidite', HumidityUnit.relative.name);
  }

  await NotificationService().init();

  if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
    BackgroundFetch.registerHeadlessTask(backgroundFetchHeadlessTask);
  } else {
    print("Headless Task non enregistré : plateforme non supportée");
  }

  // 6. Lancer l'application
  runApp(
    ChangeNotifierProvider(
      create: (_) => UserPreferences(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    _configureBackgroundFetch();
  }

  /// Configuration de background_fetch
  Future<void> _configureBackgroundFetch() async {
    if (kIsWeb || !(Platform.isAndroid || Platform.isIOS)) {
      print('background_fetch non initialisé : plateforme non supportée');
      return;
    }

    try {
      await BackgroundFetch.configure(
        BackgroundFetchConfig(
          minimumFetchInterval: 15,  // en minutes
          stopOnTerminate: false,
          startOnBoot: true,
          enableHeadless: true,
        ),
        _onBackgroundFetch,
        _onBackgroundFetchTimeout,
      );
      print('[BackgroundFetch] configure success');
    } catch (e) {
      print('[BackgroundFetch] configure ERROR: $e');
    }
  }

  /// Callback standard quand background_fetch se déclenche
  void _onBackgroundFetch(String taskId) async {
    // TODO: Votre logique de fetch météo, etc.

    BackgroundFetch.finish(taskId);
  }

  void _onBackgroundFetchTimeout(String taskId) {
    print("[BackgroundFetch] TIMEOUT: $taskId");
    BackgroundFetch.finish(taskId);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      title: 'AtmoPulse',
      theme: ThemeData(primarySwatch: Colors.blue),
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => HomePage(),
      },
    );
  }
}
