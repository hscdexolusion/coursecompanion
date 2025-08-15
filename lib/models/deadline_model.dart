// lib/models/deadline.dart


class Deadline {
  final String id;
  final String title;
  final String description;
  final String courseId;
  final String courseName;
  final DateTime dueDate;
  final String priority;
  final DateTime createdAt;
  final DateTime updatedAt;
  bool isCompleted;

  Deadline({
    required this.id,
    required this.title,
    required this.description,
    required this.courseId,
    required this.courseName,
    required this.dueDate,
    this.priority = 'medium',
    required this.createdAt,
    required this.updatedAt,
    this.isCompleted = false,
  });

  Deadline copyWith({
    String? id,
    String? title,
    String? description,
    String? courseId,
    String? courseName,
    DateTime? dueDate,
    String? priority,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isCompleted,
  }) {
    return Deadline(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      courseId: courseId ?? this.courseId,
      courseName: courseName ?? this.courseName,
      dueDate: dueDate ?? this.dueDate,
      priority: priority ?? this.priority,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'course_id': courseId,
      'course_name': courseName,
      'due_date': dueDate.toIso8601String(),
      'priority': priority,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'is_completed': isCompleted,
    };
  }

  factory Deadline.fromMap(Map<String, dynamic> map) {
    return Deadline(
      id: map['id'],
      title: map['title'],
      description: map['description'] ?? '',
      courseId: map['course_id'] ?? '',
      courseName: map['course_name'] ?? '',
      dueDate: DateTime.parse(map['due_date']),
      priority: map['priority'] ?? 'medium',
      createdAt: DateTime.parse(map['created_at']),
      updatedAt: DateTime.parse(map['updated_at']),
      isCompleted: map['is_completed'] ?? false,
    );
  }
}
