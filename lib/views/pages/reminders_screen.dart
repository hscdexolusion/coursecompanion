import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'package:coursecompanion/models/reminder_model.dart';
import 'package:coursecompanion/providers/reminder_provider.dart';
import 'package:coursecompanion/views/pages/add_reminder_screen.dart';
import 'package:coursecompanion/views/theme/theme_provider.dart';
import 'package:coursecompanion/views/widgets/empty_state.dart';
import 'package:coursecompanion/services/web_notification_service.dart';
import 'package:intl/intl.dart';

class RemindersScreen extends StatefulWidget {
  const RemindersScreen({super.key});

  @override
  State<RemindersScreen> createState() => _RemindersScreenState();
}

class _RemindersScreenState extends State<RemindersScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  String _getReminderTypeText(ReminderType type) {
    switch (type) {
      case ReminderType.general:
        return 'General';
      case ReminderType.assignment:
        return 'Assignment';
      case ReminderType.exam:
        return 'Exam';
      case ReminderType.classReminder:
        return 'Class';
      case ReminderType.meeting:
        return 'Meeting';
      case ReminderType.personal:
        return 'Personal';
    }
  }

  Color _getReminderTypeColor(ReminderType type) {
    switch (type) {
      case ReminderType.general:
        return Colors.blue;
      case ReminderType.assignment:
        return Colors.orange;
      case ReminderType.exam:
        return Colors.red;
      case ReminderType.classReminder:
        return Colors.green;
      case ReminderType.meeting:
        return Colors.purple;
      case ReminderType.personal:
        return Colors.teal;
    }
  }

  String _getRepeatText(ReminderRepeat repeat) {
    switch (repeat) {
      case ReminderRepeat.once:
        return 'Once';
      case ReminderRepeat.daily:
        return 'Daily';
      case ReminderRepeat.weekly:
        return 'Weekly';
      case ReminderRepeat.monthly:
        return 'Monthly';
      case ReminderRepeat.yearly:
        return 'Yearly';
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final reminderProvider = Provider.of<ReminderProvider>(context);

    return Scaffold(
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: themeProvider.primaryGradient,
          ),
        ),
        foregroundColor: Colors.white,
        centerTitle: true,
        automaticallyImplyLeading: false,
        title: const Text('Reminders'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notification_add),
            onPressed: () async {
              // Test notification
              if (kIsWeb) {
                await WebNotificationService().showNotification(
                  title: 'Test Reminder',
                  body: 'This is a test notification from Course Companion!',
                  tag: 'test',
                );
              }
            },
            tooltip: 'Test Notification',
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AddReminderScreen(),
                ),
              );
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: 'Today'),
            Tab(text: 'Upcoming'),
            Tab(text: 'All'),
            Tab(text: 'Overdue'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildRemindersList(reminderProvider.todaysReminders, 'No reminders for today'),
          _buildRemindersList(reminderProvider.upcomingReminders, 'No upcoming reminders'),
          _buildRemindersList(reminderProvider.reminders, 'No reminders yet'),
          _buildRemindersList(reminderProvider.overdueReminders, 'No overdue reminders'),
        ],
      ),
    );
  }

  Widget _buildRemindersList(List<Reminder> reminders, String emptyMessage) {
    if (reminders.isEmpty) {
      return EmptyState(
        icon: Icons.notifications_off,
        title: 'No reminders',
        subtitle: emptyMessage,
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: reminders.length,
      itemBuilder: (context, index) {
        final reminder = reminders[index];
        final isOverdue = reminder.scheduledTime.isBefore(DateTime.now());
        
        return Card(
          margin: const EdgeInsets.only(bottom: 12.0),
          elevation: 4,
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: _getReminderTypeColor(reminder.type),
              child: Icon(
                _getReminderIcon(reminder.type),
                color: Colors.white,
              ),
            ),
            title: Text(
              reminder.title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                decoration: isOverdue ? TextDecoration.lineThrough : null,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (reminder.description.isNotEmpty)
                  Text(
                    reminder.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      size: 16,
                      color: isOverdue ? Colors.red : Colors.grey[600],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      DateFormat('MMM dd, yyyy - HH:mm').format(reminder.scheduledTime),
                      style: TextStyle(
                        color: isOverdue ? Colors.red : Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: _getReminderTypeColor(reminder.type).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        _getReminderTypeText(reminder.type),
                        style: TextStyle(
                          color: _getReminderTypeColor(reminder.type),
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.grey.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        _getRepeatText(reminder.repeat),
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                if (reminder.courseName != null) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.school,
                        size: 16,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        reminder.courseName!,
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
            trailing: PopupMenuButton<String>(
              onSelected: (value) {
                switch (value) {
                  case 'edit':
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AddReminderScreen(reminder: reminder),
                      ),
                    );
                    break;
                  case 'toggle':
                    Provider.of<ReminderProvider>(context, listen: false).toggleReminder(reminder.id);
                    break;
                  case 'delete':
                    _showDeleteDialog(reminder);
                    break;
                }
              },
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 'edit',
                  child: const Row(
                    children: [
                      Icon(Icons.edit),
                      SizedBox(width: 8),
                      Text('Edit'),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'toggle',
                  child: Row(
                    children: [
                      Icon(reminder.isActive ? Icons.pause : Icons.play_arrow),
                      const SizedBox(width: 8),
                      Text(reminder.isActive ? 'Pause' : 'Activate'),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'delete',
                  child: const Row(
                    children: [
                      Icon(Icons.delete, color: Colors.red),
                      SizedBox(width: 8),
                      Text('Delete', style: TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  IconData _getReminderIcon(ReminderType type) {
    switch (type) {
      case ReminderType.general:
        return Icons.notifications;
      case ReminderType.assignment:
        return Icons.assignment;
      case ReminderType.exam:
        return Icons.quiz;
      case ReminderType.classReminder:
        return Icons.school;
      case ReminderType.meeting:
        return Icons.meeting_room;
      case ReminderType.personal:
        return Icons.person;
    }
  }

  void _showDeleteDialog(Reminder reminder) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Reminder'),
        content: Text('Are you sure you want to delete "${reminder.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final provider = Provider.of<ReminderProvider>(context, listen: false);
              provider.deleteReminder(reminder.id);
              Navigator.pop(context);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
} 