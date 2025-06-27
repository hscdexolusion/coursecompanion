import 'package:coursecompanion/views/pages/add_course_sreen.dart';
import 'package:coursecompanion/views/widgets/empty_state.dart';
import 'package:flutter/material.dart';

class CoursesScreen extends StatelessWidget {
  const CoursesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Courses'),
        centerTitle: true,
        backgroundColor: Colors.blue[50],
      ),
      body: const EmptyState(
        icon: Icons.menu_book,
        message: "You haven't added any courses yet.\nTap the + button to add your first course.",
      ),
      floatingActionButton:   Padding(
        padding: const EdgeInsets.only(bottom: 8.0),
        child: FloatingActionButton(
                backgroundColor: Colors.blue[50],
                onPressed: () {
                   Navigator.push(
            context,
            MaterialPageRoute(builder: (_) =>  AddCoursePage()),
          );
               },
               tooltip: 'Increment',
               shape: const CircleBorder(),
               child: Icon(Icons.add),
               ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
      
        
    );
  }
}