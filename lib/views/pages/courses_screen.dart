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
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: themeProvider.primaryGradient,
          ),
        ),
        foregroundColor: Colors.white,
        centerTitle: true,
        automaticallyImplyLeading: false,
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
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 16.0),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          course.color.withOpacity(isDark ? 0.3 : 0.2),
                          course.color.withOpacity(isDark ? 0.1 : 0.05),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: course.color.withOpacity(0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
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
        child: Container(
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
            shape: const CircleBorder(),
            child: const Icon(Icons.add),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
    );
  }
}
