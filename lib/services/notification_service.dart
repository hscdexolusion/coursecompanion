//```dart
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
           final channels = await androidPlugin?.getNotificationChannels();
           print('NotificationService: Available channels: $channels');
         }
       }

       /// Request notification and alarm permissions
       static Future<bool> requestNotificationPermissions() async {
         bool granted = false;
         if (Platform.isAndroid) {
           granted = await Permission.notification.request().isGranted;
           print('NotificationService: Android notification permission = $granted');
           final alarmGranted = await Permission.scheduleExactAlarm.request().isGranted;
           print('NotificationService: Android schedule exact alarm permission = $alarmGranted');
           granted = granted && alarmGranted;
         } else if (Platform.isIOS) {
           granted = (await _notificationsPlugin
                   .resolvePlatformSpecificImplementation<
                       IOSFlutterLocalNotificationsPlugin>()
                   ?.requestPermissions(alert: true, badge: true, sound: true)) ??
               false;
           print('NotificationService: iOS notification permission = $granted');
         }
         if (!granted) {
           print('NotificationService: Permissions not granted');
         }
         return granted;
       }

       /// Show an immediate test notification
       static Future<void> showTestNotification() async {
         try {
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
           print('NotificationService: Test notification shown');
         } catch (e) {
           print('NotificationService: Error showing test notification: $e');
         }
       }

       /// Check active notifications
       static Future<void> checkActiveNotifications() async {
         if (Platform.isAndroid) {
           final androidPlugin = _notificationsPlugin
               .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
           final activeNotifications = await androidPlugin?.getActiveNotifications();
           print('NotificationService: Active notifications: $activeNotifications');
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
         print('NotificationService: Scheduling notification $id for $scheduledDate (TZ: $tzScheduledDate, Now: $now)');

         if (tzScheduledDate.isBefore(tz.TZDateTime.now(tz.local))) {
           print('NotificationService: Skipping past notification for $tzScheduledDate');
           return;
         }

         try {
           await _notificationsPlugin.zonedSchedule(
             id,
             title,
             body,
             tzScheduledDate,
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
             androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
           );
           print('NotificationService: Scheduled notification $id for $tzScheduledDate');
           await checkActiveNotifications();
         } catch (e) {
           print('NotificationService: Error scheduling notification (exact): $e');
           // Fallback to inexact scheduling
           try {
             await _notificationsPlugin.zonedSchedule(
               id,
               title,
               body,
               tzScheduledDate,
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
               androidScheduleMode: AndroidScheduleMode.inexact,
             );
             print('NotificationService: Scheduled notification $id (inexact) for $tzScheduledDate');
             await checkActiveNotifications();
           } catch (e) {
             print('NotificationService: Error scheduling notification (inexact): $e');
           }
         }
       }

       /// Schedule three notifications for a deadline: 1h, 30m, and exact time
       static Future<void> scheduleDeadlineNotifications({
         required int baseId,
         required String title,
         required String body,
         required DateTime dueDate,
       }) async {
         bool hasPermission = await requestNotificationPermissions();
         print('NotificationService: Permissions for scheduling: $hasPermission');
         if (!hasPermission) {
           print('NotificationService: Cannot schedule notifications: Permission denied');
           return;
         }

         final times = [
           dueDate.subtract(const Duration(hours: 1)),
           dueDate.subtract(const Duration(minutes: 30)),
           dueDate,
         ];

         print('NotificationService: Scheduling for dueDate $dueDate (baseId: $baseId)');
         for (int i = 0; i < times.length; i++) {
           final time = times[i];
           await scheduleNotification(
             id: baseId * 10 + i,
             title: title,
             body: '$body (${i == 0 ? "1 hour" : i == 1 ? "30 minutes" : "due now"})',
             scheduledDate: time,
           );
         }
         await checkActiveNotifications();
       }

       /// Cancel a single notification by ID
       static Future<void> cancelNotification(int id) async {
         await _notificationsPlugin.cancel(id);
         print('NotificationService: Cancelled notification $id');
       }

       /// Cancel all notifications for a deadline (1h, 30m, exact)
       static Future<void> cancelDeadlineNotifications(int baseId) async {
         for (int i = 0; i < 3; i++) {
           await cancelNotification(baseId * 10 + i);
         }
       }
     }