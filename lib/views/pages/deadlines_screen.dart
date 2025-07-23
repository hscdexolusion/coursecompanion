import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:coursecompanion/providers/deadline_provider.dart';
import 'package:coursecompanion/views/pages/add_deadline_screen.dart';
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
        body: Consumer<DeadlineProvider>(
          builder: (context, deadlineProvider, _) {
            final pending = deadlineProvider.pendingDeadlines;
            final completed = deadlineProvider.completedDeadlines;
            final all = deadlineProvider.allDeadlines;

            return TabBarView(
              children: [
                buildDeadlineList(pending, "You have no pending deadlines.", context,"Pending"),
                buildDeadlineList(completed, "You haven't completed any deadlines yet.", context,"Completed"),
                buildDeadlineList(all, "No deadlines available.", context,"All"),
              ],
            );
          },
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

  Widget buildDeadlineList(List deadlines, String emptyMessage, BuildContext context, String Tab) {
  if (deadlines.isEmpty) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.calendar_today, size: 50, color: Colors.grey),
          const SizedBox(height: 10),
          Text(emptyMessage, style: const TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  return ListView.builder(
    itemCount: deadlines.length,
    itemBuilder: (context, index) {
      final d = deadlines[index];
      return Card(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        child: ListTile(
          title: Text(d.title),
          subtitle: Text('${d.course} • Due: ${d.dueDate.toLocal()}'),
          trailing: PopupMenuButton<String>(
            onSelected: (value) {
              final provider = Provider.of<DeadlineProvider>(context, listen: false);
              switch (value) {
                case 'edit':
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => AddDeadlineScreen(existingDeadline: d),
                    ),
                  );
                  break;
                case 'complete':
                  provider.markAsCompleted(d);
                  break;
                case 'delete':
                  provider.deleteDeadline(d);
                  break;
              }
            },
            itemBuilder: (context) {
                  List<PopupMenuEntry<String>> menuItems = [
                    const PopupMenuItem(value: 'delete', child: Text('Delete')),
                  ];

                  if (Tab == 'Pending') {
                    // Only add Edit and Complete for Pending tab
                    menuItems.insertAll(0, [
                      const PopupMenuItem(value: 'edit', child: Text('Edit')),
                      const PopupMenuItem(value: 'complete', child: Text('Mark as Completed')),
                    ]);
                  }

                  return menuItems;
                },

            icon: const Icon(Icons.more_vert),
          ),
        ),
      );
    },
  );
}


  
  
}
