import 'package:coursecompanion/views/pages/onboarding_screen.dart';
import 'package:coursecompanion/views/theme/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

void main() {
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
      overlays: [SystemUiOverlay.bottom]); // Show only the bottom navigation bar
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    Provider.of<ThemeProvider>(context);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'COURSE COMPANION',
      theme: ThemeData.light(),
      home: OnboardingScreen(),
    );
  }
}
