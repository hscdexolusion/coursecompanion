// lib/models/deadline.dart


class Deadline {
  final String id;
  final String title;
  final String course;
  final String note;
  final DateTime dueDate;
  bool isCompleted;

  Deadline({
    required this.id,
    required this.title,
    required this.course,
    required this.note,
    required this.dueDate,
    this.isCompleted = false,
  });
}
