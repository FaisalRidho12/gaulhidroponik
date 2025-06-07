import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
  FlutterLocalNotificationsPlugin();

  static FlutterLocalNotificationsPlugin get plugin => _notificationsPlugin;

  // Tambahkan navigatorKey untuk digunakan di main.dart
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  static Future<void> initialize() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
    );

    await _notificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        // Aksi ketika notifikasi diklik
        if (response.payload == 'go_to_monitoring') {
          navigatorKey.currentState?.pushNamed('/iot-monitoring');
        }
      },
    );
  }

  static Future<void> showNotification(String title, String body, {String? payload}) async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'volume_air_channel',
      'Volume Air Notif',
      icon: 'notification_icon',
      channelDescription: 'Notifikasi untuk volume air',
      importance: Importance.max,
      priority: Priority.high,
    );

    const NotificationDetails platformDetails = NotificationDetails(android: androidDetails);

    await _notificationsPlugin.show(
      0,
      title,
      body,
      platformDetails,
      payload: payload, // Tambahkan payload
    );
  }
}
