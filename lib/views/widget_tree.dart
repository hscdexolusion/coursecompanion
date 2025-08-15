import 'package:coursecompanion/views/pages/courses_screen.dart';
import 'package:coursecompanion/views/pages/deadlines_screen.dart';
import 'package:coursecompanion/views/pages/notes_screen.dart';
import 'package:coursecompanion/views/pages/reminders_screen.dart';
import 'package:coursecompanion/views/theme/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class WidgetTree extends StatefulWidget {
  const WidgetTree({super.key});

  @override
  State<WidgetTree> createState() => _WidgetTreeState();
}

class _WidgetTreeState extends State<WidgetTree> {
 int currentIndex = 0;

  final List<Widget> pages = [
     CoursesScreen(),
     DeadlinesScreen(),
     NotesScreen(),
     RemindersScreen(),
     //SettingsScreen() 
  ]; 

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    
    return Scaffold(
      body: pages[currentIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          gradient: themeProvider.primaryGradient,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: NavigationBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          onDestinationSelected: (value) {
            setState(() {
              currentIndex = value;
            });
          },
          selectedIndex: currentIndex,
          indicatorColor: Colors.white.withOpacity(0.2),
          destinations: [
            NavigationDestination(
              icon: Icon(Icons.menu_book, color: Colors.white),
              selectedIcon: Icon(Icons.menu_book, color: Colors.white),
              label: 'Courses'
            ),
            NavigationDestination(
              icon: Icon(Icons.calendar_today, color: Colors.white),
              selectedIcon: Icon(Icons.calendar_today, color: Colors.white),
              label: 'Deadlines'
            ),
            NavigationDestination(
              icon: Icon(Icons.note, color: Colors.white),
              selectedIcon: Icon(Icons.note, color: Colors.white),
              label: 'Notes'
            ),
            NavigationDestination(
              icon: Icon(Icons.notifications, color: Colors.white),
              selectedIcon: Icon(Icons.notifications, color: Colors.white),
              label: 'Reminders'
            ),
            //NavigationDestination(icon: Icon(Icons.settings), label: 'Settings'),
          ],
        ),
      ),
    );
  }
}
