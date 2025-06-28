import 'package:coursecompanion/views/widgets/empty_state.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(child: Text('Home Screen')),
      ),
      body: Container(
        child: Center(
          child: EmptyState(icon: Icons.home, message: 'You are welcome to Course Companion!'),
        ),
      ),
    );
  }
}