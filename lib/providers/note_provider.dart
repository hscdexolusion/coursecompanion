import 'package:flutter/material.dart';
import 'package:coursecompanion/models/note_model.dart';




class NoteProvider with ChangeNotifier {

void updateNote(Note oldNote, Note updatedNote) {
  final index = _notes.indexOf(oldNote);
  if (index != -1) {
    _notes[index] = updatedNote;
    notifyListeners();
  }
}

  final List<Note> _notes = [];

  List<Note> get notes => _notes;

  void addNote(Note note) {
    _notes.add(note);
    notifyListeners();
  }

  void deleteNote(Note note) {
    _notes.remove(note);
    notifyListeners();
  }

  void clearNotes() {
    _notes.clear();
    notifyListeners();
  }
}
