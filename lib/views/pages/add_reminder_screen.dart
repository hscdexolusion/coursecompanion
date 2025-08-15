import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'package:coursecompanion/models/reminder_model.dart';
import 'package:coursecompanion/providers/reminder_provider.dart';
import 'package:coursecompanion/providers/course_provider.dart';
import 'package:coursecompanion/services/reminder_service.dart';
import 'package:coursecompanion/views/widgets/custom_app_bar.dart';
import 'package:coursecompanion/views/theme/theme_provider.dart';
import 'package:coursecompanion/services/in_app_notification_service.dart';
import 'package:uuid/uuid.dart';

class AddReminderScreen extends StatefulWidget {
  final Reminder? reminder;
  final String? courseId;
  final String? courseName;

  const AddReminderScreen({
    super.key,
    this.reminder,
    this.courseId,
    this.courseName,
  });

  @override
  State<AddReminderScreen> createState() => _AddReminderScreenState();
}

class _AddReminderScreenState extends State<AddReminderScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();
  ReminderType _selectedType = ReminderType.general;
  ReminderRepeat _selectedRepeat = ReminderRepeat.once;
  String? _selectedCourseId;
  String? _selectedCourseName;
  
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.reminder != null) {
      _titleController.text = widget.reminder!.title;
      _descriptionController.text = widget.reminder!.description;
      _selectedDate = widget.reminder!.scheduledTime;
      _selectedTime = TimeOfDay.fromDateTime(widget.reminder!.scheduledTime);
      _selectedType = widget.reminder!.type;
      _selectedRepeat = widget.reminder!.repeat;
      _selectedCourseId = widget.reminder!.courseId;
      _selectedCourseName = widget.reminder!.courseName;
    } else if (widget.courseId != null && widget.courseName != null) {
      _selectedCourseId = widget.courseId;
      _selectedCourseName = widget.courseName;
      _selectedType = ReminderType.classReminder;
    }
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  Future<void> _saveReminder() async {
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a title for the reminder'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final scheduledTime = DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        _selectedTime.hour,
        _selectedTime.minute,
      );

      if (widget.reminder != null) {
        // Update existing reminder
        final updatedReminder = widget.reminder!.copyWith(
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim(),
          scheduledTime: scheduledTime,
          type: _selectedType,
          repeat: _selectedRepeat,
          courseId: _selectedCourseId,
          courseName: _selectedCourseName,
        );

        await ReminderService().updateReminder(updatedReminder);
        
        final provider = Provider.of<ReminderProvider>(context, listen: false);
        provider.updateReminder(updatedReminder);

        if (kIsWeb) {
          InAppNotificationService.showSuccessNotification(
            context: context,
            title: 'Reminder Updated!',
            message: 'Your reminder has been updated successfully.',
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Reminder updated successfully!')),
          );
        }
      } else {
        // Create new reminder
        final reminderId = await ReminderService().scheduleReminder(
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim(),
          scheduledTime: scheduledTime,
          courseId: _selectedCourseId,
          courseName: _selectedCourseName,
          type: _selectedType,
          repeat: _selectedRepeat,
        );

        final newReminder = Reminder(
          id: reminderId,
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim(),
          scheduledTime: scheduledTime,
          courseId: _selectedCourseId,
          courseName: _selectedCourseName,
          type: _selectedType,
          repeat: _selectedRepeat,
          createdAt: DateTime.now(),
        );

        final provider = Provider.of<ReminderProvider>(context, listen: false);
        provider.addReminder(newReminder);

        if (kIsWeb) {
          InAppNotificationService.showSuccessNotification(
            context: context,
            title: 'Reminder Created!',
            message: 'Your reminder has been created successfully.',
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Reminder created successfully!')),
          );
        }
      }

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error saving reminder: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final courseProvider = Provider.of<CourseProvider>(context);
    final courses = courseProvider.courses;

    return Scaffold(
      appBar: CustomAppBar(
        title: widget.reminder == null ? 'Add Reminder' : 'Edit Reminder',
        showBackButton: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            // Title
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Title *',
                hintText: 'Enter reminder title',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            // Description
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description',
                hintText: 'Enter reminder description',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 24),

            // Date and Time
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _selectDate,
                    icon: const Icon(Icons.calendar_today),
                    label: Text(
                      'Date: ${_selectedDate.toString().split(' ')[0]}',
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _selectTime,
                    icon: const Icon(Icons.access_time),
                    label: Text(
                      'Time: ${_selectedTime.format(context)}',
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Reminder Type
            Text('Reminder Type', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: ReminderType.values.map((type) {
                return ChoiceChip(
                  label: Text(type.toString().split('.').last.toUpperCase()),
                  selected: _selectedType == type,
                  onSelected: (selected) {
                    setState(() {
                      _selectedType = type;
                    });
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 24),

            // Repeat
            Text('Repeat', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: ReminderRepeat.values.map((repeat) {
                return ChoiceChip(
                  label: Text(repeat.toString().split('.').last.toUpperCase()),
                  selected: _selectedRepeat == repeat,
                  onSelected: (selected) {
                    setState(() {
                      _selectedRepeat = repeat;
                    });
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 24),

            // Course Selection
            if (courses.isNotEmpty) ...[
              Text('Course (Optional)', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _selectedCourseId,
                decoration: const InputDecoration(
                  labelText: 'Select Course',
                  border: OutlineInputBorder(),
                ),
                items: [
                  const DropdownMenuItem<String>(
                    value: null,
                    child: Text('No Course'),
                  ),
                  ...courses.map((course) => DropdownMenuItem<String>(
                    value: course.id,
                    child: Text(course.title),
                  )),
                ],
                onChanged: (courseId) {
                  setState(() {
                    _selectedCourseId = courseId;
                    _selectedCourseName = courseId != null
                        ? courses.firstWhere((c) => c.id == courseId).title
                        : null;
                  });
                },
              ),
              const SizedBox(height: 24),
            ],

            // Save Button
            Container(
              width: double.infinity,
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
              child: ElevatedButton(
                onPressed: _isLoading ? null : _saveReminder,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  foregroundColor: Colors.white,
                  shadowColor: Colors.transparent,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(
                        widget.reminder == null ? 'Create Reminder' : 'Update Reminder',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
} 