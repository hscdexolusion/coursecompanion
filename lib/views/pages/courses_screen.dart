import 'package:coursecompanion/views/pages/add_course_sreen.dart';
import 'package:coursecompanion/views/theme/theme_provider.dart';
import 'package:coursecompanion/views/widgets/custom_app_bar.dart';
import 'package:coursecompanion/views/widgets/empty_state.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';



class CoursesScreen extends StatelessWidget {
  const CoursesScreen({super.key});

  

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Scaffold(
      appBar:CustomAppBar(title: 'Courses'),
      body: const EmptyState(
        icon: Icons.menu_book,
        message: "You haven't added any courses yet.\nTap the + button to add your first course.",
      ),
      floatingActionButton:   Padding(
        padding: const EdgeInsets.only(bottom: 8.0),
        child: FloatingActionButton(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
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