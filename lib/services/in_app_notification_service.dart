import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

class InAppNotificationService {
  static final InAppNotificationService _instance = InAppNotificationService._internal();
  factory InAppNotificationService() => _instance;
  InAppNotificationService._internal();

  static void showNotification({
    required BuildContext context,
    required String title,
    required String message,
    Duration duration = const Duration(seconds: 4),
    Color backgroundColor = Colors.blue,
    IconData icon = Icons.notifications,
  }) {
    if (!kIsWeb) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    message,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        backgroundColor: backgroundColor,
        duration: duration,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        margin: const EdgeInsets.all(16),
        action: SnackBarAction(
          label: 'Dismiss',
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }

  static void showReminderNotification({
    required BuildContext context,
    required String title,
    required String message,
    String? courseName,
  }) {
    if (!kIsWeb) return;

    final backgroundColor = courseName != null ? Colors.green : Colors.blue;
    final icon = courseName != null ? Icons.school : Icons.notifications;

    showNotification(
      context: context,
      title: title,
      message: courseName != null ? '$message (Course: $courseName)' : message,
      backgroundColor: backgroundColor,
      icon: icon,
      duration: const Duration(seconds: 6),
    );
  }

  static void showSuccessNotification({
    required BuildContext context,
    required String title,
    required String message,
  }) {
    if (!kIsWeb) return;

    showNotification(
      context: context,
      title: title,
      message: message,
      backgroundColor: Colors.green,
      icon: Icons.check_circle,
    );
  }

  static void showErrorNotification({
    required BuildContext context,
    required String title,
    required String message,
  }) {
    if (!kIsWeb) return;

    showNotification(
      context: context,
      title: title,
      message: message,
      backgroundColor: Colors.red,
      icon: Icons.error,
    );
  }

  static void showWarningNotification({
    required BuildContext context,
    required String title,
    required String message,
  }) {
    if (!kIsWeb) return;

    showNotification(
      context: context,
      title: title,
      message: message,
      backgroundColor: Colors.orange,
      icon: Icons.warning,
    );
  }
} 