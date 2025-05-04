import 'package:flutter/material.dart';
import '../widgets/task_list.dart';
import '../widgets/timer_view.dart';
import 'settings_screen.dart'; // Import settings screen
import 'package:provider/provider.dart';
import '../services/task_manager.dart';      // for TaskManager
import '../models/timer_settings.dart';      // for TimerSettings

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Basic layout: Timer on top, Task list below for desktop-like view
    // Could use Row for side-by-side on wider screens later
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pomodoro App'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: 'Settings',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );
            },
          ),
          // TODO: Add navigation to Statistics screen
        ],
      ),
      body: Column(
        children: [
          const TimerView(), // Timer display and controls
          const Divider(),
          Expanded(
            child: const TaskList(), // Scrollable task list
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Show dialog to add a new Task
          _showAddTaskDialog(context);
        },
        tooltip: 'Add Task',
        child: const Icon(Icons.add),
      ),
    );
  }

  // Placeholder for Add Task Dialog (similar to Add Subtask)
  void _showAddTaskDialog(BuildContext context) {
     final taskManager = Provider.of<TaskManager>(context, listen: false);
     final titleController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New Task'),
        content: TextField(
          controller: titleController,
          decoration: const InputDecoration(hintText: 'Task title'),
          autofocus: true,
        ),
        actions: [
          TextButton(
            child: const Text('Cancel'),
            onPressed: () => Navigator.of(context).pop(),
          ),
          TextButton(
            child: const Text('Add'),
            onPressed: () {
              if (titleController.text.isNotEmpty) {
                taskManager.addTask(titleController.text);
                Navigator.of(context).pop();
              }
            },
          ),
        ],
      ),
    );
  }
}

