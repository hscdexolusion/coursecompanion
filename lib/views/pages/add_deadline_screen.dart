import 'package:coursecompanion/models/deadline_model.dart';
import 'package:coursecompanion/providers/course_provider.dart';
import 'package:coursecompanion/providers/deadline_provider.dart';
import 'package:coursecompanion/services/notification_service.dart';
import 'package:coursecompanion/views/widgets/custom_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';
import 'package:coursecompanion/services/supabase_service.dart';

class AddDeadlineScreen extends StatefulWidget {
  final Deadline? existingDeadline;

  const AddDeadlineScreen({Key? key, this.existingDeadline}) : super(key: key);

  @override
  State<AddDeadlineScreen> createState() => _AddDeadlineScreenState();
}

class _AddDeadlineScreenState extends State<AddDeadlineScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _title;
  String? _description;
  String? _selectedCourseId;
  String? _selectedCourseName;
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  String _priority = 'medium';

  @override
  void initState() {
    super.initState();
    if (widget.existingDeadline != null) {
      final existing = widget.existingDeadline!;
      _title = existing.title;
      _description = existing.description;
      _selectedCourseId = existing.courseId;
      _selectedCourseName = existing.courseName;
      _selectedDate = existing.dueDate;
      _selectedTime = TimeOfDay.fromDateTime(existing.dueDate);
      _priority = existing.priority;
    }
  }

  Future<void> _selectDate() async {
    final now = DateTime.now();
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? now,
      firstDate: now,
      lastDate: DateTime(2100),
    );
    if (pickedDate != null) setState(() => _selectedDate = pickedDate);
  }

  Future<void> _selectTime() async {
    final now = TimeOfDay.now();
    final pickedTime = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? now,
    );
    if (pickedTime != null) setState(() => _selectedTime = pickedTime);
  }

  DateTime _combine(DateTime date, TimeOfDay time) {
    return DateTime(date.year, date.month, date.day, time.hour, time.minute);
  }

  @override
  Widget build(BuildContext context) {
    final courses = Provider.of<CourseProvider>(context).courses;
    final deadlineProvider = Provider.of<DeadlineProvider>(context, listen: false);

    return Scaffold(
      appBar: const CustomAppBar(title: 'Add Deadline'),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Title
              TextFormField(
                initialValue: _title,
                decoration: const InputDecoration(labelText: 'Deadline Title'),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Please enter a title' : null,
                onSaved: (value) => _title = value,
              ),
              const SizedBox(height: 16),

              // Description
              TextFormField(
                initialValue: _description,
                decoration: const InputDecoration(labelText: 'Description'),
                onSaved: (value) => _description = value,
              ),
              const SizedBox(height: 16),

              // Course Dropdown
              DropdownButtonFormField<String>(
                value: _selectedCourseId,
                items: [
                  const DropdownMenuItem(
                    value: null,
                    child: Text('No Course'),
                  ),
                  ...courses.map(
                    (c) => DropdownMenuItem(
                      value: c.id,
                      child: Text(c.title),
                    ),
                  ),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedCourseId = value;
                    _selectedCourseName = value != null
                        ? courses.firstWhere((c) => c.id == value).title
                        : null;
                  });
                },
                decoration: const InputDecoration(labelText: 'Course'),
              ),
              const SizedBox(height: 16),

              // Date Picker
              ListTile(
                title: Text(
                  _selectedDate == null
                      ? 'Select Due Date'
                      : DateFormat('EEE, MMM d, yyyy').format(_selectedDate!),
                ),
                trailing: const Icon(Icons.calendar_today),
                onTap: _selectDate,
              ),
              const SizedBox(height: 16),

              // Time Picker
              ListTile(
                title: Text(
                  _selectedTime == null
                      ? 'Select Due Time'
                      : _selectedTime!.format(context),
                ),
                trailing: const Icon(Icons.access_time),
                onTap: _selectTime,
              ),
              const SizedBox(height: 32),

              ElevatedButton(
                onPressed: () async {
                  if (!_formKey.currentState!.validate()) return;
                  if (_selectedDate == null || _selectedTime == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Please select a due date and time')),
                    );
                    return;
                  }

                  _formKey.currentState!.save();
                  final dueDate = _combine(_selectedDate!, _selectedTime!);

                  try {
                    if (widget.existingDeadline != null) {
                      // Update existing deadline
                      final updated = widget.existingDeadline!.copyWith(
                        title: _title!,
                        description: _description ?? '',
                        courseId: _selectedCourseId ?? '',
                        courseName: _selectedCourseName ?? 'No Course',
                        dueDate: dueDate,
                      );
                      await deadlineProvider.updateDeadline(widget.existingDeadline!.id, updated);
                    } else {
                      // Add new deadline
                      final newDeadline = Deadline(
                        id: const Uuid().v4(),
                        title: _title!,
                        description: _description ?? '',
                        courseId: _selectedCourseId ?? '',
                        courseName: _selectedCourseName ?? 'No Course',
                        dueDate: dueDate,
                        priority: _priority,
                        createdAt: DateTime.now(),
                        updatedAt: DateTime.now(),
                      );
                      await deadlineProvider.addDeadline(newDeadline);
                    }

                    // Force reload to update DeadlinesScreen immediately
                    await deadlineProvider.loadDeadlines();

                    Navigator.pop(context);
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Failed to save deadline: $e')),
                    );
                  }
                },
                child: const Text('Save Deadline'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
