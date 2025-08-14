import 'package:coursecompanion/models/deadline_model.dart';
import 'package:coursecompanion/providers/course_provider.dart';
import 'package:coursecompanion/providers/deadline_provider.dart';
import 'package:coursecompanion/services/notification_service.dart';
import 'package:coursecompanion/views/widgets/custom_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';

class AddDeadlineScreen extends StatefulWidget {
  final Deadline? existingDeadline;

  const AddDeadlineScreen({Key? key, this.existingDeadline}) : super(key: key);

  @override
  State<AddDeadlineScreen> createState() => _AddDeadlineScreenState();
}

class _AddDeadlineScreenState extends State<AddDeadlineScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _title;
  String? _note;
  String? _selectedCourse;
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;

  @override
  void initState() {
    super.initState();
    if (widget.existingDeadline != null) {
      final existing = widget.existingDeadline!;
      _title = existing.title;
      _note = existing.note;
      _selectedCourse = existing.course;
      _selectedDate = existing.dueDate;
      _selectedTime = TimeOfDay.fromDateTime(existing.dueDate);
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
    if (pickedDate != null) {
      setState(() => _selectedDate = pickedDate);
    }
  }

  Future<void> _selectTime() async {
    final now = TimeOfDay.now();
    final pickedTime = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? now,
    );
    if (pickedTime != null) {
      setState(() => _selectedTime = pickedTime);
    }
  }

  DateTime _combine(DateTime date, TimeOfDay time) {
    return DateTime(date.year, date.month, date.day, time.hour, time.minute);
  }

  Future<void> _promptBatteryOptimization() async {
    // Optional: Ask Android users to disable battery optimization for reliability
    if (Theme.of(context).platform == TargetPlatform.android) {
      // Implementation for prompting battery optimization disable
    }
  }

  @override
  Widget build(BuildContext context) {
    final courses = Provider.of<CourseProvider>(context).courses;

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

              // Note
              TextFormField(
                initialValue: _note,
                decoration: const InputDecoration(labelText: 'Note'),
                onSaved: (value) => _note = value,
              ),
              const SizedBox(height: 16),

              // Course Dropdown
              DropdownButtonFormField<String>(
                value: _selectedCourse,
                items: [
                  const DropdownMenuItem(
                    value: 'Unassigned',
                    child: Text('Unassigned'),
                  ),
                  ...courses.map(
                    (c) => DropdownMenuItem(
                      value: c.title,
                      child: Text(c.title),
                    ),
                  ),
                ],
                onChanged: (value) => setState(() => _selectedCourse = value),
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

                  final now = DateTime.now();
                  final dueDate = _combine(_selectedDate!, _selectedTime!);

                  const minLead = Duration(seconds: 15);
                  if (!dueDate.isAfter(now.add(minLead))) {
                    showDialog(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text('Invalid Date & Time'),
                        content: const Text(
                          'Please pick a time at least a few seconds in the future.',
                        ),
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
                  final provider =
                      Provider.of<DeadlineProvider>(context, listen: false);

                  // Prevent duplicate deadlines at the same minute
                  final isDuplicate = provider.allDeadlines.any((d) {
                    if (d.id == widget.existingDeadline?.id) return false;
                    final existing = d.dueDate;
                    return existing.year == dueDate.year &&
                        existing.month == dueDate.month &&
                        existing.day == dueDate.day &&
                        existing.hour == dueDate.hour &&
                        existing.minute == dueDate.minute;
                  });

                  if (isDuplicate) {
                    showDialog(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text('Duplicate Deadline'),
                        content: const Text(
                          'A deadline already exists at this date and time.',
                        ),
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

                  // Request permissions
                  final hasPermission =
                      await NotificationService.requestNotificationPermissions();
                  if (!hasPermission) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text(
                            'Notification permissions are required for reminders.'),
                        action: SnackBarAction(
                          label: 'Settings',
                          onPressed: () => openAppSettings(),
                        ),
                      ),
                    );
                    return;
                  }

                  await _promptBatteryOptimization();
                  await NotificationService.showTestNotification();

                  // Save deadline and schedule notifications
                  late int baseId;
                  final String deadlineTitle = _title ?? '';

                  if (widget.existingDeadline != null) {
                    // Update existing
                    final updated = widget.existingDeadline!.copyWith(
                      title: _title!,
                      note: _note!,
                      course: _selectedCourse ?? 'Unassigned',
                      dueDate: dueDate,
                    );
                    provider.updateDeadline(widget.existingDeadline!.id, updated);

                    baseId = widget.existingDeadline!.id.hashCode;
                    await NotificationService.cancelDeadlineNotifications(baseId);

                    await NotificationService.scheduleDeadlineNotifications(
                      baseId: baseId,
                      title: 'Deadline approaching!',
                      body: 'Your deadline "$deadlineTitle" is due soon.',
                      dueDate: dueDate,
                    );

                    print('Updated deadline scheduled at $dueDate (now: $now)');
                  } else {
                    // Create new
                    final newDeadline = Deadline(
                      id: const Uuid().v4(),
                      title: _title!,
                      note: _note!,
                      course: _selectedCourse ?? 'Unassigned',
                      dueDate: dueDate,
                    );
                    provider.addDeadline(newDeadline);

                    baseId = newDeadline.id.hashCode;

                    await NotificationService.scheduleDeadlineNotifications(
                      baseId: baseId,
                      title: 'Deadline approaching!',
                      body: 'Your deadline "$deadlineTitle" is due soon.',
                      dueDate: dueDate,
                    );

                    print('New deadline scheduled at $dueDate (now: $now)');
                  }

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Deadline saved successfully')),
                  );
                  Navigator.pop(context);
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
