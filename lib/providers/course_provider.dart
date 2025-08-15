import 'package:flutter/material.dart';
import 'package:coursecompanion/models/course_model.dart';
import 'package:coursecompanion/services/supabase_service.dart';

class CourseProvider with ChangeNotifier {
  final List<Course> _courses = [];

  List<Course> get courses => _courses;

  void addCourse(Course course) {
    _courses.add(course);
    notifyListeners();
  }

  void updateCourse(Course updatedCourse) {
  final index = _courses.indexWhere((c) => c.id == updatedCourse.id);
  if (index != -1) {
    _courses[index] = updatedCourse;
    notifyListeners();
  }
}

Future<void> removeCourse(String id) async {
    try {
      // Delete from Supabase first
      await SupabaseService.deleteCourse(id);
      
      // Then remove from local list
      _courses.removeWhere((course) => course.id == id);
      notifyListeners();
    } catch (e) {
      print('Error deleting course: $e');
      rethrow;
    }
  }

  void clearCourses() {
    _courses.clear();
    notifyListeners();
  }

  // Load courses from Supabase
  Future<void> loadCourses() async {
    try {
      final coursesData = await SupabaseService.getCourses();
      _courses.clear();
      
      for (final data in coursesData) {
        _courses.add(Course(
          id: data['id'],
          title: data['title'],
          code: data['code'],
          instructor: data['instructor'] ?? '',
          schedule: List<Map<String, String>>.from(data['schedule'] ?? []),
          colorIndex: data['color_index'] ?? 0,
          color: _parseColor(data['color']),
          attachments: [],
        ));
      }
      
      notifyListeners();
    } catch (e) {
      print('Error loading courses: $e');
      rethrow;
    }
  }

  Color _parseColor(dynamic colorData) {
    try {
      if (colorData != null) {
        final colorStr = colorData.toString();
        if (colorStr.startsWith('#')) {
          return Color(int.parse(colorStr.replaceFirst('#', '0xFF')));
        } else if (colorStr.startsWith('Color(')) {
          return Colors.blue;
        } else {
          return Color(int.parse(colorStr));
        }
      }
      return Colors.blue;
    } catch (e) {
      return Colors.blue;
    }
  }

}
