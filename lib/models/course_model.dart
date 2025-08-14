import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

class Course {
  final String id;
  final String title;
  final String code;
  final String instructor;
  final List<Map<String, String>> schedule;
  final int colorIndex;
  final Color color;
  final List<PlatformFile>? attachments;
  


  Course({
    required this.id,
    required this.title,
    required this.code,
    required this.instructor,
    required this.schedule,
    required this.colorIndex,
    required this.color,
    this.attachments,
  });

   // Convert a Map to Course
  factory Course.fromMap(Map<String, dynamic> map) {
    return Course(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      code: map['code'] ?? '',
      instructor: map['instructor'] ?? '',
      schedule: List<Map<String, String>>.from(
          map['schedule']?.map((x) => Map<String, String>.from(x)) ?? []),
      colorIndex: map['colorIndex'] ?? 0,
      color: Color(map['color'] ?? 0xFFFFFFFF),
      // attachments can't be stored directly in a map; leave null or handle separately
      attachments: null,
    );
  }

  // Convert Course to Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'code': code,
      'instructor': instructor,
      'schedule': schedule,
      'colorIndex': colorIndex,
      'color': color.value,
      // attachments are not included
    };
  }
}
