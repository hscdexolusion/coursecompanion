import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:coursecompanion/models/reminder_model.dart';
import 'package:coursecompanion/services/notification_service.dart';
import 'package:coursecompanion/services/web_notification_service.dart';
import 'package:uuid/uuid.dart';
import 'package:timezone/timezone.dart' as tz;

class ReminderService {
  static final ReminderService _instance = ReminderService._internal();
  factory ReminderService() => _instance;
  ReminderService._internal();

  final FlutterLocalNotificationsPlugin _notifications = 
      FlutterLocalNotificationsPlugin();
  final Uuid _uuid = Uuid();

  Future<void> initialize() async {
    if (kIsWeb) {
      // Initialize web notifications
      await WebNotificationService().initialize();
      await WebNotificationService().requestPermission();
    } else {
      // Initialize mobile notifications
      await NotificationService.initialize();
    }
  }

  // Schedule a new reminder
  Future<String> scheduleReminder({
    required String title,
    required String description,
    required DateTime scheduledTime,
    String? courseId,
    String? courseName,
    ReminderType type = ReminderType.general,
    ReminderRepeat repeat = ReminderRepeat.once,
  }) async {
    final reminderId = _uuid.v4();
    
    // Create the reminder
    final reminder = Reminder(
      id: reminderId,
      title: title,
      description: description,
      scheduledTime: scheduledTime,
      courseId: courseId,
      courseName: courseName,
      type: type,
      repeat: repeat,
      createdAt: DateTime.now(),
    );

    // Schedule the notification
    await _scheduleNotification(reminder);

    return reminderId;
  }

  // Schedule the actual notification
  Future<void> _scheduleNotification(Reminder reminder) async {
    if (kIsWeb) {
      // Use web notifications
      final now = DateTime.now();
      final delay = reminder.scheduledTime.difference(now);
      
      if (delay.isNegative) {
        // If the time has passed, show immediately
        await WebNotificationService().showNotification(
          title: reminder.title,
          body: reminder.description,
          tag: reminder.id,
        );
      } else {
        // Schedule for later
        await WebNotificationService().scheduleNotification(
          title: reminder.title,
          body: reminder.description,
          delay: delay,
          tag: reminder.id,
        );
      }
    } else {
      // Use mobile notifications
      final androidDetails = AndroidNotificationDetails(
        'reminders_channel',
        'Reminders',
        channelDescription: 'Course and personal reminders',
        importance: Importance.high,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
        color: const Color(0xFF2196F3),
      );

      final iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      final details = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      // Calculate notification ID (unique for each reminder)
      final notificationId = reminder.id.hashCode;

      // Schedule the notification
      await _notifications.zonedSchedule(
        notificationId,
        reminder.title,
        reminder.description,
        tz.TZDateTime.from(reminder.scheduledTime, tz.local),
        details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        payload: reminder.id,
      );
    }

    // If repeating, schedule the next occurrence
    if (reminder.repeat != ReminderRepeat.once) {
      await _scheduleNextRepeat(reminder);
    }
  }

  // Schedule next repeat occurrence
  Future<void> _scheduleNextRepeat(Reminder reminder) async {
    DateTime nextTime = reminder.scheduledTime;
    
    switch (reminder.repeat) {
      case ReminderRepeat.daily:
        nextTime = nextTime.add(const Duration(days: 1));
        break;
      case ReminderRepeat.weekly:
        nextTime = nextTime.add(const Duration(days: 7));
        break;
      case ReminderRepeat.monthly:
        nextTime = DateTime(
          nextTime.year,
          nextTime.month + 1,
          nextTime.day,
          nextTime.hour,
          nextTime.minute,
        );
        break;
      case ReminderRepeat.yearly:
        nextTime = DateTime(
          nextTime.year + 1,
          nextTime.month,
          nextTime.day,
          nextTime.hour,
          nextTime.minute,
        );
        break;
      case ReminderRepeat.once:
        return; // No repeat
    }

    // Create new reminder for next occurrence
    final nextReminder = reminder.copyWith(
      id: _uuid.v4(),
      scheduledTime: nextTime,
      createdAt: DateTime.now(),
    );

    // Schedule the next notification
    await _scheduleNotification(nextReminder);
  }

  // Cancel a reminder
  Future<void> cancelReminder(String reminderId) async {
    if (kIsWeb) {
      await WebNotificationService().cancelNotification(reminderId);
    } else {
      final notificationId = reminderId.hashCode;
      await _notifications.cancel(notificationId);
    }
  }

  // Cancel all reminders
  Future<void> cancelAllReminders() async {
    if (kIsWeb) {
      await WebNotificationService().cancelAllNotifications();
    } else {
      await _notifications.cancelAll();
    }
  }

  // Update an existing reminder
  Future<void> updateReminder(Reminder reminder) async {
    // Cancel the old notification
    await cancelReminder(reminder.id);
    
    // Schedule the new notification
    await _scheduleNotification(reminder);
  }

  // Toggle reminder on/off
  Future<void> toggleReminder(Reminder reminder) async {
    if (reminder.isActive) {
      await cancelReminder(reminder.id);
    } else {
      await _scheduleNotification(reminder);
    }
  }

  // Get pending notifications
  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    return await _notifications.pendingNotificationRequests();
  }

  // Check if reminder is scheduled
  Future<bool> isReminderScheduled(String reminderId) async {
    final pending = await getPendingNotifications();
    final notificationId = reminderId.hashCode;
    return pending.any((notification) => notification.id == notificationId);
  }

  // Reschedule reminder for a different time
  Future<void> rescheduleReminder(
    String reminderId,
    DateTime newTime,
  ) async {
    // Cancel the old notification
    await cancelReminder(reminderId);
    
    // Create new reminder with new time
    // Note: You'll need to update the reminder in your database/storage
    // and then call scheduleReminder again
  }
} 