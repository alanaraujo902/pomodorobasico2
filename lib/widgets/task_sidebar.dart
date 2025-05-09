import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/task.dart';
import '../services/task_manager.dart';

class TaskSidebar extends StatelessWidget {
  final String? selectedTaskId;
  final void Function(String taskId) onTaskSelected;

  const TaskSidebar({
    super.key,
    required this.selectedTaskId,
    required this.onTaskSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<TaskManager>(
      builder: (context, taskManager, _) {
        final tasks = taskManager.tasks;

        return ListView(
          children: tasks.map((task) {
            final isSelected = task.id == selectedTaskId;
            return ListTile(
              selected: isSelected,
              selectedTileColor: Colors.blue.shade50,
              title: Text(task.title),
              leading: Checkbox(
                value: task.isCompleted,
                onChanged: (_) {
                  taskManager.toggleTaskCompletion(task.id);
                },
              ),
              onTap: () => onTaskSelected(task.id),
            );
          }).toList(),
        );
      },
    );
  }
}
