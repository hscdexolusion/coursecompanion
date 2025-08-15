import 'package:flutter/material.dart';
import 'package:coursecompanion/models/course_model.dart';
import 'package:coursecompanion/services/supabase_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class CourseProvider with ChangeNotifier {
  final List<Course> _courses = [];
  bool _isInitialized = false;

  List<Course> get courses => _courses;

  CourseProvider() {
    _initializeCourses();
  }

  Future<void> _initializeCourses() async {
    if (_isInitialized) return;
    
    try {
      // First try to load from local storage
      await _loadFromLocalStorage();
      
      // If no courses in local storage, add sample courses
      if (_courses.isEmpty) {
        await _addSampleCourses();
      }
      
      // Then try to load from Supabase (this will update the local list)
      await _loadFromSupabase();
      
      _isInitialized = true;
      notifyListeners();
    } catch (e) {
      print('Error initializing courses: $e');
      // If everything fails, ensure we have sample courses
      if (_courses.isEmpty) {
        await _addSampleCourses();
      }
      _isInitialized = true;
      notifyListeners();
    }
  }

  Future<void> _loadFromLocalStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final coursesJson = prefs.getString('local_courses');
      
      if (coursesJson != null) {
        final coursesData = jsonDecode(coursesJson) as List;
        _courses.clear();
        
        for (final data in coursesData) {
          // Safely convert schedule data from local storage
          List<Map<String, String>> schedule = [];
          if (data['schedule'] != null) {
            try {
              final scheduleData = data['schedule'] as List;
              schedule = scheduleData.map((item) {
                if (item is Map) {
                  return Map<String, String>.from(item.map((key, value) => 
                    MapEntry(key.toString(), value?.toString() ?? '')
                  ));
                }
                return <String, String>{};
              }).toList();
            } catch (e) {
              print('Error parsing local schedule data: $e');
              schedule = [];
            }
          }
          
          _courses.add(Course(
            id: data['id']?.toString() ?? '',
            title: data['title']?.toString() ?? '',
            code: data['code']?.toString() ?? '',
            instructor: data['instructor']?.toString() ?? '',
            schedule: schedule,
            colorIndex: data['color_index'] ?? 0,
            color: _parseColor(data['color']),
            attachments: [],
          ));
        }
      }
    } catch (e) {
      print('Error loading courses from local storage: $e');
    }
  }

  Future<void> _saveToLocalStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final coursesData = _courses.map((course) => {
        'id': course.id,
        'title': course.title,
        'code': course.code,
        'instructor': course.instructor,
        'schedule': course.schedule,
        'color_index': course.colorIndex,
        'color': course.color.value,
        'attachments': course.attachments,
      }).toList();
      
      await prefs.setString('local_courses', jsonEncode(coursesData));
    } catch (e) {
      print('Error saving courses to local storage: $e');
    }
  }

  Future<void> _addSampleCourses() async {
    final sampleCourses = [
      Course(
        id: 'sample1',
        title: 'Introduction to Computer Science',
        code: 'CS101',
        instructor: 'Dr. Smith',
        schedule: [
          {'day': 'Monday', 'time': '9:00 AM - 10:30 AM'},
          {'day': 'Wednesday', 'time': '9:00 AM - 10:30 AM'},
        ],
        colorIndex: 0,
        color: Colors.blue,
        attachments: [],
      ),
      Course(
        id: 'sample2',
        title: 'Mathematics for Engineers',
        code: 'MATH201',
        instructor: 'Prof. Johnson',
        schedule: [
          {'day': 'Tuesday', 'time': '2:00 PM - 3:30 PM'},
          {'day': 'Thursday', 'time': '2:00 PM - 3:30 PM'},
        ],
        colorIndex: 1,
        color: Colors.green,
        attachments: [],
      ),
    ];
    
    _courses.addAll(sampleCourses);
    await _saveToLocalStorage();
  }

  Future<void> _loadFromSupabase() async {
    try {
      final coursesData = await SupabaseService.getCourses();
      
      if (coursesData.isNotEmpty) {
        _courses.clear();
        
        for (final data in coursesData) {
          try {
            // Safely convert schedule data
            List<Map<String, String>> schedule = [];
            if (data['schedule'] != null) {
              try {
                final scheduleData = data['schedule'] as List;
                schedule = scheduleData.map((item) {
                  if (item is Map) {
                    return Map<String, String>.from(item.map((key, value) => 
                      MapEntry(key.toString(), value?.toString() ?? '')
                    ));
                  }
                  return <String, String>{};
                }).toList();
              } catch (e) {
                print('Error parsing schedule data for course ${data['title']}: $e');
                schedule = [];
              }
            }
            
            _courses.add(Course(
              id: data['id']?.toString() ?? '',
              title: data['title']?.toString() ?? '',
              code: data['code']?.toString() ?? '',
              instructor: data['instructor']?.toString() ?? '',
              schedule: schedule,
              colorIndex: data['color_index'] ?? 0,
              color: _parseColor(data['color']),
              attachments: [],
            ));
          } catch (e) {
            print('Error processing course data: $e');
            print('Problematic data: $data');
            // Continue with next course instead of failing completely
            continue;
          }
        }
        
        // Save to local storage after loading from Supabase
        await _saveToLocalStorage();
      }
    } catch (e) {
      print('Error loading courses from Supabase: $e');
      // Don't rethrow - we'll keep using local courses
    }
  }

  void addCourse(Course course) {
    _courses.add(course);
    _saveToLocalStorage();
    notifyListeners();
  }

  void updateCourse(Course updatedCourse) {
    final index = _courses.indexWhere((c) => c.id == updatedCourse.id);
    if (index != -1) {
      _courses[index] = updatedCourse;
      _saveToLocalStorage();
      notifyListeners();
    }
  }

  Future<void> removeCourse(String id) async {
    try {
      // Delete from Supabase first
      await SupabaseService.deleteCourse(id);
      
      // Then remove from local list
      _courses.removeWhere((course) => course.id == id);
      await _saveToLocalStorage();
      notifyListeners();
    } catch (e) {
      print('Error deleting course: $e');
      rethrow;
    }
  }

  void clearCourses() {
    _courses.clear();
    _saveToLocalStorage();
    notifyListeners();
  }

  // Public method to refresh courses from Supabase
  Future<void> refreshCourses() async {
    try {
      await _loadFromSupabase();
      notifyListeners();
    } catch (e) {
      print('Error refreshing courses from Supabase: $e');
      // If refresh fails, we keep the existing courses
      // The user can try again later
    }
  }

  // Method to check if Supabase is available and working
  Future<bool> isSupabaseAvailable() async {
    try {
      await SupabaseService.getCourses();
      return true; // If we can reach Supabase, it's available
    } catch (e) {
      print('Supabase not available: $e');
      return false;
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
