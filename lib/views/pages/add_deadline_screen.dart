import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AddDeadlineScreen extends StatefulWidget {
  const AddDeadlineScreen({super.key});

  @override
  State<AddDeadlineScreen> createState() => _AddDeadlineScreenState();
}

class _AddDeadlineScreenState extends State<AddDeadlineScreen> {
  final _formKey = GlobalKey<FormState>();

  String? _selectedCourse;
  final List<String> _courses = [];

  DateTime? _selectedDate;

  String get formattedDate {
    if (_selectedDate == null) return 'Select a deadline date';
    return DateFormat.yMMMMd().format(_selectedDate!);
  }

  Future<void> _pickDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
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
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Add Deadline'),
        leading: const BackButton(color: Colors.black),
        centerTitle: true,
        /* iconTheme: const IconThemeData(
         color: Colors.black 
          ),*/
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
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
              ),
              const SizedBox(height: 20),

              // Course Dropdown
              const Text('Course'),
              const SizedBox(height: 6),
              DropdownButtonFormField<String>(
                value: _selectedCourse,
                hint: const Text("Select a course"),
                items: _courses
                    .map((course) => DropdownMenuItem(
                          value: course,
                          child: Text(course),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedCourse = value;
                  });
                },
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding:
                      const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
                ),
                validator: (value) {
                  if (_courses.isEmpty) {
                    return 'No courses available. Please add courses first.';
                  }
                  if (value == null || value.isEmpty) {
                    return 'Please select a course';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Note Content
              const Text('Note Content'),
              const SizedBox(height: 6),
              TextFormField(
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
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    // Save logic here
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Deadline saved!')),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amberAccent,
                ),
                child: const Text(
                  'Save Note',
                  style: TextStyle(color: Colors.black),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
