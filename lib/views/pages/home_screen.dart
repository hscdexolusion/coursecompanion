import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(child: Text('Home Screen')),
      ),
      body: Center(
        child: Text('Welcome to our Home Screen!'),
        
        
      ),
    );
  }
}