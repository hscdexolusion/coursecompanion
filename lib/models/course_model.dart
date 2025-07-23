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
}
