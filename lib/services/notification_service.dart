import 'dart:io';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tzData;
import 'package:permission_handler/permission_handler.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  /// Initialize plugin and timezone data
  static Future<void> initialize() async {
    tzData.initializeTimeZones();
    print('NotificationService: Timezone initialized, local: ${tz.local.name}');

    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const DarwinInitializationSettings iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    bool? initialized = await _notificationsPlugin.initialize(initSettings);
    print('NotificationService: Initialized = $initialized');

    // Create Android notification channel
    if (Platform.isAndroid) {
      const AndroidNotificationChannel channel = AndroidNotificationChannel(
        'deadline_channel',
        'Deadlines',
        description: 'Notification channel for deadline reminders',
        importance: Importance.max,
        playSound: true,
        enableVibration: true,
      );
      final androidPlugin = _notificationsPlugin
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
      await androidPlugin?.createNotificationChannel(channel);
      print('NotificationService: Android channel created');
    }
  }

  /// Request notification and alarm permissions
  static Future<bool> requestNotificationPermissions() async {
    bool granted = false;
    if (Platform.isAndroid) {
      granted = await Permission.notification.request().isGranted;
      final alarmGranted = await Permission.scheduleExactAlarm.request().isGranted;
      granted = granted && alarmGranted;
    } else if (Platform.isIOS) {
      granted = (await _notificationsPlugin
              .resolvePlatformSpecificImplementation<
                  IOSFlutterLocalNotificationsPlugin>()
              ?.requestPermissions(alert: true, badge: true, sound: true)) ??
          false;
    }
    return granted;
  }

  /// Show an immediate test notification
  static Future<void> showTestNotification() async {
    await _notificationsPlugin.show(
      0,
      'Test Notification',
      'This is a test to verify notifications',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'deadline_channel',
          'Deadlines',
          channelDescription: 'Notification channel for deadlines',
          importance: Importance.max,
          priority: Priority.high,
          playSound: true,
          enableVibration: true,
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
    );
  }

  /// Check active notifications (Android only)
  static Future<void> checkActiveNotifications() async {
    if (Platform.isAndroid) {
      final androidPlugin = _notificationsPlugin
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
      final activeNotifications = await androidPlugin?.getActiveNotifications();
      print('Active notifications: $activeNotifications');
    }
  }

  /// Schedule a single notification
  static Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
  }) async {
    final now = DateTime.now();
    final tzScheduledDate = tz.TZDateTime.from(scheduledDate, tz.local);

    if (tzScheduledDate.isBefore(tz.TZDateTime.now(tz.local))) {
      print('Skipping past notification: $tzScheduledDate');
      return;
    }

    await _notificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      tzScheduledDate,
      NotificationDetails(
        android: AndroidNotificationDetails(
          'deadline_channel',
          'Deadlines',
          channelDescription: 'Channel for deadline notifications',
          importance: Importance.max,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }

  /// Schedule 1h, 30m, and exact deadline alerts
  static Future<void> scheduleDeadlineNotifications({
    required int baseId,
    required String title,
    required String body,
    required DateTime dueDate,
  }) async {
    if (!await requestNotificationPermissions()) {
      print('Permission denied. Cannot schedule.');
      return;
    }

    final now = DateTime.now();
    final alerts = [
      {'time': dueDate.subtract(const Duration(hours: 1)), 'label': '1 hour before'},
      {'time': dueDate.subtract(const Duration(minutes: 30)), 'label': '30 minutes before'},
      {'time': dueDate, 'label': 'Deadline now'},
    ];

    for (int i = 0; i < alerts.length; i++) {
      final scheduledTime = alerts[i]['time'] as DateTime;
      final label = alerts[i]['label'] as String;

      if (scheduledTime.isAfter(now.add(const Duration(seconds: 5)))) {
        await scheduleNotification(
          id: baseId * 10 + i,
          title: title,
          body: '$body ($label)',
          scheduledDate: scheduledTime,
        );
      } else {
        print('Skipping $label because it’s too soon or past.');
      }
    }
  }

  /// Cancel a single notification by ID
  static Future<void> cancelNotification(int id) async {
    await _notificationsPlugin.cancel(id);
  }

  /// Cancel all deadline notifications
  static Future<void> cancelDeadlineNotifications(int baseId) async {
    for (int i = 0; i < 3; i++) {
      await cancelNotification(baseId * 10 + i);
    }
  }
}
