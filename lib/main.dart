import 'package:coursecompanion/views/pages/onboarding_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:coursecompanion/views/theme/theme_provider.dart';
import 'package:coursecompanion/providers/course_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:coursecompanion/providers/note_provider.dart';
import 'package:coursecompanion/providers/deadline_provider.dart';
import 'services/notification_service.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'COURSE COMPANION',
      theme: themeProvider.lightTheme,
      darkTheme: themeProvider.darkTheme,
      themeMode: themeProvider.themeMode,
      home: const OnboardingScreen(),
    );
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  


  // Initialize timezone
  tz.initializeTimeZones();
  tz.setLocalLocation(tz.getLocation('Africa/Accra')); // adjust as needed

  // Initialize notifications & request permissions
  await NotificationService.initialize();

  await NotificationService.requestNotificationPermissions();

  // Lock system UI mode
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
      overlays: [SystemUiOverlay.bottom]);

       await Supabase.initialize(
    url: 'https://jmyxsxrnjnjafstqnhdh.supabase.co',  // Replace with your project URL
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImpteXhzeHJuam5qYWZzdHFuaGRoIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTUxOTg3NDgsImV4cCI6MjA3MDc3NDc0OH0.XwYiqDnoqCGChq51PVpz0SxtZ99Xx0Xf2hs1QMpFBSM',                 // Replace with your anon/public key
  );

  // Run app with providers
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => CourseProvider()),
        ChangeNotifierProvider(create: (_) => NoteProvider()),
        ChangeNotifierProvider(create: (_) => DeadlineProvider()),
      ],
      child: const MyApp(),
    ),
  );
}
