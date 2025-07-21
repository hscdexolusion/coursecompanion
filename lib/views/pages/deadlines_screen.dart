import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:coursecompanion/views/pages/add_deadline_screen.dart';
import 'package:coursecompanion/views/widgets/empty_state.dart';
import 'package:coursecompanion/views/theme/theme_provider.dart';

class DeadlinesScreen extends StatelessWidget {
  const DeadlinesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
          title: const Text('Deadlines'),
          centerTitle: true,
          actions: [
            IconButton(
              icon: Icon(themeProvider.isDarkMode ? Icons.light_mode : Icons.dark_mode),
              onPressed: () => themeProvider.toggleTheme(),
            ),
          ],
          bottom: const TabBar(
            tabs: [
              Tab(text: "Pending"),
              Tab(text: "Completed"),
              Tab(text: "All"),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            EmptyState(
              icon: Icons.calendar_today,
              message: "You have no pending deadlines.",
            ),
            EmptyState(
              icon: Icons.calendar_today,
              message: "You haven't completed any deadlines yet.",
            ),
            EmptyState(
              icon: Icons.calendar_today,
              message: "No deadlines available.",
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: Colors.blue,
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AddDeadlineScreen()),
            );
          },
          tooltip: 'Add Deadline',
          shape: const CircleBorder(),
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}
