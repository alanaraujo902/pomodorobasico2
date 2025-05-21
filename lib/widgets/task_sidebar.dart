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
        final folders = taskManager.folders;
        final looseTasks = taskManager.tasks;

        return ListView(
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text('Tarefas soltas', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            ...looseTasks.map((task) {
              final isSelected = task.id == selectedTaskId;
              return ListTile(
                selected: isSelected,
                selectedTileColor: Colors.blue.shade50,
                title: Text(task.title),
                leading: Checkbox(
                  value: task.isCompleted,
                  onChanged: (_) => taskManager.toggleTaskCompletion(task.id),
                ),
                onTap: () => onTaskSelected(task.id),
              );
            }),
            const Divider(height: 32),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text('Pastas', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            ...folders.map((folder) {
              return ExpansionTile(
                title: Text(folder.name),
                children: folder.tasks.map((task) {
                  final isSelected = task.id == selectedTaskId;
                  return ListTile(
                    selected: isSelected,
                    selectedTileColor: Colors.blue.shade50,
                    title: Text(task.title),
                    leading: Checkbox(
                      value: task.isCompleted,
                      onChanged: (_) =>
                          taskManager.toggleTaskCompletionInFolder(folder.id, task.id),
                    ),
                    onTap: () => onTaskSelected(task.id),
                  );
                }).toList(),
              );
            }),
            ListTile(
              leading: const Icon(Icons.create_new_folder),
              title: const Text("Nova Pasta"),
              onTap: () => _showAddFolderDialog(context),
            )
          ],
        );
      },
    );
  }

  void _showAddFolderDialog(BuildContext context) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Nova Pasta"),
        content: TextField(controller: controller, autofocus: true),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancelar")),
          TextButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                Provider.of<TaskManager>(context, listen: false).addFolder(controller.text);
                Navigator.pop(context);
              }
            },
            child: const Text("Criar"),
          ),
        ],
      ),
    );
  }
}
