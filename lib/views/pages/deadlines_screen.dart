import 'package:coursecompanion/views/pages/add_deadline_screen.dart';
import 'package:flutter/material.dart';
import '../widgets/empty_state.dart';

class DeadlinesScreen extends StatelessWidget {
  const DeadlinesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Deadlines'),
          centerTitle: true,
          bottom: TabBar(
            tabs: const [
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
                message: "You have no pending deadlines."),
            EmptyState(
                icon: Icons.calendar_today,
                message: "You haven't completed any deadlines yet."),
            EmptyState(
                icon: Icons.calendar_today, message: "No deadlines available."),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.push(context,
                MaterialPageRoute(builder: (_) => const AddDeadlineScreen()));
          },
          tooltip: 'Increment',
          shape: const CircleBorder(),
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}
