import 'package:flutter/material.dart';
import '../models/deadline_model.dart';
import '../services/notification_service.dart';
import '../services/supabase_service.dart';
import 'package:uuid/uuid.dart';

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

      // Add to Supabase
      final response = await SupabaseService.addDeadline(
        courseId: deadline.courseId,
        title: deadline.title,
        description: deadline.description,
        dueDate: deadline.dueDate,
        priority: deadline.priority,
      );

      // Update the deadline with the ID from Supabase
      final updatedDeadline = deadline.copyWith(
        id: response['id'],
        createdAt: DateTime.parse(response['created_at']),
        updatedAt: DateTime.parse(response['updated_at']),
      );

      // Add to local list
      _deadlines.add(updatedDeadline);

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
    } catch (e) {
      print('Error adding deadline: $e');
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

      // Delete from Supabase
      await SupabaseService.deleteDeadline(deadline.id);

      // Remove from local list
      _deadlines.remove(deadline);

      // Cancel notification
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

  Future<void> toggleCompletion(String id) async {
    try {
      final deadline = _deadlines.firstWhere((d) => d.id == id);
      final newCompletionStatus = !deadline.isCompleted;
      
      // Update in Supabase
      await SupabaseService.updateDeadline(id, {
        'is_completed': newCompletionStatus,
      });

      // Update local deadline
      deadline.isCompleted = newCompletionStatus;

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
    } catch (e) {
      print('Error toggling deadline completion: $e');
      rethrow;
    }
  }

  Future<void> updateDeadline(String id, Deadline updatedDeadline) async {
    try {
      _isLoading = true;
      notifyListeners();

      // Update in Supabase
      await SupabaseService.updateDeadline(id, {
        'title': updatedDeadline.title,
        'description': updatedDeadline.description,
        'course_id': updatedDeadline.courseId,
        'course_name': updatedDeadline.courseName,
        'due_date': updatedDeadline.dueDate.toIso8601String(),
        'priority': updatedDeadline.priority,
        'is_completed': updatedDeadline.isCompleted,
      });

      // Update local list
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

  Future<void> markAsCompleted(Deadline deadline) async {
    try {
      // Update in Supabase
      await SupabaseService.updateDeadline(deadline.id, {
        'is_completed': true,
      });

      // Update local deadline
      deadline.isCompleted = true;
      NotificationService.cancelNotification(deadline.id.hashCode);
      notifyListeners();
    } catch (e) {
      print('Error marking deadline as completed: $e');
      rethrow;
    }
  }
}
