import 'package:flutter/material.dart';
import '../widgets/task_list.dart';
import '../widgets/timer_view.dart';
import 'settings_screen.dart'; // Import settings screen
import 'package:provider/provider.dart';
import '../services/task_manager.dart';      // for TaskManager
import '../models/timer_settings.dart';      // for TimerSettings
import '../widgets/task_sidebar.dart';
import '../widgets/task_list_item_view.dart';
import '../widgets/floating_timer_widget.dart';


class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? selectedTaskId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pomodoro App'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SettingsScreen()),
              );
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          Row(
            children: [
              SizedBox(
                width: 250,
                child: TaskSidebar(
                  selectedTaskId: selectedTaskId,
                  onTaskSelected: (id) => setState(() => selectedTaskId = id),
                ),
              ),
              const VerticalDivider(width: 1),
              Expanded(
                child: selectedTaskId == null
                    ? const Center(child: Text("Selecione uma tarefa à esquerda"))
                    : TaskListItemView(taskId: selectedTaskId!),
              ),
            ],
          ),
          const FloatingTimerWidget(), // ← Adicionado aqui
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddTaskDialog(context),
        tooltip: 'Add Task',
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddTaskDialog(BuildContext context) {
    final taskManager = Provider.of<TaskManager>(context, listen: false);
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Add Task"),
        content: TextField(controller: controller, autofocus: true),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          TextButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                taskManager.addTask(controller.text);
                Navigator.pop(context);
              }
            },
            child: const Text("Add"),
          ),
        ],
      ),
    );
  }
}
