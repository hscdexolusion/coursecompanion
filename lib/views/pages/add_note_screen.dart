import 'package:coursecompanion/views/widgets/custom_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/note_model.dart';
import '../../providers/note_provider.dart';
import '../../providers/course_provider.dart';

class AddNoteScreen extends StatefulWidget {
  const AddNoteScreen({super.key});

  @override
  State<AddNoteScreen> createState() => _AddNoteScreenState();
}

class _AddNoteScreenState extends State<AddNoteScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  String? _selectedCourse;

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  void _saveNote() {
    if (_formKey.currentState!.validate()) {
      final newNote = Note(
        title: _titleController.text.trim(),
        content: _contentController.text.trim(),
        course: _selectedCourse ?? 'Unassigned',
        createdAt: DateTime.now(),
      );

      Provider.of<NoteProvider>(context, listen: false).addNote(newNote);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final courseProvider = Provider.of<CourseProvider>(context);
    final courses = courseProvider.courses;

    return Scaffold(
      appBar: CustomAppBar(title: 'Add Note', showBackButton: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Note Details',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              const Text('Note Title'),
              const SizedBox(height: 6),
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  hintText: 'Enter note title...',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                       //borderSide: BorderSide.none,
                       ),
                  contentPadding:
                      const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
                ),
                validator: (value) => value == null || value.isEmpty
                    ? 'Please enter note title'
                    : null,
              ),
              const SizedBox(height: 20),
              const Text('Course'),
              const SizedBox(height: 6),
              DropdownButtonFormField<String>(
                value: _selectedCourse,
                hint: Text(courses.isEmpty
                    ? "No courses available"
                    : "Select a course"),
                items: courses
                    .map((course) => DropdownMenuItem<String>(
                          value: course.title,
                          child: Text(course.title),
                        ))
                    .toList(),
                onChanged: courses.isEmpty
                    ? null
                    : (value) => setState(() => _selectedCourse = value),
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8)),
                  contentPadding:
                      const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
                ),
                // Make selection optional — no validator
              ),
              const SizedBox(height: 20),
              const Text('Note Content'),
              const SizedBox(height: 6),
              TextFormField(
                controller: _contentController,
                maxLines: 8,
                decoration: InputDecoration(
                  hintText: 'Write your notes here...',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8)),
                  contentPadding: const EdgeInsets.all(12),
                ),
                validator: (value) => value == null || value.isEmpty
                    ? 'Please enter note content'
                    : null,
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: _saveNote,
                icon: const Icon(Icons.save),
                label: const Text("Add Note"),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
