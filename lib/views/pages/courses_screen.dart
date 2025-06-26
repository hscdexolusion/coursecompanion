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
      body: Center(
        child: Column
        (
          children: [
             Text('You have not added any courses yet. Tap the + button to add your first course', textAlign: TextAlign.center,),          ]
          ),
        
      ),
      floatingActionButton:   Padding(
        padding: const EdgeInsets.only(bottom: 8.0),
        child: FloatingActionButton(
                backgroundColor: Colors.blue[50],
                onPressed: () {
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