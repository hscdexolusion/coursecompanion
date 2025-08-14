import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  // Singleton client
  static final supabase = Supabase.instance.client;

  // ---------------------
  // COURSES
  // ---------------------
  static Future<void> addCourse(String title, String code, String instructor, List<Map<String, String>> schedule) async {
    await supabase.from('courses').insert({
      'title': title,
      'code': code,
      'instructor': instructor,
      'schedule': schedule,
    });
  }

  static Future<List<Map<String, dynamic>>> getCourses({String? searchQuery}) async {
    var query = supabase.from('courses').select();
    if (searchQuery != null && searchQuery.isNotEmpty) {
      query = query.ilike('title', '%$searchQuery%'); // Case-insensitive search
    }
    final response = await query;
    return List<Map<String, dynamic>>.from(response);
  }

  static Future<void> updateCourse(String id, Map<String, dynamic> updates) async {
    await supabase.from('courses').update(updates).eq('id', id);
  }

  static Future<void> deleteCourse(String id) async {
    await supabase.from('courses').delete().eq('id', id);
  }

  // ---------------------
  // NOTES
  // ---------------------
  static Future<void> addNote(String courseId, String title, String content) async {
    await supabase.from('notes').insert({
      'course_id': courseId,
      'title': title,
      'content': content,
    });
  }

  static Future<List<Map<String, dynamic>>> getNotes(String courseId, {String? searchQuery}) async {
    var query = supabase.from('notes').select().eq('course_id', courseId);
    if (searchQuery != null && searchQuery.isNotEmpty) {
      query = query.ilike('title', '%$searchQuery%');
    }
    final response = await query;
    return List<Map<String, dynamic>>.from(response);
  }

  static Future<void> updateNote(String id, Map<String, dynamic> updates) async {
    await supabase.from('notes').update(updates).eq('id', id);
  }

  static Future<void> deleteNote(String id) async {
    await supabase.from('notes').delete().eq('id', id);
  }

  // ---------------------
  // DEADLINES
  // ---------------------
  static Future<void> addDeadline(String courseId, String note, DateTime dueDate) async {
    await supabase.from('deadlines').insert({
      'course_id': courseId,
      'note': note,
      'due_date': dueDate.toIso8601String(),
      'status': 'pending',
    });
  }

  static Future<List<Map<String, dynamic>>> getDeadlines(String courseId, {String status = 'all', String? searchQuery}) async {
    var query = supabase.from('deadlines').select().eq('course_id', courseId);

    if (status != 'all') {
      query = query.eq('status', status); // Filter by pending/completed
    }

    if (searchQuery != null && searchQuery.isNotEmpty) {
      query = query.ilike('note', '%$searchQuery%');
    }

    final response = await query;
    return List<Map<String, dynamic>>.from(response);
  }

  static Future<void> updateDeadline(String id, Map<String, dynamic> updates) async {
    await supabase.from('deadlines').update(updates).eq('id', id);
  }

  static Future<void> deleteDeadline(String id) async {
    await supabase.from('deadlines').delete().eq('id', id);
  }

  // ---------------------
  // ATTACHMENTS
  // ---------------------
  static Future<void> addAttachment(String courseId, String type, String fileUrl) async {
    await supabase.from('attachments').insert({
      'course_id': courseId,
      'type': type,
      'file_url': fileUrl,
    });
  }

  static Future<List<Map<String, dynamic>>> getAttachments(String courseId, [String? type]) async {
    var query = supabase.from('attachments').select().eq('course_id', courseId);
    if (type != null) query = query.eq('type', type);
    final response = await query;
    return List<Map<String, dynamic>>.from(response);
  }

  static Future<void> deleteAttachment(String id) async {
    await supabase.from('attachments').delete().eq('id', id);
  }
}
