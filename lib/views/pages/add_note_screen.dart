import 'package:coursecompanion/models/note_model.dart';
import 'package:coursecompanion/providers/note_provider.dart';
import 'package:coursecompanion/providers/course_provider.dart';
import 'package:coursecompanion/views/widgets/custom_app_bar.dart';
import 'package:coursecompanion/views/theme/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AddNoteScreen extends StatefulWidget {
  final Note? noteToEdit;
  final String? course;

  const AddNoteScreen({super.key, this.noteToEdit, this.course});

  @override
  State<AddNoteScreen> createState() => _AddNoteScreenState();
}

class _AddNoteScreenState extends State<AddNoteScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  String? _selectedCourse;

  @override
  void initState() {
    super.initState();

    // Populate form if editing
    if (widget.noteToEdit != null) {
      _titleController.text = widget.noteToEdit!.title;
      _contentController.text = widget.noteToEdit!.content;
      _selectedCourse = widget.noteToEdit!.course;
    } else if (widget.course != null) {
      _selectedCourse = widget.course;
    } else {
      _selectedCourse = 'Unassigned';
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  void _saveNote() {
    if (_formKey.currentState!.validate()) {
      final noteProvider = Provider.of<NoteProvider>(context, listen: false);

      final newNote = Note(
        id: widget.noteToEdit?.id ?? '', // Will be set by provider if new
        title: _titleController.text.trim(),
        content: _contentController.text.trim(),
        course: _selectedCourse ?? 'Unassigned',
        createdAt: widget.noteToEdit?.createdAt ?? DateTime.now(),
      );

      if (widget.noteToEdit == null) {
        noteProvider.addNote(newNote);
      } else {
        noteProvider.updateNote(widget.noteToEdit!, newNote);
      }

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final courseProvider = Provider.of<CourseProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final courses = courseProvider.courses;

    return Scaffold(
      appBar: CustomAppBar(
        title: widget.noteToEdit == null ? 'Add Note' : 'Edit Note',
        showBackButton: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Note Title'),
              const SizedBox(height: 6),
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  hintText: 'Enter note title...',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
                ),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Please enter note title' : null,
              ),
              const SizedBox(height: 20),

              const Text('Course'),
              const SizedBox(height: 6),
              DropdownButtonFormField<String>(
                value: _selectedCourse,
                hint: Text(courses.isEmpty ? "No courses available" : "Select a course"),
                items: [
                  const DropdownMenuItem<String>(
                    value: 'Unassigned',
                    child: Text('Unassigned'),
                  ),
                  ...courses.map((course) {
                    return DropdownMenuItem<String>(
                      value: course.title,
                      child: Text(course.title),
                    );
                  }).toList(),
                ],
                onChanged: (value) => setState(() => _selectedCourse = value),
                decoration: InputDecoration(
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
                ),
              ),
              const SizedBox(height: 20),

              const Text('Note Content'),
              const SizedBox(height: 6),
              TextFormField(
                controller: _contentController,
                maxLines: 8,
                decoration: InputDecoration(
                  hintText: 'Write your notes here...',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  contentPadding: const EdgeInsets.all(12),
                ),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Please enter note content' : null,
              ),
              const SizedBox(height: 20),

              // Gradient Save/Update Button
              Container(
                decoration: BoxDecoration(
                  gradient: themeProvider.primaryGradient,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ElevatedButton.icon(
                  onPressed: _saveNote,
                  icon: const Icon(Icons.save),
                  label: Text(widget.noteToEdit == null ? "Add Note" : "Update Note"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    foregroundColor: Colors.white,
                    shadowColor: Colors.transparent,
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
