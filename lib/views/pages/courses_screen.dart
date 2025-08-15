import 'package:coursecompanion/services/supabase_service.dart';
import 'package:coursecompanion/views/pages/add_course_sreen.dart';
import 'package:coursecompanion/views/pages/course_detail.dart';
import 'package:coursecompanion/views/theme/theme_provider.dart';
import 'package:coursecompanion/views/widgets/empty_state.dart';
import 'package:coursecompanion/models/course_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:coursecompanion/providers/course_provider.dart';

class CoursesScreen extends StatefulWidget {
  const CoursesScreen({super.key});

  @override
  State<CoursesScreen> createState() => _CoursesScreenState();
}

class _CoursesScreenState extends State<CoursesScreen> {
  List<Map<String, dynamic>> courses = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCourses();
  }

  Color _parseColor(dynamic colorData) {
    try {
      if (colorData != null) {
        final colorStr = colorData.toString();
        // Handle different color formats
        if (colorStr.startsWith('#')) {
          // Hex color
          return Color(int.parse(colorStr.replaceFirst('#', '0xFF')));
        } else if (colorStr.startsWith('Color(')) {
          // Flutter Color object - fallback to blue
          return Colors.blue;
        } else {
          // Try to parse as integer
          return Color(int.parse(colorStr));
        }
      }
      return Colors.blue;
    } catch (e) {
      // If any parsing fails, use default blue
      return Colors.blue;
    }
  }

  Future<void> _loadCourses() async {
    setState(() => isLoading = true);
    try {
      // Load courses through the provider
      final provider = Provider.of<CourseProvider>(context, listen: false);
      await provider.loadCourses();
      
      // Update local state for backward compatibility
      setState(() {
        courses = provider.courses.map((course) => {
          'id': course.id,
          'title': course.title,
          'code': course.code,
          'instructor': course.instructor,
          'schedule': course.schedule,
          'colorIndex': course.colorIndex,
          'color': course.color,
        }).toList();
      });
    } catch (e) {
      debugPrint('Error fetching courses: $e');
      // You can show a snackbar or error widget here if needed
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
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
            icon: const Icon(Icons.refresh),
            onPressed: _loadCourses,
            tooltip: 'Refresh Courses',
          ),
          IconButton(
            icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode),
            onPressed: () => themeProvider.toggleTheme(),
          ),
        ],
      ),
      backgroundColor: theme.scaffoldBackgroundColor,
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : courses.isEmpty
              ? const EmptyState(
                  icon: Icons.menu_book,
                  message:
                      "You haven't added any courses yet.\nTap the + button to add your first course.",
                )
              : RefreshIndicator(
                  onRefresh: _loadCourses,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16.0),
                    itemCount: courses.length,
                    itemBuilder: (context, index) {
                      final course = courses[index];
                      // Use a default color if color field doesn't exist or can't be parsed
                      Color color;
                      try {
                        if (course['color'] != null) {
                          final colorStr = course['color'].toString();
                          // Handle different color formats
                          if (colorStr.startsWith('#')) {
                            // Hex color
                            color = Color(int.parse(colorStr.replaceFirst('#', '0xFF')));
                          } else if (colorStr.startsWith('Color(')) {
                            // Flutter Color object
                            color = Colors.blue; // Fallback to blue
                          } else {
                            // Try to parse as integer
                            color = Color(int.parse(colorStr));
                          }
                        } else {
                          color = Colors.blue;
                        }
                      } catch (e) {
                        // If any parsing fails, use default blue
                        color = Colors.blue;
                      }
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CourseDetailPage(
                              course: Course(
                                id: course['id'],
                                title: course['title'],
                                code: course['code'],
                                instructor: course['instructor'],
                                schedule: List<Map<String, String>>.from(course['schedule'] ?? []),
                                colorIndex: course['colorIndex'] ?? 0,
                                color: color,
                                attachments: [], // You can load attachments from local storage if you store them
                              ),
                            ),
                          ),
                        ).then((_) => _loadCourses());

                        },
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 16.0),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                color.withOpacity(isDark ? 0.3 : 0.2),
                                color.withOpacity(isDark ? 0.1 : 0.05),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: color.withOpacity(0.2),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: color,
                              child: Text(
                                course['code'][0],
                                style: const TextStyle(color: Colors.white),
                              ),
                            ),
                            title: Text(
                              course['title'],
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: theme.textTheme.bodyLarge?.color,
                              ),
                            ),
                            subtitle: Text(
                              '${course['code']} • ${course['instructor']}',
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
              ).then((_) => _loadCourses());
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
