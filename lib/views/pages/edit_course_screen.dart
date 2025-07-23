import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/course_model.dart';
import '../../providers/course_provider.dart';
import '../widgets/custom_app_bar.dart';

class EditCourseScreen extends StatefulWidget {
  final Course course;

  const EditCourseScreen({super.key, required this.course});

  @override
  State<EditCourseScreen> createState() => _EditCourseScreenState();
}

class _EditCourseScreenState extends State<EditCourseScreen> {
  final _formKey = GlobalKey<FormState>();
  late String _title;
  late String _code;
  late String _instructor;

  List<Map<String, String>> _schedules = [];
  final List<String> weekdays = [
    'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'
  ];

  @override
  void initState() {
    super.initState();
    _title = widget.course.title;
    _code = widget.course.code;
    _instructor = widget.course.instructor;

    // Parse existing schedule into a list of maps
    if (widget.course.schedule.isNotEmpty) {
      _schedules = widget.course.schedule.map<Map<String, String>>((item) {
        return {
          'day': item['day']!,
          'time': item['time']!,
        };
      }).toList();
    }
  }

  void _addSchedule() async {
    String? selectedDay;
    TimeOfDay? selectedTime;

    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Add Schedule"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(labelText: "Select Day"),
              items: weekdays.map((day) {
                return DropdownMenuItem(
                  value: day,
                  child: Text(day),
                );
              }).toList(),
              onChanged: (val) => selectedDay = val,
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () async {
                final picked = await showTimePicker(
                  context: context,
                  initialTime: TimeOfDay.now(),
                );
                if (picked != null) selectedTime = picked;
              },
              child: const Text("Pick Time"),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              if (selectedDay != null && selectedTime != null) {
                setState(() {
                  _schedules.add({
                    'day': selectedDay!,
                    'time': selectedTime!.format(context)
                  });
                });
                Navigator.pop(context);
              }
            },
            child: const Text("Add"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
        ],
      ),
    );
  }

  void _saveChanges() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final updatedCourse = Course(
        id: widget.course.id,
        title: _title,
        code: _code,
        instructor: _instructor,
        schedule: _schedules,
        attachments: widget.course.attachments,
        colorIndex: widget.course.colorIndex,
        color: widget.course.color,
      );

      Provider.of<CourseProvider>(context, listen: false).updateCourse(updatedCourse);

      Navigator.pop(context); // Return to course detail screen
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: 'Edit Course', showBackButton: true),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Title
              TextFormField(
                initialValue: _title,
                decoration: const InputDecoration(labelText: 'Course Title'),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Enter course title' : null,
                onSaved: (value) => _title = value!,
              ),
              const SizedBox(height: 16),

              // Code
              TextFormField(
                initialValue: _code,
                decoration: const InputDecoration(labelText: 'Course Code'),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Enter course code' : null,
                onSaved: (value) => _code = value!,
              ),
              const SizedBox(height: 16),

              // Instructor
              TextFormField(
                initialValue: _instructor,
                decoration: const InputDecoration(labelText: 'Instructor Name'),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Enter instructor name' : null,
                onSaved: (value) => _instructor = value!,
              ),
              const SizedBox(height: 24),

              // Schedule Section
              Text("Schedule", style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ..._schedules.map((s) => Text("• ${s['day']} at ${s['time']}")),
                  TextButton.icon(
                    onPressed: _addSchedule,
                    icon: Icon(Icons.add),
                    label: Text("Add Meeting Day & Time"),
                  )
                ],
              ),
              const SizedBox(height: 30),

              // Save Button
              ElevatedButton.icon(
                onPressed: _saveChanges,
                icon: const Icon(Icons.save),
                label: const Text('Save Changes'),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
