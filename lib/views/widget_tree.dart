import 'package:coursecompanion/views/pages/courses_screen.dart';
import 'package:coursecompanion/views/pages/deadlines_screen.dart';
import 'package:coursecompanion/views/pages/notes_screen.dart';
import 'package:coursecompanion/views/pages/settings_screen.dart';
import 'package:flutter/material.dart';

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
     SettingsScreen() 
  ]; 

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pages[currentIndex],
       bottomNavigationBar: NavigationBarTheme(
        data: NavigationBarThemeData(
          //   indicatorColor: Colors.blue,
        ),
         child: NavigationBar(
          onDestinationSelected: (value) {
            setState(() {
              currentIndex = value;
            });
          },
          selectedIndex: currentIndex,
          
          destinations: [
          NavigationDestination(icon: Icon(Icons.book), label: 'Courses'),
          NavigationDestination(icon: Icon(Icons.calendar_today), label: 'Deadlines'),
          NavigationDestination(icon: Icon(Icons.note), label: 'Notes'),
          NavigationDestination(icon: Icon(Icons.settings), label: 'Settings'),
               ]),
       ),  
    );
  }
}
