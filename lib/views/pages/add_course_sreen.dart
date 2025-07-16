import 'package:flutter/material.dart';

void main() => runApp(MaterialApp(home: AddCoursePage()));

class AddCoursePage extends StatefulWidget {
  const AddCoursePage({super.key});

  @override
  _AddCoursePageState createState() => _AddCoursePageState();
}

class _AddCoursePageState extends State<AddCoursePage> {
  final TextEditingController courseNameController = TextEditingController();
  final TextEditingController courseCodeController = TextEditingController();
  final TextEditingController instructorController = TextEditingController();
  final TextEditingController scheduleController = TextEditingController();

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Add New Course'),
        actions: [
          TextButton(
            onPressed: () {
              // Handle Save action
            },
            child: Text('Save', style: TextStyle(color: Colors.blue)),
          ),
        ],
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0.5,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            buildLabeledTextField("Course Name *", courseNameController, "Introduction to Computer Science"),
            buildLabeledTextField("Course Code *", courseCodeController, "CS101"),
            buildLabeledTextField("Instructor", instructorController, "Prof. John Doe"),
            buildLabeledTextField("Schedule", scheduleController, "Mon, Wed, Fri 10:00 AM – 11:30 AM"),
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
