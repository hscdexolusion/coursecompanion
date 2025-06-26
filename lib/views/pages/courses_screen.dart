import 'package:flutter/material.dart';

class CoursesScreen extends StatelessWidget {
  const CoursesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Courses'),
        centerTitle: true,
      ),
      body: Center(
        child: Text('You have not added any courses yet. Tap the + button to add your first course'),
      ),
      
        
    );
  }
}