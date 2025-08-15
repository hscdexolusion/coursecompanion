import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:coursecompanion/providers/deadline_provider.dart';
import 'package:coursecompanion/views/pages/add_deadline_screen.dart';
import 'package:coursecompanion/views/theme/theme_provider.dart';
import '../../services/notification_service.dart';

class DeadlinesScreen extends StatefulWidget {
  const DeadlinesScreen({super.key});

  @override
  State<DeadlinesScreen> createState() => _DeadlinesScreenState();
}

class _DeadlinesScreenState extends State<DeadlinesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<DeadlineProvider>(context, listen: false).loadDeadlines();
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          flexibleSpace: Container(
              decoration: BoxDecoration(gradient: themeProvider.primaryGradient)),
          foregroundColor: Colors.white,
          title: const Text('Deadlines'),
          centerTitle: true,
          actions: [
            IconButton(
              icon: Icon(themeProvider.isDarkMode
                  ? Icons.light_mode
                  : Icons.dark_mode),
              onPressed: () => themeProvider.toggleTheme(),
            ),
          ],
          bottom: TabBar(
            indicatorColor: Colors.white.withOpacity(0.3),
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white.withOpacity(0.7),
            tabs: const [
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
                buildDeadlineList(pending, deadlineProvider,
                    "You have no pending deadlines.", context, themeProvider),
                buildDeadlineList(completed, deadlineProvider,
                    "You haven't completed any deadlines yet.", context, themeProvider),
                buildDeadlineList(
                    all, deadlineProvider, "No deadlines available.", context, themeProvider),
              ],
            );
          },
        ),
        floatingActionButton: Container(
          decoration: BoxDecoration(
            gradient: themeProvider.floatingActionButtonGradient,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4))
            ],
          ),
          child: FloatingActionButton(
            backgroundColor: Colors.transparent,
            foregroundColor: Colors.white,
            onPressed: () => Navigator.push(
                context, MaterialPageRoute(builder: (_) => const AddDeadlineScreen())),
            tooltip: 'Add Deadline',
            shape: const CircleBorder(),
            child: const Icon(Icons.add),
          ),
        ),
      ),
    );
  }

  Widget buildDeadlineList(List deadlines, DeadlineProvider deadlineProvider,
      String emptyMessage, BuildContext context, ThemeProvider themeProvider) {
    if (deadlines.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.calendar_today, size: 50, color: Colors.grey),
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
        return GestureDetector(
          onTap: () => Navigator.push(
              context, MaterialPageRoute(builder: (_) => AddDeadlineScreen(existingDeadline: d))),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  themeProvider.isDarkMode
                      ? Colors.tealAccent.withOpacity(0.3)
                      : Colors.orange.withOpacity(0.2),
                  themeProvider.isDarkMode
                      ? Colors.tealAccent.withOpacity(0.1)
                      : Colors.orange.withOpacity(0.05),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 6,
                    offset: const Offset(0, 4)),
              ],
            ),
            child: ListTile(
              title: Text(d.title),
              subtitle: Text('${d.courseName} • Due: ${d.dueDate.toLocal()}'),
              trailing: PopupMenuButton<String>(
                onSelected: (value) async {
                  switch (value) {
                    case 'edit':
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => AddDeadlineScreen(existingDeadline: d)));
                      break;
                    case 'complete':
                      deadlineProvider.markAsCompleted(d);
                      break;
                    case 'delete':
                      await NotificationService.cancelNotification(d.id.hashCode);
                      deadlineProvider.deleteDeadline(d);
                      break;
                  }
                },
                itemBuilder: (context) {
                  List<PopupMenuEntry<String>> menuItems = [
                    const PopupMenuItem(value: 'delete', child: Text('Delete'))
                  ];
                  if (deadlines == deadlineProvider.pendingDeadlines) {
                    menuItems.insertAll(0, [
                      const PopupMenuItem(value: 'edit', child: Text('Edit')),
                      const PopupMenuItem(
                          value: 'complete', child: Text('Mark as Completed')),
                    ]);
                  }
                  return menuItems;
                },
                icon: const Icon(Icons.more_vert),
              ),
            ),
          ),
        );
      },
    );
  }
}
