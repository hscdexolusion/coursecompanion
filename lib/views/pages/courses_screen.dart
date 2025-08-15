import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:coursecompanion/models/course_model.dart';
import 'package:coursecompanion/providers/course_provider.dart';
import 'package:coursecompanion/views/pages/add_course_sreen.dart';
import 'package:coursecompanion/views/pages/course_detail.dart';
import 'package:coursecompanion/views/widgets/custom_app_bar.dart';
import 'package:coursecompanion/views/theme/theme_provider.dart';

class CoursesScreen extends StatelessWidget {
  const CoursesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final courseProvider = Provider.of<CourseProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final courses = courseProvider.courses;

    return Scaffold(
      appBar: const CustomAppBar(title: 'Courses', showBackButton: false),
      body: courses.isEmpty
          ? const Center(child: Text('No courses added yet.'))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: courses.length,
              itemBuilder: (context, index) {
                final course = courses[index];
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => CourseDetailPage(course: course),
                      ),
                    );
                  },
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          course.color.withOpacity(0.8),
                          course.color.withOpacity(0.4),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: course.color.withOpacity(0.3),
                          blurRadius: 6,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(16),
                      title: Text(
                        course.title,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 4),
                          Text(course.code, style: const TextStyle(color: Colors.white70)),
                          if (course.schedule.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Text(
                                course.schedule
                                    .map((s) => "${s['day']} at ${s['time']}")
                                    .join(', '),
                                style: const TextStyle(color: Colors.white70, fontSize: 12),
                              ),
                            ),
                        ],
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.edit, color: Colors.white),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => AddCoursePage(course: course),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: Container(
        decoration: BoxDecoration(
          gradient: themeProvider.floatingActionButtonGradient,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: FloatingActionButton(
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.white,
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AddCoursePage()),
            );
          },
          tooltip: 'Add Course',
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}
