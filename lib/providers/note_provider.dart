import 'package:flutter/material.dart';
import 'package:coursecompanion/models/note_model.dart';
import 'package:uuid/uuid.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class NoteProvider with ChangeNotifier {
  final List<Note> _notes = [];
  final Uuid _uuid = const Uuid();
  bool _isLoading = false;
  String? _error;
  bool _isInitialized = false;

  List<Note> get notes => List.unmodifiable(_notes);
  bool get isLoading => _isLoading;
  String? get error => _error;

  NoteProvider() {
    _loadNotes();
  }

  Future<void> _loadNotes() async {
    if (_isInitialized) return;
    
    try {
      _setLoading(true);
      _clearError();
      
      // Load notes from local storage
      await _loadFromLocalStorage();
      
      // If no notes in local storage, add sample notes
      if (_notes.isEmpty) {
        await _addSampleNotes();
      }
      
      _isInitialized = true;
      notifyListeners();
    } catch (e) {
      _setError('Failed to load notes: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> _loadFromLocalStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final notesJson = prefs.getString('local_notes');
      
      if (notesJson != null) {
        final notesData = jsonDecode(notesJson) as List;
        _notes.clear();
        
        for (final data in notesData) {
          _notes.add(Note(
            id: data['id'],
            title: data['title'],
            content: data['content'],
            course: data['course'] ?? 'Unassigned',
            createdAt: DateTime.tryParse(data['createdAt']) ?? DateTime.now(),
          ));
        }
      }
    } catch (e) {
      print('Error loading notes from local storage: $e');
    }
  }

  Future<void> _saveToLocalStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final notesData = _notes.map((note) => note.toMap()).toList();
      await prefs.setString('local_notes', jsonEncode(notesData));
    } catch (e) {
      print('Error saving notes to local storage: $e');
    }
  }

  Future<void> _addSampleNotes() async {
    final sampleNotes = [
      Note(
        id: _uuid.v4(),
        title: 'Welcome to Course Companion!',
        content: 'This is your first note. You can create, edit, and organize notes for your courses here. Tap on this note to edit it or use the + button to create a new one.',
        course: 'Unassigned',
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      ),
      Note(
        id: _uuid.v4(),
        title: 'Getting Started Tips',
        content: '1. Create notes for each course\n2. Use the search and filter features\n3. Organize your notes by course\n4. Long press notes for more options',
        course: 'Unassigned',
        createdAt: DateTime.now().subtract(const Duration(hours: 1)),
      ),
    ];
    
    _notes.addAll(sampleNotes);
    await _saveToLocalStorage();
  }

  Future<void> addNote(Note note) async {
    try {
      _setLoading(true);
      _clearError();
      
      final noteWithId = note.copyWith(id: _uuid.v4());
      _notes.add(noteWithId);
      
      await _saveToLocalStorage();
      notifyListeners();
    } catch (e) {
      _setError('Failed to add note: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> updateNote(Note oldNote, Note updatedNote) async {
    try {
      _setLoading(true);
      _clearError();
      
      final index = _notes.indexWhere((n) => n.id == oldNote.id);
  if (index != -1) {
    _notes[index] = updatedNote;
        await _saveToLocalStorage();
    notifyListeners();
      }
    } catch (e) {
      _setError('Failed to update note: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> deleteNote(Note note) async {
    try {
      _setLoading(true);
      _clearError();
      
      _notes.removeWhere((n) => n.id == note.id);
      await _saveToLocalStorage();
      notifyListeners();
    } catch (e) {
      _setError('Failed to delete note: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> clearNotes() async {
    try {
      _setLoading(true);
      _clearError();
      
      _notes.clear();
      await _saveToLocalStorage();
      notifyListeners();
    } catch (e) {
      _setError('Failed to clear notes: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Public method to refresh notes (useful for future integration with cloud storage)
  Future<void> refreshNotes() async {
    try {
      _setLoading(true);
      _clearError();
      
      // For now, just reload from local storage
      // In the future, this could sync with cloud storage
      await _loadFromLocalStorage();
      
      notifyListeners();
    } catch (e) {
      _setError('Failed to refresh notes: $e');
    } finally {
      _setLoading(false);
    }
  }

  List<Note> getNotesByCourse(String course) {
    if (course.isEmpty || course == 'All') return _notes;
    return _notes.where((note) => note.course == course).toList();
  }

  List<Note> searchNotes(String query) {
    if (query.isEmpty) return _notes;
    return _notes.where((note) =>
        note.title.toLowerCase().contains(query.toLowerCase()) ||
        note.content.toLowerCase().contains(query.toLowerCase()) ||
        note.course.toLowerCase().contains(query.toLowerCase())).toList();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
  }
}
