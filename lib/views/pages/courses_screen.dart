import 'package:coursecompanion/providers/course_provider.dart';
import 'package:coursecompanion/views/pages/add_course_sreen.dart';
import 'package:coursecompanion/views/pages/course_detail.dart';
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
    final courseProvider = Provider.of<CourseProvider>(context);
    final courses = courseProvider.courses;

    return Scaffold(
      appBar: const CustomAppBar(title: 'Courses', showBackButton: true),
      body: courses.isEmpty
          ? const EmptyState(
              icon: Icons.menu_book,
              message:
                  "You haven't added any courses yet.\nTap the + button to add your first course.",
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: courses.length,
              itemBuilder: (context, index) {
                final course = courses[index];
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CourseDetailPage(course: course),
                      ),
                    );
                  },
                  child: Card(
                    color: course.color.withOpacity(0.1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    margin: const EdgeInsets.only(bottom: 16.0),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: course.color,
                        child: Text(
                          course.code[0],
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                      title: Text(course.title,
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text('${course.code} • ${course.instructor}'),
                      trailing: Icon(Icons.arrow_forward_ios, size: 16),
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 8.0),
        child: FloatingActionButton(
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AddCoursePage()),
            );
          },
          tooltip: 'Add Course',
          shape: const CircleBorder(),
          child: const Icon(Icons.add),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
    );
  }
}
