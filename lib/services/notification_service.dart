import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(settings);
  }

  Future<void> showItemAddedNotification({
    required String userName,
    required String itemName,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'item_updates',
      'Item Updates',
      channelDescription: 'Notifications for item additions and updates',
      importance: Importance.high,
      priority: Priority.high,
    );

    const iosDetails = DarwinNotificationDetails();

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(
      DateTime.now().millisecond,
      'New Item Added',
      '$userName added $itemName to the list',
      details,
    );
  }

  Future<void> showWeekCompletedNotification({
    required int weekNumber,
    required int itemsCompleted,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'week_updates',
      'Week Updates',
      channelDescription: 'Notifications for weekly list completions',
      importance: Importance.high,
      priority: Priority.high,
    );

    const iosDetails = DarwinNotificationDetails();

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(
      DateTime.now().millisecond,
      'Week $weekNumber Completed! 🎉',
      'You completed $itemsCompleted items this week',
      details,
    );
  }
}
