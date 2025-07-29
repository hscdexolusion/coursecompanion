import 'package:coursecompanion/views/widgets/custom_app_bar.dart';
import 'package:coursecompanion/views/theme/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../providers/course_provider.dart';
import '../../providers/deadline_provider.dart';
import '../../models/deadline_model.dart';
import 'package:uuid/uuid.dart';

class AddDeadlineScreen extends StatefulWidget {
  final Deadline? existingDeadline;

  const AddDeadlineScreen({super.key, this.existingDeadline});

  @override
  State<AddDeadlineScreen> createState() => _AddDeadlineScreenState();
}

class _AddDeadlineScreenState extends State<AddDeadlineScreen> {
  final _formKey = GlobalKey<FormState>();

  String? _title;
  String? _note;
  String? _selectedCourse;
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    if (widget.existingDeadline != null) {
      _title = widget.existingDeadline!.title;
      _note = widget.existingDeadline!.note;
      _selectedCourse = widget.existingDeadline!.course;
      _selectedDate = widget.existingDeadline!.dueDate;
    }
  }

  String get formattedDate {
    if (_selectedDate == null) return 'Select a deadline date';
    return DateFormat.yMMMMd().format(_selectedDate!);
  }

  Future<void> _pickDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final courseProvider = Provider.of<CourseProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final courses = courseProvider.courses;

    return Scaffold(
      appBar: CustomAppBar(
        title: widget.existingDeadline != null ? 'Edit Deadline' : 'Add Deadline',
        showBackButton: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Text(
                  'New Deadline',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),

              // Title
              const Text('Deadline Title'),
              const SizedBox(height: 6),
              TextFormField(
                initialValue: _title,
                decoration: InputDecoration(
                  hintText: 'Enter Deadline title...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding:
                      const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter deadline title';
                  }
                  return null;
                },
                onSaved: (value) => _title = value,
              ),
              const SizedBox(height: 20),

              // Course Dropdown
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
              ),
              const SizedBox(height: 20),

              // Note Content
              const Text('Note Content'),
              const SizedBox(height: 6),
              TextFormField(
                initialValue: _note,
                maxLines: 8,
                decoration: InputDecoration(
                  hintText: 'Write your notes here...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding: const EdgeInsets.all(12),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please fill out this field.';
                  }
                  return null;
                },
                onSaved: (value) => _note = value,
              ),
              const SizedBox(height: 20),

              // Due Date Picker
              const Text('Due Date'),
              const SizedBox(height: 6),
              InkWell(
                onTap: () => _pickDate(context),
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        formattedDate,
                        style: const TextStyle(fontSize: 16),
                      ),
                      const Icon(Icons.calendar_today),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 30),

              // Submit Button
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
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      if (_selectedDate == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Please select a due date')),
                        );
                        return;
                      }

                      if (_selectedDate!.isBefore(DateTime.now())) {
                        showDialog(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            title: const Text('Invalid Date'),
                            content: const Text('You cannot select a past date for a deadline.'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.of(ctx).pop(),
                                child: const Text('OK'),
                              ),
                            ],
                          ),
                        );
                        return;
                      }

                      _formKey.currentState!.save();
                      final provider = Provider.of<DeadlineProvider>(context, listen: false);

                      if (widget.existingDeadline != null) {
                        final updatedDeadline = widget.existingDeadline!.copyWith(
                          title: _title!,
                          note: _note!,
                          course: _selectedCourse ?? 'Unassigned',
                          dueDate: _selectedDate!,
                        );
                        provider.updateDeadline(widget.existingDeadline!.id,updatedDeadline);
                      } else {
                        final newDeadline = Deadline(
                          id: const Uuid().v4(),
                          title: _title!,
                          note: _note!,
                          course: _selectedCourse ?? 'Unassigned',
                          dueDate: _selectedDate!,
                        );
                        provider.addDeadline(newDeadline);
                      }

                      Navigator.pop(context);
                    }
                  },
                  icon: const Icon(Icons.save),
                  label: const Text("Save Deadline"),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    backgroundColor: Colors.transparent,
                    foregroundColor: Colors.white,
                    shadowColor: Colors.transparent,
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
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
