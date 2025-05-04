import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/task.dart';
import '../models/subtask.dart';
import '../services/task_manager.dart';
import '../services/pomodoro_timer.dart';
import '../models/timer_settings.dart';
import '../screens/full_screen_timer.dart'; // IMPORTAÇÃO ADICIONADA

class TaskListItem extends StatelessWidget {
  final Task task;

  const TaskListItem({super.key, required this.task});

  @override
  Widget build(BuildContext context) {
    final taskManager = Provider.of<TaskManager>(context, listen: false);

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
      child: ExpansionTile(
        leading: Checkbox(
          value: task.isCompleted,
          onChanged: (bool? value) {
            taskManager.toggleTaskCompletion(task.id);
          },
        ),
        title: Text(
          task.title,
          style: TextStyle(
            decoration: task.isCompleted ? TextDecoration.lineThrough : null,
          ),
        ),
        children: task.subtasks.map((subtask) => _buildSubtaskTile(context, task.id, subtask)).toList(),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.add_task),
              tooltip: 'Add Subtask',
              onPressed: () {
                _showAddSubtaskDialog(context, task.id);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubtaskTile(BuildContext context, String taskId, Subtask subtask) {
    final taskManager = Provider.of<TaskManager>(context, listen: false);
    final pomodoroTimer = Provider.of<PomodoroTimer>(context, listen: false);

    return ListTile(
      dense: true,
      leading: Checkbox(
        value: subtask.isCompleted,
        onChanged: (bool? value) {
          taskManager.toggleSubtaskCompletion(taskId, subtask.id);
        },
      ),
      title: Text(
        subtask.title,
        style: TextStyle(
          decoration: subtask.isCompleted ? TextDecoration.lineThrough : null,
        ),
      ),
      subtitle: Text('Timer: ${subtask.timerSettings.focusDuration.inMinutes} min | Spent: ${subtask.timeSpent.inMinutes} min'),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.play_circle_outline, size: 20.0),
            tooltip: 'Start Pomodoro for this subtask',
            onPressed: subtask.isCompleted
                ? null
                : () {
              pomodoroTimer.startTimerForSubtask(subtask, taskManager);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const FullScreenTimerView()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.edit, size: 20.0),
            tooltip: 'Edit Subtask',
            onPressed: () {
              _showEditSubtaskDialog(context, taskId, subtask);
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, size: 20.0),
            tooltip: 'Delete Subtask',
            onPressed: () {
              taskManager.deleteSubtask(taskId, subtask.id);
            },
          ),
        ],
      ),
    );
  }

  void _showAddSubtaskDialog(BuildContext context, String taskId) {
    final taskManager = Provider.of<TaskManager>(context, listen: false);
    final defaultSettings = Provider.of<TimerSettings>(context, listen: false);
    final titleController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New Subtask'),
        content: TextField(
          controller: titleController,
          decoration: const InputDecoration(hintText: 'Subtask title'),
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
                taskManager.addSubtask(taskId, titleController.text, defaultSettings);
                Navigator.of(context).pop();
              }
            },
          ),
        ],
      ),
    );
  }

  void _showEditSubtaskDialog(BuildContext context, String taskId, Subtask subtask) {
    final taskManager = Provider.of<TaskManager>(context, listen: false);
    final titleController = TextEditingController(text: subtask.title);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Subtask'),
        content: TextField(
          controller: titleController,
          decoration: const InputDecoration(hintText: 'Subtask title'),
          autofocus: true,
        ),
        actions: [
          TextButton(
            child: const Text('Cancel'),
            onPressed: () => Navigator.of(context).pop(),
          ),
          TextButton(
            child: const Text('Save'),
            onPressed: () {
              if (titleController.text.isNotEmpty) {
                taskManager.editSubtaskTitle(taskId, subtask.id, titleController.text);
                Navigator.of(context).pop();
              }
            },
          ),
        ],
      ),
    );
  }
}
