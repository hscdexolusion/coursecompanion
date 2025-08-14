import 'package:flutter/material.dart';
import '../models/deadline_model.dart';
import '../services/notification_service.dart';

class DeadlineProvider with ChangeNotifier {
  final List<Deadline> _deadlines = [];

  List<Deadline> get allDeadlines => _deadlines;
  List<Deadline> get pendingDeadlines => _deadlines
      .where((d) => !d.isCompleted && d.dueDate.isAfter(DateTime.now()))
      .toList();
  List<Deadline> get completedDeadlines => _deadlines
      .where((d) => d.isCompleted || d.dueDate.isBefore(DateTime.now()))
      .toList();

  void addDeadline(Deadline deadline) {
    _deadlines.add(deadline);

    // Only schedule if the deadline is in the future and not completed
    if (!deadline.isCompleted && deadline.dueDate.isAfter(DateTime.now())) {
      NotificationService.scheduleNotification(
        id: deadline.id.hashCode,
        title: "Upcoming Deadline",
        body: "${deadline.title} is due on ${deadline.dueDate}",
        scheduledDate: deadline.dueDate.subtract(const Duration(hours: 1)),
      );
    }

    notifyListeners();
  }

  void deleteDeadline(Deadline deadline) {
    _deadlines.remove(deadline);

    // Cancel notification
    NotificationService.cancelNotification(deadline.id.hashCode);

    notifyListeners();
  }

  void toggleCompletion(String id) {
    final deadline = _deadlines.firstWhere((d) => d.id == id);
    deadline.isCompleted = !deadline.isCompleted;

    if (deadline.isCompleted) {
      NotificationService.cancelNotification(deadline.id.hashCode);
    } else if (deadline.dueDate.isAfter(DateTime.now())) {
      // Re-schedule if marking back to pending
      NotificationService.scheduleNotification(
        id: deadline.id.hashCode,
        title: "Upcoming Deadline",
        body: "${deadline.title} is due on ${deadline.dueDate}",
        scheduledDate: deadline.dueDate.subtract(const Duration(hours: 1)),
      );
    }

    notifyListeners();
  }

  void updateDeadline(String id, Deadline updatedDeadline) {
    final index = _deadlines.indexWhere((d) => d.id == id);
    if (index != -1) {
      _deadlines[index] = updatedDeadline;

      // Cancel old notification
      NotificationService.cancelNotification(updatedDeadline.id.hashCode);

      // Schedule new one only if pending & in future
      if (!updatedDeadline.isCompleted &&
          updatedDeadline.dueDate.isAfter(DateTime.now())) {
        NotificationService.scheduleNotification(
          id: updatedDeadline.id.hashCode,
          title: 'Updated Deadline',
          body: '${updatedDeadline.title} is due soon!',
          scheduledDate:
              updatedDeadline.dueDate.subtract(const Duration(hours: 1)),
        );
      }

      notifyListeners();
    }
  }

  void markAsCompleted(Deadline deadline) {
    deadline.isCompleted = true;
    NotificationService.cancelNotification(deadline.id.hashCode);
    notifyListeners();
  }
}
