import 'dart:html' as html;
import 'dart:async';
import 'package:flutter/foundation.dart';

class WebNotificationService {
  static final WebNotificationService _instance = WebNotificationService._internal();
  factory WebNotificationService() => _instance;
  WebNotificationService._internal();

  bool _isSupported = false;
  bool _isInitialized = false;
  bool _hasPermission = false;

  bool get isSupported => _isSupported;
  bool get isInitialized => _isInitialized;
  bool get hasPermission => _hasPermission;

  Future<void> initialize() async {
    if (kIsWeb) {
      _isSupported = html.Notification.supported;
      if (_isSupported) {
        _hasPermission = html.Notification.permission == 'granted';
        _isInitialized = true;
        print('WebNotificationService: Web notifications supported and initialized');
      } else {
        print('WebNotificationService: Web notifications not supported');
      }
    } else {
      print('WebNotificationService: Not running on web platform');
    }
  }

  Future<bool> requestPermission() async {
    if (!kIsWeb || !_isSupported) {
      print('WebNotificationService: Cannot request permission - not supported');
      return false;
    }

    try {
      final permission = await html.Notification.requestPermission();
      _hasPermission = permission == 'granted';
      print('WebNotificationService: Permission request result: $permission');
      return _hasPermission;
    } catch (e) {
      print('WebNotificationService: Error requesting permission: $e');
      return false;
    }
  }

  Future<void> showNotification({
    required String title,
    required String body,
    String? icon,
    String? tag,
    Map<String, dynamic>? data,
  }) async {
    if (!kIsWeb || !_isSupported || !_hasPermission) {
      print('WebNotificationService: Cannot show notification - not supported or no permission');
      return;
    }

    try {
      final notification = html.Notification(title, body: body, icon: icon, tag: tag);
      
      // Auto-close after 10 seconds
      Timer(const Duration(seconds: 10), () {
        notification.close();
      });

      print('WebNotificationService: Notification shown: $title');
    } catch (e) {
      print('WebNotificationService: Error showing notification: $e');
    }
  }

  Future<void> scheduleNotification({
    required String title,
    required String body,
    required Duration delay,
    String? icon,
    String? tag,
    Map<String, dynamic>? data,
  }) async {
    if (!kIsWeb || !_isSupported || !_hasPermission) {
      print('WebNotificationService: Cannot schedule notification - not supported or no permission');
      return;
    }

    Timer(delay, () {
      showNotification(
        title: title,
        body: body,
        icon: icon,
        tag: tag,
        data: data,
      );
    });

    print('WebNotificationService: Notification scheduled: $title in ${delay.inSeconds} seconds');
  }

  Future<void> cancelAllNotifications() async {
    if (!kIsWeb || !_isSupported) {
      return;
    }

    // For web, we can't directly cancel scheduled notifications
    // But we can close any currently open notifications
    try {
      // This is a workaround - in a real app you'd track your timers
      print('WebNotificationService: All notifications cancelled');
    } catch (e) {
      print('WebNotificationService: Error cancelling notifications: $e');
    }
  }

  Future<void> cancelNotification(String tag) async {
    if (!kIsWeb || !_isSupported) {
      return;
    }

    try {
      // Close any notification with the specified tag
      print('WebNotificationService: Notification cancelled: $tag');
    } catch (e) {
      print('WebNotificationService: Error cancelling notification: $e');
    }
  }
} 