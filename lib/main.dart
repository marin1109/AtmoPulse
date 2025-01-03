import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:background_fetch/background_fetch.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' show Platform;

// Import de mes fichiers
import 'services/notification_service.dart';
import 'utils/user_preferences.dart';
import 'view/home/home_page.dart';

// Import des types

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

  // Initialiser le NotificationService
  await NotificationService().init();

  final userPrefs = UserPreferences();
  
  await userPrefs.initializeDefaultUnits();

  // Enregistrer la tâche headless si mobile
  if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
    BackgroundFetch.registerHeadlessTask(backgroundFetchHeadlessTask);
  } else {
    print("Headless Task non enregistré : plateforme non supportée");
  }

  // Lancer l'application
  runApp(
    ChangeNotifierProvider(
      create: (_) => userPrefs,
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

    final isLoggedIn =
        Provider.of<UserPreferences>(context, listen: false).isLogged;
    if (!isLoggedIn) {
      print('background_fetch désactivé : utilisateur non connecté');
      return;
    }

    try {
      await BackgroundFetch.configure(
        BackgroundFetchConfig(
          minimumFetchInterval: 15, // en minutes
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
