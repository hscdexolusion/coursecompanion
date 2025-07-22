// lib/providers/deadline_provider.dart

import 'package:flutter/material.dart';
//import 'package:uuid/uuid.dart';
import '../models/deadline_model.dart';
//import 'package:coursecompanion/views/pages/add_deadline_screen.dart';


class DeadlineProvider with ChangeNotifier {

void markAsCompleted(Deadline deadline) {
  deadline.isCompleted = true;
  notifyListeners();
}

void deleteDeadline(Deadline deadline) {
  _deadlines.remove(deadline);
  notifyListeners();
}


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
    notifyListeners();
  }

  void toggleCompletion(String id) {
    final deadline = _deadlines.firstWhere((d) => d.id == id);
    deadline.isCompleted = !deadline.isCompleted;
    notifyListeners();
  }

  /*void deleteDeadline(String id) {
    _deadlines.removeWhere((d) => d.id == id);
    notifyListeners();
  }*/
}
