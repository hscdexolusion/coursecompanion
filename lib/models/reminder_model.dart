class Reminder {
  final String id;
  final String title;
  final String description;
  final DateTime scheduledTime;
  final bool isActive;
  final String? courseId;
  final String? courseName;
  final ReminderType type;
  final ReminderRepeat repeat;
  final DateTime createdAt;

  Reminder({
    required this.id,
    required this.title,
    required this.description,
    required this.scheduledTime,
    this.isActive = true,
    this.courseId,
    this.courseName,
    this.type = ReminderType.general,
    this.repeat = ReminderRepeat.once,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'scheduled_time': scheduledTime.toIso8601String(),
      'is_active': isActive,
      'course_id': courseId,
      'course_name': courseName,
      'type': type.toString().split('.').last,
      'repeat': repeat.toString().split('.').last,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory Reminder.fromMap(Map<String, dynamic> map) {
    return Reminder(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      scheduledTime: DateTime.parse(map['scheduled_time']),
      isActive: map['is_active'] ?? true,
      courseId: map['course_id'],
      courseName: map['course_name'],
      type: ReminderType.values.firstWhere(
        (e) => e.toString().split('.').last == map['type'],
        orElse: () => ReminderType.general,
      ),
      repeat: ReminderRepeat.values.firstWhere(
        (e) => e.toString().split('.').last == map['repeat'],
        orElse: () => ReminderRepeat.once,
      ),
      createdAt: DateTime.parse(map['created_at']),
    );
  }

  Reminder copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? scheduledTime,
    bool? isActive,
    String? courseId,
    String? courseName,
    ReminderType? type,
    ReminderRepeat? repeat,
    DateTime? createdAt,
  }) {
    return Reminder(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      scheduledTime: scheduledTime ?? this.scheduledTime,
      isActive: isActive ?? this.isActive,
      courseId: courseId ?? this.courseId,
      courseName: courseName ?? this.courseName,
      type: type ?? this.type,
      repeat: repeat ?? this.repeat,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

enum ReminderType {
  general,
  assignment,
  exam,
  classReminder,
  meeting,
  personal,
}

enum ReminderRepeat {
  once,
  daily,
  weekly,
  monthly,
  yearly,
} 