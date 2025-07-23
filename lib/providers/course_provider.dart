import 'package:flutter/material.dart';
import 'package:coursecompanion/models/course_model.dart';

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

void removeCourse(String id) {
    _courses.removeWhere((course) => course.id == id);
    notifyListeners();
  }

}
