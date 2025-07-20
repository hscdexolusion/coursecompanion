import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:coursecompanion/models/course_model.dart';
import 'package:coursecompanion/providers/course_provider.dart';
import 'package:coursecompanion/views/widgets/custom_app_bar.dart';

class AddCoursePage extends StatefulWidget {
  const AddCoursePage({super.key});

  @override
  _AddCoursePageState createState() => _AddCoursePageState();
}

class _AddCoursePageState extends State<AddCoursePage> {
  final TextEditingController courseNameController = TextEditingController();
  final TextEditingController courseCodeController = TextEditingController();
  final TextEditingController instructorController = TextEditingController();

  int selectedColorIndex = 0;

  final List<Color> colors = [
    Colors.blue,
    Colors.pinkAccent,
    Colors.green,
    Colors.orange,
    Colors.purple,
    Colors.cyan,
    Colors.deepOrange,
    Colors.teal,
  ];

  List<Map<String, dynamic>> schedules = [];

  final List<String> weekdays = [
    'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'
  ];

  void addSchedule() async {
    String? selectedDay;
    TimeOfDay? selectedTime;

    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("Add Schedule"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<String>(
              decoration: InputDecoration(labelText: "Select Day"),
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
                if (picked != null) {
                  selectedTime = picked;
                }
              },
              child: Text("Pick Time"),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              if (selectedDay != null && selectedTime != null) {
                setState(() {
                  schedules.add({
                    'day': selectedDay!,
                    'time': selectedTime!.format(context)
                  });
                });
                Navigator.pop(context);
              }
            },
            child: Text("Add"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancel"),
          ),
        ],
      ),
    );
  }

  String formatSchedules() {
    if (schedules.isEmpty) return "Unscheduled";
    return schedules.map((s) => "${s['day']} at ${s['time']}").join(', ');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: "Add New Course", showBackButton: true),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            buildLabeledTextField("Course Name *", courseNameController, "Introduction to Computer Science"),
            buildLabeledTextField("Course Code *", courseCodeController, "CS101"),
            buildLabeledTextField("Instructor", instructorController, "Prof. John Doe"),

            const SizedBox(height: 16),
            Text("Schedule", style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ...schedules.map((s) => Text("• ${s['day']} at ${s['time']}")),
                TextButton.icon(
                  onPressed: addSchedule,
                  icon: Icon(Icons.add),
                  label: Text("Add Meeting Day & Time"),
                )
              ],
            ),

            const SizedBox(height: 24),
            Text("Color", style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: List.generate(colors.length, (index) {
                return GestureDetector(
                  onTap: () => setState(() => selectedColorIndex = index),
                  child: CircleAvatar(
                    radius: 20,
                    backgroundColor: colors[index],
                    child: selectedColorIndex == index
                        ? Icon(Icons.check, color: Colors.white)
                        : null,
                  ),
                );
              }),
            ),

            const SizedBox(height: 30),
            ElevatedButton.icon(
              onPressed: () {
                if (courseNameController.text.isNotEmpty &&
                    courseCodeController.text.isNotEmpty) {
                  final newCourse = Course(
                    title: courseNameController.text,
                    code: courseCodeController.text,
                    instructor: instructorController.text,
                    schedule: formatSchedules(),
                    color: colors[selectedColorIndex],
                    colorIndex: selectedColorIndex,
                  );

                  Provider.of<CourseProvider>(context, listen: false).addCourse(newCourse);

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Course added!')),
                  );

                  Navigator.pop(context);
                }
              },
              icon: Icon(Icons.save),
              label: Text("Save Course"),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 14),
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget buildLabeledTextField(String label, TextEditingController controller, String hint) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        Text(label, style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: Colors.grey[100],
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }
}
