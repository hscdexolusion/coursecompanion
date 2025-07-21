import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

class Course {
  final String title;
  final String code;
  final String instructor;
  final String schedule;
  final int colorIndex;
  final Color color;
  final List<PlatformFile>? attachments;
  


  Course({
    required this.title,
    required this.code,
    required this.instructor,
    required this.schedule,
    required this.colorIndex,
    required this.color,
    this.attachments,
  });
}
