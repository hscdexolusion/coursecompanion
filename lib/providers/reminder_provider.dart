import 'package:flutter/foundation.dart';
import 'package:coursecompanion/models/reminder_model.dart';

class ReminderProvider extends ChangeNotifier {
  List<Reminder> _reminders = [];
  bool _isLoading = false;

  List<Reminder> get reminders => _reminders;
  bool get isLoading => _isLoading;

  // Get active reminders
  List<Reminder> get activeReminders => 
      _reminders.where((reminder) => reminder.isActive).toList();

  // Get reminders for a specific course
  List<Reminder> getRemindersForCourse(String courseId) =>
      _reminders.where((reminder) => reminder.courseId == courseId).toList();

  // Get upcoming reminders (next 7 days)
  List<Reminder> get upcomingReminders {
    final now = DateTime.now();
    final nextWeek = now.add(const Duration(days: 7));
    
    return _reminders.where((reminder) {
      return reminder.isActive && 
             reminder.scheduledTime.isAfter(now) && 
             reminder.scheduledTime.isBefore(nextWeek);
    }).toList()
      ..sort((a, b) => a.scheduledTime.compareTo(b.scheduledTime));
  }

  // Get overdue reminders
  List<Reminder> get overdueReminders {
    final now = DateTime.now();
    return _reminders.where((reminder) {
      return reminder.isActive && reminder.scheduledTime.isBefore(now);
    }).toList()
      ..sort((a, b) => b.scheduledTime.compareTo(a.scheduledTime));
  }

  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void addReminder(Reminder reminder) {
    _reminders.add(reminder);
    _reminders.sort((a, b) => a.scheduledTime.compareTo(b.scheduledTime));
    notifyListeners();
  }

  void updateReminder(Reminder reminder) {
    final index = _reminders.indexWhere((r) => r.id == reminder.id);
    if (index != -1) {
      _reminders[index] = reminder;
      _reminders.sort((a, b) => a.scheduledTime.compareTo(b.scheduledTime));
      notifyListeners();
    }
  }

  void deleteReminder(String id) {
    _reminders.removeWhere((reminder) => reminder.id == id);
    notifyListeners();
  }

  void toggleReminder(String id) {
    final index = _reminders.indexWhere((r) => r.id == id);
    if (index != -1) {
      _reminders[index] = _reminders[index].copyWith(
        isActive: !_reminders[index].isActive,
      );
      notifyListeners();
    }
  }

  void clearReminders() {
    _reminders.clear();
    notifyListeners();
  }

  void loadReminders(List<Reminder> reminders) {
    _reminders = reminders;
    _reminders.sort((a, b) => a.scheduledTime.compareTo(b.scheduledTime));
    notifyListeners();
  }

  // Get reminders by type
  List<Reminder> getRemindersByType(ReminderType type) {
    return _reminders.where((reminder) => reminder.type == type).toList();
  }

  // Get reminders for today
  List<Reminder> get todaysReminders {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    
    return _reminders.where((reminder) {
      return reminder.isActive && 
             reminder.scheduledTime.isAfter(today) && 
             reminder.scheduledTime.isBefore(tomorrow);
    }).toList()
      ..sort((a, b) => a.scheduledTime.compareTo(b.scheduledTime));
  }
} 