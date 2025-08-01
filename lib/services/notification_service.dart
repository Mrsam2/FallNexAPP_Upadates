import 'dart:ui';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:fall_detection/models/fall_event.dart';

class NotificationService {
  final FlutterLocalNotificationsPlugin _notificationsPlugin = FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsIOS =
    DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await _notificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        // Handle notification tap
      },
    );
  }

  // High Alert Notification (90%+)
  Future<void> showHighAlertNotification() async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
    AndroidNotificationDetails(
      'high_alert_channel',
      'High Priority Fall Alerts',
      channelDescription: 'Critical fall detection alerts requiring immediate attention',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: true,
      enableVibration: true,
      playSound: true,
      color: Color(0xFFE53E3E),
      largeIcon: DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
      ongoing: true, // Makes notification persistent
    );

    const DarwinNotificationDetails iOSPlatformChannelSpecifics =
    DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      interruptionLevel: InterruptionLevel.critical,
    );

    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics,
    );

    await _notificationsPlugin.show(
      1, // High alert ID
      '🚨 HIGH ALERT - Fall Detected!',
      'Critical fall detected (90%+ confidence). Immediate attention required!',
      platformChannelSpecifics,
    );
  }

  // Basic Alert Notification (80%+)
  Future<void> showBasicAlertNotification() async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
    AndroidNotificationDetails(
      'basic_alert_channel',
      'Basic Fall Alerts',
      channelDescription: 'Standard fall detection alerts',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
      enableVibration: true,
      playSound: true,
      color: Color(0xFFFF9800),
      largeIcon: DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
    );

    const DarwinNotificationDetails iOSPlatformChannelSpecifics =
    DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      interruptionLevel: InterruptionLevel.active,
    );

    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics,
    );

    await _notificationsPlugin.show(
      2, // Basic alert ID
      '⚠️ BASIC ALERT - Fall Detected',
      'Fall detected with 80%+ confidence. Please check the situation.',
      platformChannelSpecifics,
    );
  }

  // Legacy method for backward compatibility
  Future<void> showFallDetectionNotification() async {
    await showBasicAlertNotification();
  }

  Future<void> showFallDetectedNotification(String title, String body) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
    AndroidNotificationDetails(
      'fall_detection_channel',
      'Fall Detection Alerts',
      channelDescription: 'Alerts when a fall is detected',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: true,
      enableVibration: true,
      playSound: true,
      color: Color(0xFFE53E3E),
      largeIcon: DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
    );

    const DarwinNotificationDetails iOSPlatformChannelSpecifics =
    DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics,
    );

    await _notificationsPlugin.show(
      0,
      title,
      body,
      platformChannelSpecifics,
    );
  }

  Future<void> sendFallAlert(FallEvent fallEvent) async {
    // Determine alert type based on probability
    if (fallEvent.probability >= 0.90) {
      await showHighAlertNotification();
    } else if (fallEvent.probability >= 0.80) {
      await showBasicAlertNotification();
    }

    print('Sending tiered fall alert to emergency contacts');
    print('Fall detected at: ${fallEvent.timestamp}');
    print('Location: ${fallEvent.location}');
    print('Alert Level: ${fallEvent.probability >= 0.90 ? "HIGH" : fallEvent.probability >= 0.80 ? "BASIC" : "MINOR"}');
  }

  Future<void> cancelFallAlert() async {
    await _notificationsPlugin.cancel(0);
    await _notificationsPlugin.cancel(1);
    await _notificationsPlugin.cancel(2);
  }
}
