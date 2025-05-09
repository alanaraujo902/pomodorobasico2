import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/task_manager.dart';
import '../widgets/task_list_item.dart';
import 'package:collection/collection.dart';
import '../models/task.dart';



class TaskListItemView extends StatelessWidget {
  final String taskId;

  const TaskListItemView({super.key, required this.taskId});

  @override
  Widget build(BuildContext context) {
    return Consumer<TaskManager>(
      builder: (_, manager, __) {
        final Task? task = manager.tasks.firstWhereOrNull((t) => t.id == taskId);

        if (task == null) {
          return const Center(child: Text("Tarefa não encontrada"));
        }
        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: TaskListItem(task: task),
          ),
        );
      },
    );
  }
}