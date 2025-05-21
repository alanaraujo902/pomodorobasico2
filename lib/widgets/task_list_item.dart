import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/task.dart';
import '../models/subtask.dart';
import '../services/task_manager.dart';
import '../services/pomodoro_timer.dart';
import '../models/timer_settings.dart';
import '../screens/full_screen_timer.dart';

class TaskListItem extends StatelessWidget {
  final Task task;

  const TaskListItem({super.key, required this.task});

  @override
  Widget build(BuildContext context) {
    final taskManager = Provider.of<TaskManager>(context, listen: false);
    final defaultSettings = Provider.of<TimerSettings>(context, listen: false);
    final titleController = TextEditingController();

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  task.title,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'mover') {
                    _showMoveToFolderDialog(context, task.id);
                  } else if (value == 'remover') {
                    final taskManager = Provider.of<TaskManager>(context, listen: false);
                    for (final folder in taskManager.folders) {
                      final exists = folder.tasks.any((t) => t.id == task.id);
                      if (exists) {
                        taskManager.removeTaskFromFolder(folder.id, task.id);
                        break;
                      }
                    }
                  }
                },
                itemBuilder: (_) => [
                  const PopupMenuItem(value: 'mover', child: Text('Mover para pasta')),
                  const PopupMenuItem(value: 'remover', child: Text('Mover para tarefas soltas')),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextField(
            controller: titleController,
            onSubmitted: (text) {
              if (text.isNotEmpty) {
                taskManager.addSubtask(task.id, text, defaultSettings);
                titleController.clear();
              }
            },
            decoration: InputDecoration(
              hintText: 'Adicionar subtarefa na tarefa "${task.title}"... Pressione Enter para confirmar',
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Theme.of(context).colorScheme.primary),
              ),
              filled: true,
              fillColor: Colors.grey.shade100,
            ),
          ),
          const SizedBox(height: 16),
          if (task.subtasks.isEmpty)
            const Center(child: Text('Nenhuma subtarefa')),
          ...task.subtasks.map((subtask) => _buildSubtaskTile(context, task.id, subtask)).toList(),
        ],
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
      subtitle: Text(
        'Timer: ${subtask.timerSettings.focusDuration.inMinutes} min | Spent: ${subtask.timeSpent.inMinutes} min',
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.play_circle_outline, size: 20.0),
            tooltip: 'Iniciar Pomodoro para esta subtarefa',
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
            tooltip: 'Editar Subtarefa',
            onPressed: () {
              _showEditSubtaskDialog(context, taskId, subtask);
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, size: 20.0),
            tooltip: 'Excluir Subtarefa',
            onPressed: () {
              taskManager.deleteSubtask(taskId, subtask.id);
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
        title: const Text('Editar Subtarefa'),
        content: TextField(
          controller: titleController,
          decoration: const InputDecoration(hintText: 'Título da subtarefa'),
          autofocus: true,
        ),
        actions: [
          TextButton(
            child: const Text('Cancelar'),
            onPressed: () => Navigator.of(context).pop(),
          ),
          TextButton(
            child: const Text('Salvar'),
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

  void _showMoveToFolderDialog(BuildContext context, String taskId) {
    final taskManager = Provider.of<TaskManager>(context, listen: false);
    final folders = taskManager.folders;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Mover para pasta"),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: folders.length,
            itemBuilder: (context, index) {
              final folder = folders[index];
              return ListTile(
                title: Text(folder.name),
                onTap: () {
                  taskManager.moveTaskToFolder(taskId, folder.id);
                  Navigator.pop(context);
                },
              );
            },
          ),
        ),
      ),
    );
  }
}
