import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:coursecompanion/models/course_model.dart';
import 'package:coursecompanion/providers/course_provider.dart';
import 'package:coursecompanion/views/widgets/custom_app_bar.dart';
import 'package:coursecompanion/views/theme/theme_provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:coursecompanion/services/supabase_service.dart';

class AddCoursePage extends StatefulWidget {
  final Course? course;

  const AddCoursePage({super.key, this.course});

  @override
  _AddCoursePageState createState() => _AddCoursePageState();
}

class _AddCoursePageState extends State<AddCoursePage> {
  final TextEditingController courseNameController = TextEditingController();
  final TextEditingController courseCodeController = TextEditingController();
  final TextEditingController instructorController = TextEditingController();
  final List<Map<String, String>> _schedule = [];

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

  final List<String> weekdays = [
    'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'
  ];

  List<PlatformFile> selectedFiles = [];

  String _colorToHex(Color color) {
    return '#${color.value.toRadixString(16).padLeft(8, '0').substring(2)}';
  }

  @override
  void initState() {
    super.initState();
    // If editing an existing course, populate fields
    if (widget.course != null) {
      courseNameController.text = widget.course!.title;
      courseCodeController.text = widget.course!.code;
      instructorController.text = widget.course!.instructor;
      _schedule.addAll(widget.course!.schedule);
      selectedColorIndex = widget.course!.colorIndex;
      selectedFiles = widget.course!.attachments ?? [];
    }
  }

  Future<void> pickFiles() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        allowMultiple: true,
        type: FileType.any,
        withData: true,
      );

      if (result != null && result.files.isNotEmpty) {
        setState(() {
          selectedFiles = result.files;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("No files selected.")),
        );
      }
    } catch (e) {
      print("Error picking files: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to pick files. Please try again")),
      );
    }
  }

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
                if (picked != null) selectedTime = picked;
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
                  _schedule.add({
                    'day': selectedDay!,
                    'time': selectedTime!.format(context),
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

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Scaffold(
      appBar: CustomAppBar(title: widget.course == null ? "Add New Course" : "Edit Course", showBackButton: true),
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
                ..._schedule.map((s) => Text("• ${s['day']} at ${s['time']}")),
                TextButton.icon(
                  onPressed: addSchedule,
                  icon: Icon(Icons.add),
                  label: Text("Add Meeting Day & Time"),
                ),
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
                    child: selectedColorIndex == index ? Icon(Icons.check, color: Colors.white) : null,
                  ),
                );
              }),
            ),

            const SizedBox(height: 30),
            Text("Attachments", style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            ElevatedButton.icon(
              onPressed: pickFiles,
              icon: Icon(Icons.attach_file),
              label: Text("Pick Files"),
            ),
            const SizedBox(height: 12),
            if (selectedFiles.isEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text("No files selected."),
              )
            else
              ...selectedFiles.map((file) => ListTile(
                    leading: Icon(Icons.insert_drive_file),
                    title: Text(file.name),
                    subtitle: Text("${(file.size / 1024).toStringAsFixed(2)} KB"),
                  )),

            const SizedBox(height: 24),

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
                  if (courseNameController.text.isNotEmpty && courseCodeController.text.isNotEmpty) {
                    try {
                      // Show loading indicator
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Saving course...')),
                      );

                      if (widget.course == null) {
                        // Add new course to Supabase
                        final courseData = await SupabaseService.addCourse(
                          title: courseNameController.text,
                          code: courseCodeController.text,
                          instructor: instructorController.text,
                          schedule: _schedule,
                          colorIndex: selectedColorIndex,
                          color: _colorToHex(colors[selectedColorIndex]),
                        );

                        // Also add to provider for immediate UI update
                        final newCourse = Course(
                          id: courseData['id'],
                          title: courseNameController.text,
                          code: courseCodeController.text,
                          instructor: instructorController.text,
                          schedule: _schedule,
                          colorIndex: selectedColorIndex,
                          color: colors[selectedColorIndex],
                          attachments: selectedFiles,
                        );

                        final provider = Provider.of<CourseProvider>(context, listen: false);
                        provider.addCourse(newCourse);

                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Course added successfully!')),
                        );
                      } else {
                        // Update existing course
                        await SupabaseService.updateCourse(
                          widget.course!.id,
                          {
                            'title': courseNameController.text,
                            'code': courseCodeController.text,
                            'instructor': instructorController.text,
                            'schedule': _schedule,
                            'color_index': selectedColorIndex,
                            'color': _colorToHex(colors[selectedColorIndex]),
                          },
                        );

                        // Also update in provider for immediate UI update
                        final updatedCourse = Course(
                          id: widget.course!.id,
                          title: courseNameController.text,
                          code: courseCodeController.text,
                          instructor: instructorController.text,
                          schedule: _schedule,
                          colorIndex: selectedColorIndex,
                          color: colors[selectedColorIndex],
                          attachments: selectedFiles,
                        );

                        final provider = Provider.of<CourseProvider>(context, listen: false);
                        provider.updateCourse(updatedCourse);

                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Course updated successfully!')),
                        );
                      }

                      Navigator.pop(context);
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Error saving course: ${e.toString()}'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Please fill in all required fields'),
                        backgroundColor: Colors.orange,
                      ),
                    );
                  }
                },
                icon: Icon(Icons.save),
                label: Text("Save Course"),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 14),
                  backgroundColor: Colors.transparent,
                  foregroundColor: Colors.white,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
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
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
      ],
    );
  }
}
