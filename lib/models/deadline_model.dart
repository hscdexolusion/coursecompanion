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

  Deadline copyWith({
    String? id,
    String? title,
    String? course,
    String? note,
    DateTime? dueDate,
    bool? isCompleted,
  }) {
    return Deadline(
      id: id ?? this.id,
      title: title ?? this.title,
      course: course ?? this.course,
      note: note ?? this.note,
      dueDate: dueDate ?? this.dueDate,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}
