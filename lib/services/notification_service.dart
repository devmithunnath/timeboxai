import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:window_manager/window_manager.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;

  Future<void> init() async {
    if (_isInitialized) return;

    // Initialize without requesting permissions immediately
    const DarwinInitializationSettings initializationSettingsMacOS =
        DarwinInitializationSettings(
          requestAlertPermission: false,
          requestBadgePermission: false,
          requestSoundPermission: false,
        );

    const InitializationSettings initializationSettings =
        InitializationSettings(macOS: initializationSettingsMacOS);

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (details) async {
        // Bring app to front when notification is clicked
        await windowManager.show();
        await windowManager.focus();
      },
    );
    _isInitialized = true;
    if (kDebugMode) print('NotificationService initialized');
  }

  Future<bool> requestPermissions() async {
    if (kDebugMode) print('Requesting notification permissions...');
    final bool? result = await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
          MacOSFlutterLocalNotificationsPlugin
        >()
        ?.requestPermissions(alert: true, badge: true, sound: true);
    if (kDebugMode) print('Notification permissions result: $result');
    return result ?? false;
  }

  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
  }) async {
    if (!_isInitialized) {
      if (kDebugMode) {
        print('NotificationService NOT initialized. Attempting to init...');
      }
      await init();
    }

    if (kDebugMode) print('Showing notification: $title - $body');
    const DarwinNotificationDetails macOSPlatformChannelSpecifics =
        DarwinNotificationDetails(
          presentSound: true,
          presentAlert: true,
          presentBadge: true,
          interruptionLevel:
              InterruptionLevel.active, // Ensure it shows over other apps
        );

    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      macOS: macOSPlatformChannelSpecifics,
    );

    await flutterLocalNotificationsPlugin.show(
      id,
      title,
      body,
      platformChannelSpecifics,
    );
  }
}
