import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// Custom exception for local storage service errors
class LocalStorageException implements Exception {
  final String message;
  final String? details;
  
  LocalStorageException(this.message, [this.details]);
  
  @override
  String toString() => 'LocalStorageException: $message${details != null ? ' - $details' : ''}';
}

/// Service class for handling all local storage operations
class LocalStorageService {
  static const String _coursesKey = 'courses';
  static const String _notesKey = 'notes';
  static const String _deadlinesKey = 'deadlines';
  static const String _attachmentsKey = 'attachments';
  
  // ---------------------
  // COURSES
  // ---------------------
  
  /// Add a new course to local storage
  /// 
  /// Throws [LocalStorageException] if the operation fails
  static Future<void> addCourse({
    required String title,
    required String code,
    required String instructor,
    required List<Map<String, String>> schedule,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final courses = await getCourses();
      
      final newCourse = {
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'title': title.trim(),
        'code': code.trim().toUpperCase(),
        'instructor': instructor.trim(),
        'schedule': schedule,
        'created_at': DateTime.now().toIso8601String(),
      };
      
      courses.add(newCourse);
      await prefs.setString(_coursesKey, jsonEncode(courses));
    } catch (e) {
      throw LocalStorageException('Failed to add course', e.toString());
    }
  }

  /// Get all courses with optional search
  /// 
  /// Returns a list of courses, optionally filtered by search query
  /// Throws [LocalStorageException] if the operation fails
  static Future<List<Map<String, dynamic>>> getCourses({String? searchQuery}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final coursesJson = prefs.getString(_coursesKey);
      
      if (coursesJson == null) return [];
      
      final courses = List<Map<String, dynamic>>.from(
        jsonDecode(coursesJson).map((x) => Map<String, dynamic>.from(x))
      );
      
      if (searchQuery != null && searchQuery.trim().isNotEmpty) {
        final query = searchQuery.trim().toLowerCase();
        return courses.where((course) {
          final title = course['title']?.toString().toLowerCase() ?? '';
          final code = course['code']?.toString().toLowerCase() ?? '';
          return title.contains(query) || code.contains(query);
        }).toList();
      }
      
      return courses;
    } catch (e) {
      throw LocalStorageException('Failed to fetch courses', e.toString());
    }
  }

  /// Update an existing course
  /// 
  /// Throws [LocalStorageException] if the operation fails
  static Future<void> updateCourse(String id, Map<String, dynamic> updates) async {
    try {
      if (id.isEmpty) {
        throw LocalStorageException('Course ID cannot be empty');
      }
      
      final prefs = await SharedPreferences.getInstance();
      final courses = await getCourses();
      
      final index = courses.indexWhere((course) => course['id'] == id);
      if (index == -1) {
        throw LocalStorageException('Course not found with ID: $id');
      }
      
      // Add updated timestamp
      updates['updated_at'] = DateTime.now().toIso8601String();
      
      courses[index].addAll(updates);
      await prefs.setString(_coursesKey, jsonEncode(courses));
    } catch (e) {
      throw LocalStorageException('Failed to update course', e.toString());
    }
  }

  /// Delete a course and all related data
  /// 
  /// Throws [LocalStorageException] if the operation fails
  static Future<void> deleteCourse(String id) async {
    try {
      if (id.isEmpty) {
        throw LocalStorageException('Course ID cannot be empty');
      }
      
      final prefs = await SharedPreferences.getInstance();
      
      // Delete related data first
      await deleteNotesByCourseId(id);
      await deleteDeadlinesByCourseId(id);
      await deleteAttachmentsByCourseId(id);
      
      // Delete course
      final courses = await getCourses();
      courses.removeWhere((course) => course['id'] == id);
      await prefs.setString(_coursesKey, jsonEncode(courses));
    } catch (e) {
      throw LocalStorageException('Failed to delete course', e.toString());
    }
  }

  // ---------------------
  // NOTES
  // ---------------------
  
  /// Add a new note to a course
  /// 
  /// Throws [LocalStorageException] if the operation fails
  static Future<void> addNote({
    required String courseId,
    required String title,
    required String content,
  }) async {
    try {
      if (courseId.isEmpty) {
        throw LocalStorageException('Course ID cannot be empty');
      }
      
      final prefs = await SharedPreferences.getInstance();
      final notes = await getNotes(courseId);
      
      final newNote = {
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'course_id': courseId,
        'title': title.trim(),
        'content': content.trim(),
        'created_at': DateTime.now().toIso8601String(),
      };
      
      notes.add(newNote);
      await prefs.setString(_notesKey, jsonEncode(notes));
    } catch (e) {
      throw LocalStorageException('Failed to add note', e.toString());
    }
  }

  /// Get notes for a specific course with optional search
  /// 
  /// Returns a list of notes for the specified course
  /// Throws [LocalStorageException] if the operation fails
  static Future<List<Map<String, dynamic>>> getNotes(String courseId, {String? searchQuery}) async {
    try {
      if (courseId.isEmpty) {
        throw LocalStorageException('Course ID cannot be empty');
      }
      
      final prefs = await SharedPreferences.getInstance();
      final notesJson = prefs.getString(_notesKey);
      
      if (notesJson == null) return [];
      
      final allNotes = List<Map<String, dynamic>>.from(
        jsonDecode(notesJson).map((x) => Map<String, dynamic>.from(x))
      );
      
      final notes = allNotes.where((note) => note['course_id'] == courseId).toList();
      
      if (searchQuery != null && searchQuery.trim().isNotEmpty) {
        final query = searchQuery.trim().toLowerCase();
        return notes.where((note) {
          final title = note['title']?.toString().toLowerCase() ?? '';
          final content = note['content']?.toString().toLowerCase() ?? '';
          return title.contains(query) || content.contains(query);
        }).toList();
      }
      
      return notes;
    } catch (e) {
      throw LocalStorageException('Failed to fetch notes', e.toString());
    }
  }

  /// Update an existing note
  /// 
  /// Throws [LocalStorageException] if the operation fails
  static Future<void> updateNote(String id, Map<String, dynamic> updates) async {
    try {
      if (id.isEmpty) {
        throw LocalStorageException('Note ID cannot be empty');
      }
      
      final prefs = await SharedPreferences.getInstance();
      final notesJson = prefs.getString(_notesKey);
      
      if (notesJson == null) {
        throw LocalStorageException('No notes found');
      }
      
      final allNotes = List<Map<String, dynamic>>.from(
        jsonDecode(notesJson).map((x) => Map<String, dynamic>.from(x))
      );
      
      final index = allNotes.indexWhere((note) => note['id'] == id);
      if (index == -1) {
        throw LocalStorageException('Note not found with ID: $id');
      }
      
      // Add updated timestamp
      updates['updated_at'] = DateTime.now().toIso8601String();
      
      allNotes[index].addAll(updates);
      await prefs.setString(_notesKey, jsonEncode(allNotes));
    } catch (e) {
      throw LocalStorageException('Failed to update note', e.toString());
    }
  }

  /// Delete a note
  /// 
  /// Throws [LocalStorageException] if the operation fails
  static Future<void> deleteNote(String id) async {
    try {
      if (id.isEmpty) {
        throw LocalStorageException('Note ID cannot be empty');
      }
      
      final prefs = await SharedPreferences.getInstance();
      final notesJson = prefs.getString(_notesKey);
      
      if (notesJson == null) return;
      
      final allNotes = List<Map<String, dynamic>>.from(
        jsonDecode(notesJson).map((x) => Map<String, dynamic>.from(x))
      );
      
      allNotes.removeWhere((note) => note['id'] == id);
      await prefs.setString(_notesKey, jsonEncode(allNotes));
    } catch (e) {
      throw LocalStorageException('Failed to delete note', e.toString());
    }
  }

  /// Delete all notes for a specific course
  static Future<void> deleteNotesByCourseId(String courseId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final notesJson = prefs.getString(_notesKey);
      
      if (notesJson == null) return;
      
      final allNotes = List<Map<String, dynamic>>.from(
        jsonDecode(notesJson).map((x) => Map<String, dynamic>.from(x))
      );
      
      allNotes.removeWhere((note) => note['course_id'] == courseId);
      await prefs.setString(_notesKey, jsonEncode(allNotes));
    } catch (e) {
      throw LocalStorageException('Failed to delete notes for course', e.toString());
    }
  }

  // ---------------------
  // DEADLINES
  // ---------------------
  
  /// Add a new deadline to a course
  /// 
  /// Throws [LocalStorageException] if the operation fails
  static Future<void> addDeadline({
    required String courseId,
    required String note,
    required DateTime dueDate,
    String status = 'pending',
  }) async {
    try {
      if (courseId.isEmpty) {
        throw LocalStorageException('Course ID cannot be empty');
      }
      
      if (dueDate.isBefore(DateTime.now())) {
        throw LocalStorageException('Due date cannot be in the past');
      }
      
      final prefs = await SharedPreferences.getInstance();
      final deadlines = await getDeadlines(courseId);
      
      final newDeadline = {
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'course_id': courseId,
        'note': note.trim(),
        'due_date': dueDate.toIso8601String(),
        'status': status,
        'created_at': DateTime.now().toIso8601String(),
      };
      
      deadlines.add(newDeadline);
      await prefs.setString(_deadlinesKey, jsonEncode(deadlines));
    } catch (e) {
      throw LocalStorageException('Failed to add deadline', e.toString());
    }
  }

  /// Get deadlines for a specific course with optional filtering
  /// 
  /// Returns a list of deadlines for the specified course
  /// Throws [LocalStorageException] if the operation fails
  static Future<List<Map<String, dynamic>>> getDeadlines(
    String courseId, {
    String status = 'all',
    String? searchQuery,
  }) async {
    try {
      if (courseId.isEmpty) {
        throw LocalStorageException('Course ID cannot be empty');
      }
      
      final prefs = await SharedPreferences.getInstance();
      final deadlinesJson = prefs.getString(_deadlinesKey);
      
      if (deadlinesJson == null) return [];
      
      final allDeadlines = List<Map<String, dynamic>>.from(
        jsonDecode(deadlinesJson).map((x) => Map<String, dynamic>.from(x))
      );
      
      var deadlines = allDeadlines.where((deadline) => deadline['course_id'] == courseId).toList();

      if (status != 'all') {
        deadlines = deadlines.where((deadline) => deadline['status'] == status).toList();
      }

      if (searchQuery != null && searchQuery.trim().isNotEmpty) {
        final query = searchQuery.trim().toLowerCase();
        deadlines = deadlines.where((deadline) {
          final note = deadline['note']?.toString().toLowerCase() ?? '';
          return note.contains(query);
        }).toList();
      }

      // Sort by due date
      deadlines.sort((a, b) {
        final dateA = DateTime.parse(a['due_date']);
        final dateB = DateTime.parse(b['due_date']);
        return dateA.compareTo(dateB);
      });

      return deadlines;
    } catch (e) {
      throw LocalStorageException('Failed to fetch deadlines', e.toString());
    }
  }

  /// Update an existing deadline
  /// 
  /// Throws [LocalStorageException] if the operation fails
  static Future<void> updateDeadline(String id, Map<String, dynamic> updates) async {
    try {
      if (id.isEmpty) {
        throw LocalStorageException('Deadline ID cannot be empty');
      }
      
      // Validate due date if it's being updated
      if (updates.containsKey('due_date')) {
        final dueDate = DateTime.parse(updates['due_date']);
        if (dueDate.isBefore(DateTime.now())) {
          throw LocalStorageException('Due date cannot be in the past');
        }
      }
      
      final prefs = await SharedPreferences.getInstance();
      final deadlinesJson = prefs.getString(_deadlinesKey);
      
      if (deadlinesJson == null) {
        throw LocalStorageException('No deadlines found');
      }
      
      final allDeadlines = List<Map<String, dynamic>>.from(
        jsonDecode(deadlinesJson).map((x) => Map<String, dynamic>.from(x))
      );
      
      final index = allDeadlines.indexWhere((deadline) => deadline['id'] == id);
      if (index == -1) {
        throw LocalStorageException('Deadline not found with ID: $id');
      }
      
      // Add updated timestamp
      updates['updated_at'] = DateTime.now().toIso8601String();
      
      allDeadlines[index].addAll(updates);
      await prefs.setString(_deadlinesKey, jsonEncode(allDeadlines));
    } catch (e) {
      throw LocalStorageException('Failed to update deadline', e.toString());
    }
  }

  /// Delete a deadline
  /// 
  /// Throws [LocalStorageException] if the operation fails
  static Future<void> deleteDeadline(String id) async {
    try {
      if (id.isEmpty) {
        throw LocalStorageException('Deadline ID cannot be empty');
      }
      
      final prefs = await SharedPreferences.getInstance();
      final deadlinesJson = prefs.getString(_deadlinesKey);
      
      if (deadlinesJson == null) return;
      
      final allDeadlines = List<Map<String, dynamic>>.from(
        jsonDecode(deadlinesJson).map((x) => Map<String, dynamic>.from(x))
      );
      
      allDeadlines.removeWhere((deadline) => deadline['id'] == id);
      await prefs.setString(_deadlinesKey, jsonEncode(allDeadlines));
    } catch (e) {
      throw LocalStorageException('Failed to delete deadline', e.toString());
    }
  }

  /// Delete all deadlines for a specific course
  static Future<void> deleteDeadlinesByCourseId(String courseId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final deadlinesJson = prefs.getString(_deadlinesKey);
      
      if (deadlinesJson == null) return;
      
      final allDeadlines = List<Map<String, dynamic>>.from(
        jsonDecode(deadlinesJson).map((x) => Map<String, dynamic>.from(x))
      );
      
      allDeadlines.removeWhere((deadline) => deadline['course_id'] == courseId);
      await prefs.setString(_deadlinesKey, jsonEncode(allDeadlines));
    } catch (e) {
      throw LocalStorageException('Failed to delete deadlines for course', e.toString());
    }
  }

  // ---------------------
  // ATTACHMENTS
  // ---------------------
  
  /// Add a new attachment to a course
  /// 
  /// Throws [LocalStorageException] if the operation fails
  static Future<void> addAttachment({
    required String courseId,
    required String type,
    required String fileUrl,
    String? fileName,
    String? description,
  }) async {
    try {
      if (courseId.isEmpty) {
        throw LocalStorageException('Course ID cannot be empty');
      }
      
      if (fileUrl.isEmpty) {
        throw LocalStorageException('File URL cannot be empty');
      }
      
      final prefs = await SharedPreferences.getInstance();
      final attachments = await getAttachments(courseId);
      
      final newAttachment = {
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'course_id': courseId,
        'type': type.trim(),
        'file_url': fileUrl,
        'file_name': fileName?.trim(),
        'description': description?.trim(),
        'created_at': DateTime.now().toIso8601String(),
      };
      
      attachments.add(newAttachment);
      await prefs.setString(_attachmentsKey, jsonEncode(attachments));
    } catch (e) {
      throw LocalStorageException('Failed to add attachment', e.toString());
    }
  }

  /// Get attachments for a specific course with optional filtering
  /// 
  /// Returns a list of attachments for the specified course
  /// Throws [LocalStorageException] if the operation fails
  static Future<List<Map<String, dynamic>>> getAttachments(
    String courseId, {
    String? type,
  }) async {
    try {
      if (courseId.isEmpty) {
        throw LocalStorageException('Course ID cannot be empty');
      }
      
      final prefs = await SharedPreferences.getInstance();
      final attachmentsJson = prefs.getString(_attachmentsKey);
      
      if (attachmentsJson == null) return [];
      
      final allAttachments = List<Map<String, dynamic>>.from(
        jsonDecode(attachmentsJson).map((x) => Map<String, dynamic>.from(x))
      );
      
      var attachments = allAttachments.where((attachment) => attachment['course_id'] == courseId).toList();
      
      if (type != null && type.trim().isNotEmpty) {
        attachments = attachments.where((attachment) => attachment['type'] == type.trim()).toList();
      }
      
      // Sort by creation date
      attachments.sort((a, b) {
        final dateA = DateTime.parse(a['created_at']);
        final dateB = DateTime.parse(b['created_at']);
        return dateB.compareTo(dateA); // Newest first
      });
      
      return attachments;
    } catch (e) {
      throw LocalStorageException('Failed to fetch attachments', e.toString());
    }
  }

  /// Delete an attachment
  /// 
  /// Throws [LocalStorageException] if the operation fails
  static Future<void> deleteAttachment(String id) async {
    try {
      if (id.isEmpty) {
        throw LocalStorageException('Attachment ID cannot be empty');
      }
      
      final prefs = await SharedPreferences.getInstance();
      final attachmentsJson = prefs.getString(_attachmentsKey);
      
      if (attachmentsJson == null) return;
      
      final allAttachments = List<Map<String, dynamic>>.from(
        jsonDecode(attachmentsJson).map((x) => Map<String, dynamic>.from(x))
      );
      
      allAttachments.removeWhere((attachment) => attachment['id'] == id);
      await prefs.setString(_attachmentsKey, jsonEncode(allAttachments));
    } catch (e) {
      throw LocalStorageException('Failed to delete attachment', e.toString());
    }
  }

  /// Delete all attachments for a specific course
  static Future<void> deleteAttachmentsByCourseId(String courseId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final attachmentsJson = prefs.getString(_attachmentsKey);
      
      if (attachmentsJson == null) return;
      
      final allAttachments = List<Map<String, dynamic>>.from(
        jsonDecode(attachmentsJson).map((x) => Map<String, dynamic>.from(x))
      );
      
      allAttachments.removeWhere((attachment) => attachment['course_id'] == courseId);
      await prefs.setString(_attachmentsKey, jsonEncode(allAttachments));
    } catch (e) {
      throw LocalStorageException('Failed to delete attachments for course', e.toString());
    }
  }
  
  // ---------------------
  // UTILITY METHODS
  // ---------------------
  
  /// Get the total count of records for a table
  /// 
  /// Useful for implementing pagination
  static Future<int> getCount(String table, {Map<String, dynamic>? filters}) async {
    try {
      List<Map<String, dynamic>> records = [];
      
      switch (table) {
        case 'courses':
          records = await getCourses();
          break;
        case 'notes':
          if (filters != null && filters.containsKey('course_id')) {
            records = await getNotes(filters['course_id']);
          }
          break;
        case 'deadlines':
          if (filters != null && filters.containsKey('course_id')) {
            records = await getDeadlines(filters['course_id']);
          }
          break;
        case 'attachments':
          if (filters != null && filters.containsKey('course_id')) {
            records = await getAttachments(filters['course_id']);
          }
          break;
      }
      
      return records.length;
    } catch (e) {
      throw LocalStorageException('Failed to get count for $table', e.toString());
    }
  }
  
  /// Check if a record exists
  /// 
  /// Returns true if the record exists, false otherwise
  static Future<bool> recordExists(String table, String field, dynamic value) async {
    try {
      List<Map<String, dynamic>> records = [];
      
      switch (table) {
        case 'courses':
          records = await getCourses();
          break;
        case 'notes':
          records = await getNotes(value); // Assuming course_id for notes
          break;
        case 'deadlines':
          records = await getDeadlines(value); // Assuming course_id for deadlines
          break;
        case 'attachments':
          records = await getAttachments(value); // Assuming course_id for attachments
          break;
      }
      
      return records.isNotEmpty;
    } catch (e) {
      throw LocalStorageException('Failed to check if record exists in $table', e.toString());
    }
  }
  
  /// Clear all data (useful for testing or resetting the app)
  static Future<void> clearAllData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_coursesKey);
      await prefs.remove(_notesKey);
      await prefs.remove(_deadlinesKey);
      await prefs.remove(_attachmentsKey);
    } catch (e) {
      throw LocalStorageException('Failed to clear all data', e.toString());
    }
  }
} 