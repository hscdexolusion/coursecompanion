import 'package:flutter/material.dart';
import '../models/deadline_model.dart';
import '../services/notification_service.dart';
import '../services/supabase_service.dart';

class DeadlineProvider with ChangeNotifier {
  final List<Deadline> _deadlines = [];
  bool _isLoading = false;

  List<Deadline> get allDeadlines => _deadlines;
  List<Deadline> get pendingDeadlines => _deadlines
      .where((d) => !d.isCompleted && d.dueDate.isAfter(DateTime.now()))
      .toList();
  List<Deadline> get completedDeadlines => _deadlines
      .where((d) => d.isCompleted || d.dueDate.isBefore(DateTime.now()))
      .toList();
  bool get isLoading => _isLoading;

  // Load deadlines from Supabase
  Future<void> loadDeadlines() async {
    try {
      _isLoading = true;
      notifyListeners();

      final deadlinesData = await SupabaseService.getDeadlines();
      _deadlines.clear();

      for (final data in deadlinesData) {
        _deadlines.add(Deadline.fromMap(data));
      }

      notifyListeners();
    } catch (e) {
      print('Error loading deadlines: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addDeadline(Deadline deadline) async {
    try {
      _isLoading = true;
      notifyListeners();

      final response = await SupabaseService.addDeadline(
        courseId: deadline.courseId,
        title: deadline.title,
        description: deadline.description,
        dueDate: deadline.dueDate,
        priority: deadline.priority,
      );

      final updatedDeadline = deadline.copyWith(
        id: response['id'],
        createdAt: DateTime.parse(response['created_at']),
        updatedAt: DateTime.parse(response['updated_at']),
        isCompleted: response['is_completed'] ?? false,
      );

      _deadlines.add(updatedDeadline);

      if (!updatedDeadline.isCompleted &&
          updatedDeadline.dueDate.isAfter(DateTime.now())) {
        NotificationService.scheduleNotification(
          id: updatedDeadline.id.hashCode,
          title: "Upcoming Deadline",
          body: "${updatedDeadline.title} is due on ${updatedDeadline.dueDate}",
          scheduledDate:
              updatedDeadline.dueDate.subtract(const Duration(hours: 1)),
        );
      }

      notifyListeners();
    } catch (e) {
      print('Error adding deadline: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateDeadline(String id, Deadline updatedDeadline) async {
    try {
      _isLoading = true;
      notifyListeners();

      await SupabaseService.updateDeadline(id, {
        'title': updatedDeadline.title,
        'description': updatedDeadline.description,
        'course_id': updatedDeadline.courseId,
        'course_name': updatedDeadline.courseName,
        'due_date': updatedDeadline.dueDate.toIso8601String(),
        'priority': updatedDeadline.priority,
        'is_completed': updatedDeadline.isCompleted,
      });

      final index = _deadlines.indexWhere((d) => d.id == id);
      if (index != -1) {
        _deadlines[index] = updatedDeadline;

        NotificationService.cancelNotification(updatedDeadline.id.hashCode);

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
      }

      notifyListeners();
    } catch (e) {
      print('Error updating deadline: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteDeadline(Deadline deadline) async {
    try {
      _isLoading = true;
      notifyListeners();

      await SupabaseService.deleteDeadline(deadline.id);
      _deadlines.remove(deadline);
      NotificationService.cancelNotification(deadline.id.hashCode);

      notifyListeners();
    } catch (e) {
      print('Error deleting deadline: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> markAsCompleted(Deadline deadline) async {
    try {
      await SupabaseService.updateDeadline(deadline.id, {'is_completed': true});
      deadline.isCompleted = true;
      NotificationService.cancelNotification(deadline.id.hashCode);
      notifyListeners();
    } catch (e) {
      print('Error marking deadline as completed: $e');
      rethrow;
    }
  }

  Future<void> toggleCompletion(String id) async {
    try {
      final deadline = _deadlines.firstWhere((d) => d.id == id);
      final newCompletionStatus = !deadline.isCompleted;

      await SupabaseService.updateDeadline(id, {'is_completed': newCompletionStatus});

      deadline.isCompleted = newCompletionStatus;

      if (deadline.isCompleted) {
        NotificationService.cancelNotification(deadline.id.hashCode);
      } else if (deadline.dueDate.isAfter(DateTime.now())) {
        NotificationService.scheduleNotification(
          id: deadline.id.hashCode,
          title: "Upcoming Deadline",
          body: "${deadline.title} is due on ${deadline.dueDate}",
          scheduledDate: deadline.dueDate.subtract(const Duration(hours: 1)),
        );
      }

      notifyListeners();
    } catch (e) {
      print('Error toggling deadline completion: $e');
      rethrow;
    }
  }
}
