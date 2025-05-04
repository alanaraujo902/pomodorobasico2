import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../models/task.dart';
import '../models/timer_settings.dart';
import '../models/subtask.dart';

class TaskManager extends ChangeNotifier {
  final List<Task> _tasks = [];
  final _uuid = Uuid();

  List<Task> get tasks => List.unmodifiable(_tasks);

  // --- Inicialização Padrão ---
  void loadInitialTasks(List<Task> initialTasks) {
    _tasks.clear();
    _tasks.addAll(initialTasks);
    notifyListeners();
  }

  // --- Task Management ---

  void addTask(String title) {
    final newTask = Task(
      id: _uuid.v4(),
      title: title,
    );
    _tasks.add(newTask);
    notifyListeners();
  }

  void editTaskTitle(String taskId, String newTitle) {
    try {
      final task = _tasks.firstWhere((t) => t.id == taskId);
      task.title = newTitle;
      notifyListeners();
    } catch (e) {
      print("Error editing task title: Task with id $taskId not found.");
    }
  }

  void deleteTask(String taskId) {
    _tasks.removeWhere((t) => t.id == taskId);
    notifyListeners();
  }

  void toggleTaskCompletion(String taskId) {
    try {
      final task = _tasks.firstWhere((t) => t.id == taskId);
      task.isCompleted = !task.isCompleted;
      notifyListeners();
    } catch (e) {
      print("Error toggling task completion: Task with id $taskId not found.");
    }
  }

  // --- Subtask Management ---

  void addSubtask(String taskId, String subtaskTitle, TimerSettings settings) {
    try {
      final task = _tasks.firstWhere((t) => t.id == taskId);
      final newSubtask = Subtask(
        id: _uuid.v4(),
        title: subtaskTitle,
        timerSettings: settings,
      );
      final updatedSubtasks = List<Subtask>.from(task.subtasks);
      updatedSubtasks.add(newSubtask);
      task.subtasks = updatedSubtasks;
      notifyListeners();
    } catch (e) {
      print("Error adding subtask: Task with id $taskId not found.");
    }
  }

  void editSubtaskTitle(String taskId, String subtaskId, String newTitle) {
    try {
      final task = _tasks.firstWhere((t) => t.id == taskId);
      final subtask = task.subtasks.firstWhere((st) => st.id == subtaskId);
      subtask.title = newTitle;
      notifyListeners();
    } catch (e) {
      print("Error editing subtask title: Task $taskId or Subtask $subtaskId not found.");
    }
  }

  void deleteSubtask(String taskId, String subtaskId) {
    try {
      final task = _tasks.firstWhere((t) => t.id == taskId);
      final updatedSubtasks = List<Subtask>.from(task.subtasks);
      updatedSubtasks.removeWhere((st) => st.id == subtaskId);
      task.subtasks = updatedSubtasks;
      notifyListeners();
    } catch (e) {
      print("Error deleting subtask: Task $taskId or Subtask $subtaskId not found.");
    }
  }

  void toggleSubtaskCompletion(String taskId, String subtaskId) {
    try {
      final task = _tasks.firstWhere((t) => t.id == taskId);
      final subtask = task.subtasks.firstWhere((st) => st.id == subtaskId);
      subtask.isCompleted = !subtask.isCompleted;
      _updateParentTaskCompletion(task);
      notifyListeners();
    } catch (e) {
      print("Error toggling subtask completion: Task $taskId or Subtask $subtaskId not found.");
    }
  }

  void updateSubtaskTimerSettings(String taskId, String subtaskId, TimerSettings newSettings) {
    try {
      final task = _tasks.firstWhere((t) => t.id == taskId);
      final subtask = task.subtasks.firstWhere((st) => st.id == subtaskId);
      subtask.timerSettings = newSettings;
      notifyListeners();
    } catch (e) {
      print("Error updating subtask timer settings: Task $taskId or Subtask $subtaskId not found.");
    }
  }

  void addTimeToSubtask(String taskId, String subtaskId, Duration timeToAdd) {
    try {
      final task = _tasks.firstWhere((t) => t.id == taskId);
      final subtask = task.subtasks.firstWhere((st) => st.id == subtaskId);
      subtask.timeSpent += timeToAdd;
      notifyListeners();
    } catch (e) {
      print("Error adding time to subtask: Task $taskId or Subtask $subtaskId not found.");
    }
  }

  // --- Helper Methods ---

  void _updateParentTaskCompletion(Task task) {
    if (task.subtasks.isNotEmpty) {
      task.isCompleted = task.subtasks.every((st) => st.isCompleted);
    }
  }
}
