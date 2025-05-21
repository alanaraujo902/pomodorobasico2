import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../models/task.dart';
import '../models/timer_settings.dart';
import '../models/subtask.dart';
import '../models/folder.dart';

class TaskManager extends ChangeNotifier {
  final List<Task> _tasks = [];
  final List<Folder> _folders = [];
  final _uuid = Uuid();

  List<Task> get tasks => List.unmodifiable(_tasks);
  List<Folder> get folders => List.unmodifiable(_folders);

  // --- Inicialização Padrão ---
  void loadInitialTasks(List<Task> initialTasks) {
    _tasks.clear();
    _tasks.addAll(initialTasks);
    notifyListeners();
  }

  // --- Task Management (soltas) ---
  void addTask(String title) {
    final newTask = Task(
      id: _uuid.v4(),
      title: title,
    );
    _tasks.add(newTask);
    notifyListeners();
  }

  void editTaskTitle(String taskId, String newTitle) {
    final task = _tasks.firstWhere((t) => t.id == taskId, orElse: () {
      for (final folder in _folders) {
        try {
          final t = folder.tasks.firstWhere((t) => t.id == taskId);
          t.title = newTitle;
          notifyListeners();
          return t;
        } catch (_) {}
      }
      throw Exception("Task not found");
    });
    task.title = newTitle;
    notifyListeners();
  }

  void deleteTask(String taskId) {
    _tasks.removeWhere((t) => t.id == taskId);
    for (final folder in _folders) {
      folder.tasks.removeWhere((t) => t.id == taskId);
    }
    notifyListeners();
  }

  void toggleTaskCompletion(String taskId) {
    try {
      final task = _tasks.firstWhere((t) => t.id == taskId);
      task.isCompleted = !task.isCompleted;
    } catch (_) {
      for (final folder in _folders) {
        final task = folder.tasks.firstWhere((t) => t.id == taskId, orElse: () => Task(id: '', title: ''));
        if (task.id.isNotEmpty) {
          task.isCompleted = !task.isCompleted;
          break;
        }
      }
    }
    notifyListeners();
  }

  // --- Subtask Management ---
  void addSubtask(String taskId, String subtaskTitle, TimerSettings settings) {
    final task = _findTask(taskId);
    final newSubtask = Subtask(
      id: _uuid.v4(),
      title: subtaskTitle,
      timerSettings: settings,
    );
    task.subtasks = [...task.subtasks, newSubtask];
    notifyListeners();
  }

  void editSubtaskTitle(String taskId, String subtaskId, String newTitle) {
    final subtask = _findSubtask(taskId, subtaskId);
    subtask.title = newTitle;
    notifyListeners();
  }

  void deleteSubtask(String taskId, String subtaskId) {
    final task = _findTask(taskId);
    task.subtasks.removeWhere((st) => st.id == subtaskId);
    notifyListeners();
  }

  void toggleSubtaskCompletion(String taskId, String subtaskId) {
    final task = _findTask(taskId);
    final subtask = task.subtasks.firstWhere((st) => st.id == subtaskId);
    subtask.isCompleted = !subtask.isCompleted;
    task.isCompleted = task.subtasks.every((st) => st.isCompleted);
    notifyListeners();
  }

  void updateSubtaskTimerSettings(String taskId, String subtaskId, TimerSettings newSettings) {
    final subtask = _findSubtask(taskId, subtaskId);
    subtask.timerSettings = newSettings;
    notifyListeners();
  }

  void addTimeToSubtask(String taskId, String subtaskId, Duration timeToAdd) {
    final subtask = _findSubtask(taskId, subtaskId);
    subtask.timeSpent += timeToAdd;
    notifyListeners();
  }

  // --- Folder Support ---
  void addFolder(String name) {
    _folders.add(Folder(id: _uuid.v4(), name: name, tasks: []));
    notifyListeners();
  }

  void addTaskToFolder(String folderId, String title) {
    final folder = _folders.firstWhere((f) => f.id == folderId);
    folder.tasks.add(Task(id: _uuid.v4(), title: title));
    notifyListeners();
  }

  void moveTaskToFolder(String taskId, String folderId) {
    final task = _tasks.firstWhere((t) => t.id == taskId);
    final folder = _folders.firstWhere((f) => f.id == folderId);
    _tasks.removeWhere((t) => t.id == taskId);
    folder.tasks.add(task);
    notifyListeners();
  }

  void removeTaskFromFolder(String folderId, String taskId) {
    final folder = _folders.firstWhere((f) => f.id == folderId);
    final task = folder.tasks.firstWhere((t) => t.id == taskId);
    folder.tasks.remove(task);
    _tasks.add(task);
    notifyListeners();
  }

  void toggleTaskCompletionInFolder(String folderId, String taskId) {
    final folder = _folders.firstWhere((f) => f.id == folderId);
    final task = folder.tasks.firstWhere((t) => t.id == taskId);
    task.isCompleted = !task.isCompleted;
    notifyListeners();
  }

  // --- Helpers ---
  Task _findTask(String taskId) {
    final task = _tasks.firstWhere((t) => t.id == taskId, orElse: () {
      for (final folder in _folders) {
        try {
          return folder.tasks.firstWhere((t) => t.id == taskId);
        } catch (_) {}
      }
      throw Exception("Task not found");
    });
    return task;
  }

  Subtask _findSubtask(String taskId, String subtaskId) {
    final task = _findTask(taskId);
    return task.subtasks.firstWhere((st) => st.id == subtaskId);
  }
}
