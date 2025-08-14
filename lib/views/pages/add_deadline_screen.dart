
import 'dart:io';
import 'package:coursecompanion/views/widgets/custom_app_bar.dart';
import 'package:coursecompanion/views/theme/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../providers/course_provider.dart';
import '../../providers/deadline_provider.dart';
import '../../models/deadline_model.dart';
import 'package:uuid/uuid.dart';
import '../../services/notification_service.dart';
import 'package:permission_handler/permission_handler.dart';

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
  TimeOfDay? _selectedTime;

  @override
  void initState() {
    super.initState();
    // Initialize notifications (commented out as it's in main.dart)
    // NotificationService.initialize();
    if (widget.existingDeadline != null) {
      _title = widget.existingDeadline!.title;
      _note = widget.existingDeadline!.note;
      _selectedCourse = widget.existingDeadline!.course;
      _selectedDate = widget.existingDeadline!.dueDate;
      _selectedTime = TimeOfDay.fromDateTime(widget.existingDeadline!.dueDate);
    }
  }

  String get formattedDateTime {
    if (_selectedDate == null) return 'Select date & time';
    final dateStr = DateFormat.yMMMMd().format(_selectedDate!);
    final timeStr = _selectedTime != null
        ? _selectedTime!.format(context)
        : 'Select time';
    return '$dateStr • $timeStr';
  }

  Future<void> _pickDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _pickTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
    );
    if (picked != null) setState(() => _selectedTime = picked);
  }

  Future<void> _promptBatteryOptimization() async {
    if (Platform.isAndroid) {
      final status = await Permission.ignoreBatteryOptimizations.status;
      if (!status.isGranted) {
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Allow Background Notifications'),
            content: const Text(
                'To ensure deadline reminders appear reliably, please allow the app to run in the background.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () async {
                  await Permission.ignoreBatteryOptimizations.request();
                  Navigator.of(ctx).pop();
                },
                child: const Text('Allow'),
              ),
            ],
          ),
        );
      }
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
              const Text('Deadline Title'),
              const SizedBox(height: 6),
              TextFormField(
                initialValue: _title,
                decoration: InputDecoration(
                  hintText: 'Enter Deadline title...',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
                ),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Please enter deadline title' : null,
                onSaved: (value) => _title = value,
              ),
              const SizedBox(height: 20),
              const Text('Course'),
              const SizedBox(height: 6),
              DropdownButtonFormField<String>(
                value: _selectedCourse,
                hint: Text(courses.isEmpty ? "No courses available" : "Select a course"),
                items: courses
                    .map((course) => DropdownMenuItem<String>(
                          value: course.title,
                          child: Text(course.title),
                        ))
                    .toList(),
                onChanged: courses.isEmpty ? null : (value) => setState(() => _selectedCourse = value),
                decoration: InputDecoration(
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
                ),
              ),
              const SizedBox(height: 20),
              const Text('Note Content'),
              const SizedBox(height: 6),
              TextFormField(
                initialValue: _note,
                maxLines: 8,
                decoration: InputDecoration(
                  hintText: 'Write your notes here...',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  contentPadding: const EdgeInsets.all(12),
                ),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Please fill out this field.' : null,
                onSaved: (value) => _note = value,
              ),
              const SizedBox(height: 20),
              const Text('Due Date & Time'),
              const SizedBox(height: 6),
              InkWell(
                onTap: () async {
                  await _pickDate(context);
                  if (_selectedDate != null) await _pickTime(context);
                },
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        formattedDateTime,
                        style: const TextStyle(fontSize: 16),
                      ),
                      const Icon(Icons.calendar_today),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 30),
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
                  onPressed: () async {
                    if (!_formKey.currentState!.validate()) return;
                    if (_selectedDate == null || _selectedTime == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Please select a due date and time')),
                      );
                      return;
                    }

                    final dueDate = DateTime(
                      _selectedDate!.year,
                      _selectedDate!.month,
                      _selectedDate!.day,
                      _selectedTime!.hour,
                      _selectedTime!.minute,
                    );

                    if (dueDate.isBefore(DateTime.now())) {
                      showDialog(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: const Text('Invalid Date & Time'),
                          content: const Text('You cannot select a past date/time for a deadline.'),
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
                          content: const Text('A deadline already exists at this date and time.'),
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

                    // Check and request notification permissions
                    final hasPermission = await NotificationService.requestNotificationPermissions();
                    print('AddDeadlineScreen: Notification permission granted: $hasPermission');
                    if (!hasPermission) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text('Notification permissions are required for reminders.'),
                          action: SnackBarAction(
                            label: 'Settings',
                            onPressed: () => openAppSettings(),
                          ),
                        ),
                      );
                      return;
                    }

                    // Prompt for battery optimization (Android only)
                    await _promptBatteryOptimization();

                    // Show test notification
                    await NotificationService.showTestNotification();

                    int notifId;
                    if (widget.existingDeadline != null) {
                      final updatedDeadline = widget.existingDeadline!.copyWith(
                        title: _title!,
                        note: _note!,
                        course: _selectedCourse ?? 'Unassigned',
                        dueDate: dueDate,
                      );
                      provider.updateDeadline(widget.existingDeadline!.id, updatedDeadline);

                      // Cancel old notifications
                      notifId = widget.existingDeadline!.id.hashCode;
                      await NotificationService.cancelDeadlineNotifications(notifId);

                      // Schedule new notifications
                      await NotificationService.scheduleDeadlineNotifications(
                        baseId: updatedDeadline.id.hashCode,
                        title: updatedDeadline.title,
                        body: 'Course: ${updatedDeadline.course} - ${updatedDeadline.note ?? ''}',
                        dueDate: updatedDeadline.dueDate,
                      );
                    } else {
                      final newDeadline = Deadline(
                        id: const Uuid().v4(),
                        title: _title!,
                        note: _note!,
                        course: _selectedCourse ?? 'Unassigned',
                        dueDate: dueDate,
                      );
                      provider.addDeadline(newDeadline);

                      // Schedule notifications
                      notifId = newDeadline.id.hashCode;
                      await NotificationService.scheduleDeadlineNotifications(
                        baseId: notifId,
                        title: newDeadline.title,
                        body: 'Course: ${newDeadline.course} - ${newDeadline.note ?? ''}',
                        dueDate: newDeadline.dueDate,
                      );
                    }

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Deadline saved successfully')),
                    );
                    Navigator.pop(context);
                  },
                  icon: const Icon(Icons.save),
                  label: const Text("Save Deadline"), // Required for ElevatedButton.icon
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