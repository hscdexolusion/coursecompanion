import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseServiceException implements Exception {
  final String message;
  final String? details;

  SupabaseServiceException(this.message, [this.details]);

  @override
  String toString() => 'SupabaseServiceException: $message${details != null ? ' - $details' : ''}';
}

class SupabaseService {
  static SupabaseClient get _client => Supabase.instance.client;

  // ===== COURSES =====
  
  /// Add a new course to Supabase
  static Future<Map<String, dynamic>> addCourse({
    required String title,
    required String code,
    String? instructor,
    List<Map<String, String>>? schedule,
    int? colorIndex,
    String? color,
  }) async {
    try {
      final courseData = {
      'title': title,
      'code': code,
        'instructor': instructor ?? '',
        'schedule': schedule ?? [],
        'color_index': colorIndex ?? 0,
        'color': color ?? '#2196F3',
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      };

      final response = await _client
          .from('courses')
          .insert(courseData)
          .select()
          .single();

      return response;
    } catch (e) {
      throw SupabaseServiceException(
        'Failed to add course',
        e.toString(),
      );
    }
  }

  /// Get all courses from Supabase
  static Future<List<Map<String, dynamic>>> getCourses() async {
    try {
      final response = await _client
          .from('courses')
          .select()
          .order('created_at', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw SupabaseServiceException(
        'Failed to fetch courses',
        e.toString(),
      );
    }
  }

  /// Update an existing course
  static Future<Map<String, dynamic>> updateCourse(
    String id,
    Map<String, dynamic> updates,
  ) async {
    try {
      updates['updated_at'] = DateTime.now().toIso8601String();

      final response = await _client
          .from('courses')
          .update(updates)
          .eq('id', id)
          .select()
          .single();

      return response;
    } catch (e) {
      throw SupabaseServiceException(
        'Failed to update course',
        e.toString(),
      );
    }
  }

  /// Delete a course by ID
  static Future<void> deleteCourse(String id) async {
    try {
      await _client
          .from('courses')
          .delete()
          .eq('id', id);
    } catch (e) {
      throw SupabaseServiceException(
        'Failed to delete course',
        e.toString(),
      );
    }
  }

  // ===== NOTES =====
  
  /// Add a new note to Supabase
  static Future<Map<String, dynamic>> addNote({
    required String courseId,
    required String title,
    required String content,
    String? tags,
  }) async {
    try {
      final noteData = {
      'course_id': courseId,
      'title': title,
      'content': content,
        'tags': tags ?? '',
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      };

      final response = await _client
          .from('notes')
          .insert(noteData)
          .select()
          .single();

      return response;
    } catch (e) {
      throw SupabaseServiceException(
        'Failed to add note',
        e.toString(),
      );
    }
  }

  /// Get all notes from Supabase
  static Future<List<Map<String, dynamic>>> getNotes() async {
    try {
      final response = await _client
          .from('notes')
          .select()
          .order('created_at', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw SupabaseServiceException(
        'Failed to fetch notes',
        e.toString(),
      );
    }
  }

  /// Update an existing note
  static Future<Map<String, dynamic>> updateNote(
    String id,
    Map<String, dynamic> updates,
  ) async {
    try {
      updates['updated_at'] = DateTime.now().toIso8601String();

      final response = await _client
          .from('notes')
          .update(updates)
          .eq('id', id)
          .select()
          .single();

      return response;
    } catch (e) {
      throw SupabaseServiceException(
        'Failed to update note',
        e.toString(),
      );
    }
  }

  /// Delete a note by ID
  static Future<void> deleteNote(String id) async {
    try {
      await _client
          .from('notes')
          .delete()
          .eq('id', id);
    } catch (e) {
      throw SupabaseServiceException(
        'Failed to delete note',
        e.toString(),
      );
    }
  }

  // ===== DEADLINES =====
  
  /// Add a new deadline to Supabase
  static Future<Map<String, dynamic>> addDeadline({
    required String courseId,
    required String title,
    required String description,
    required DateTime dueDate,
    String? priority,
  }) async {
    try {
      final deadlineData = {
      'course_id': courseId,
        'title': title,
        'description': description,
      'due_date': dueDate.toIso8601String(),
        'priority': priority ?? 'medium',
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      };

      final response = await _client
          .from('deadlines')
          .insert(deadlineData)
          .select()
          .single();

      return response;
    } catch (e) {
      throw SupabaseServiceException(
        'Failed to add deadline',
        e.toString(),
      );
    }
  }

  /// Get all deadlines from Supabase
  static Future<List<Map<String, dynamic>>> getDeadlines() async {
    try {
      final response = await _client
          .from('deadlines')
          .select()
          .order('due_date', ascending: true);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw SupabaseServiceException(
        'Failed to fetch deadlines',
        e.toString(),
      );
    }
  }

  /// Update an existing deadline
  static Future<Map<String, dynamic>> updateDeadline(
    String id,
    Map<String, dynamic> updates,
  ) async {
    try {
      updates['updated_at'] = DateTime.now().toIso8601String();

      final response = await _client
          .from('deadlines')
          .update(updates)
          .eq('id', id)
          .select()
          .single();

      return response;
    } catch (e) {
      throw SupabaseServiceException(
        'Failed to update deadline',
        e.toString(),
      );
    }
  }

  /// Delete a deadline by ID
  static Future<void> deleteDeadline(String id) async {
    try {
      await _client
          .from('deadlines')
          .delete()
          .eq('id', id);
    } catch (e) {
      throw SupabaseServiceException(
        'Failed to delete deadline',
        e.toString(),
      );
    }
  }

  // ===== ATTACHMENTS =====
  
  /// Add a new attachment to Supabase
  static Future<Map<String, dynamic>> addAttachment({
    required String courseId,
    required String fileName,
    required String fileUrl,
    String? fileType,
    int? fileSize,
  }) async {
    try {
      final attachmentData = {
      'course_id': courseId,
        'file_name': fileName,
      'file_url': fileUrl,
        'file_type': fileType ?? '',
        'file_size': fileSize ?? 0,
        'created_at': DateTime.now().toIso8601String(),
      };

      final response = await _client
          .from('attachments')
          .insert(attachmentData)
          .select()
          .single();

      return response;
    } catch (e) {
      throw SupabaseServiceException(
        'Failed to add attachment',
        e.toString(),
      );
    }
  }

  /// Get all attachments from Supabase
  static Future<List<Map<String, dynamic>>> getAttachments() async {
    try {
      final response = await _client
          .from('attachments')
          .select()
          .order('created_at', ascending: false);

    return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw SupabaseServiceException(
        'Failed to fetch attachments',
        e.toString(),
      );
    }
  }

  /// Delete an attachment by ID
  static Future<void> deleteAttachment(String id) async {
    try {
      await _client
          .from('attachments')
          .delete()
          .eq('id', id);
    } catch (e) {
      throw SupabaseServiceException(
        'Failed to delete attachment',
        e.toString(),
      );
    }
  }

  // ===== UTILITY METHODS =====
  
  /// Get count of records in a table
  static Future<int> getCount(String table) async {
    try {
      final response = await _client.from(table).select('*');
      return response.length;
    } catch (e) {
      throw SupabaseServiceException(
        'Failed to get count from $table',
        e.toString(),
      );
    }
  }

  /// Clear all data from all tables (use with caution!)
  static Future<void> clearAllData() async {
    try {
      await _client.from('attachments').delete().neq('id', '');
      await _client.from('deadlines').delete().neq('id', '');
      await _client.from('notes').delete().neq('id', '');
      await _client.from('courses').delete().neq('id', '');
    } catch (e) {
      throw SupabaseServiceException(
        'Failed to clear all data',
        e.toString(),
      );
    }
  }
} 