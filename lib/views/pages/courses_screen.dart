import 'package:coursecompanion/providers/course_provider.dart';
import 'package:coursecompanion/views/pages/add_course_sreen.dart';
import 'package:coursecompanion/views/pages/course_detail.dart';
import 'package:coursecompanion/views/theme/theme_provider.dart';
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
    final isDark = themeProvider.isDarkMode;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue, // Always blue
        foregroundColor: Colors.white,
        centerTitle: true,
        title: const Text('Courses'),
        actions: [
          IconButton(
            icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode),
            onPressed: () => themeProvider.toggleTheme(),
          ),
        ],
      ),
      backgroundColor: theme.scaffoldBackgroundColor,
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
                    color: isDark
                        ? course.color.withOpacity(0.2)
                        : course.color.withOpacity(0.1),
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
                      title: Text(
                        course.title,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: theme.textTheme.bodyLarge?.color,
                        ),
                      ),
                      subtitle: Text(
                        '${course.code} • ${course.instructor}',
                        style: TextStyle(
                          color: theme.textTheme.bodyMedium?.color,
                        ),
                      ),
                      trailing: Icon(Icons.arrow_forward_ios,
                          size: 16, color: theme.iconTheme.color),
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
