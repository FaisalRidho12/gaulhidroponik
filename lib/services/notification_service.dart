import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
  FlutterLocalNotificationsPlugin();

  static FlutterLocalNotificationsPlugin get plugin => _notificationsPlugin;

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
        if (response.payload == 'go_to_monitoring') {
          navigatorKey.currentState?.pushNamed('/iot-monitoring');
        }
      },
    );
  }

  /// Tampilkan notifikasi dengan channel dan icon yang bisa disesuaikan
  static Future<void> showNotification(
      String title,
      String body, {
        String? payload,
        String channelId = 'default_channel',
        String channelName = 'Default Notifications',
        String icon = '@mipmap/ic_launcher',
      }) async {
    final androidDetails = AndroidNotificationDetails(
      channelId,
      channelName,
      icon: icon,
      channelDescription: 'Notifikasi untuk $channelName',
      importance: Importance.max,
      priority: Priority.high,
    );

    final platformDetails = NotificationDetails(android: androidDetails);

    await _notificationsPlugin.show(
      0,
      title,
      body,
      platformDetails,
      payload: payload,
    );
  }
}
