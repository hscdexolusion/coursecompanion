import 'package:coursecompanion/views/pages/courses_screen.dart';
import 'package:coursecompanion/views/widgets/empty_state.dart';
import 'package:flutter/material.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Center(child: Text('Home Screen')),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start, // left-aligns the button
          children: [
            Center(
              child: EmptyState(
                icon: Icons.home,
                message: 'You are welcome to Course Companion!',
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const CoursesScreen()));
              },
              child: const Text('Get Started'),
            ),
          ],
        ),
      ),
    );
  }
}
