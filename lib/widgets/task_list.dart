import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/task_manager.dart';
import 'task_list_item.dart';

class TaskList extends StatelessWidget {
  const TaskList({super.key});

  @override
  Widget build(BuildContext context) {
    // Use Consumer to listen to TaskManager changes
    return Consumer<TaskManager>(
      builder: (context, taskManager, child) {
        final tasks = taskManager.tasks;

        if (tasks.isEmpty) {
          return const Center(
            child: Text('No tasks yet. Add one!'),
          );
        }

        // Use ListView.builder for potentially long lists
        return ListView.builder(
          itemCount: tasks.length,
          itemBuilder: (context, index) {
            final task = tasks[index];
            return TaskListItem(task: task);
          },
        );
      },
    );
  }
}

