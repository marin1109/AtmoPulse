import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  // Instance de FlutterLocalNotificationsPlugin
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  // Méthode d'initialisation
  Future<void> init() async {
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
      // iOS, Linux, etc. si nécessaire
    );

    await _flutterLocalNotificationsPlugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (notificationResponse) {
        // Action lors d’un clic sur la notif
      },
    );
  }

  // Méthode pour afficher une notification
  Future<void> showNotification({
    required String title,
    required String body,
    int id = 0,
  }) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'weather_channel_id',
      'weather_channel_name',
      channelDescription: 'Notifications météo',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
    );

    const NotificationDetails platformDetails =
        NotificationDetails(android: androidDetails);

    await _flutterLocalNotificationsPlugin.show(
      id,
      title,
      body,
      platformDetails,
    );
  }

  // Méthode pour annuler toutes les notifications
  Future<void> cancelAllNotifications() async {
    await _flutterLocalNotificationsPlugin.cancelAll();
  }

  // etc. (annuler une notif en particulier, planifier, etc.)
}
