import 'subtask.dart'; // ADD THIS LINE
import 'timer_settings.dart';

class Task {
  String id;
  String title;
  List<Subtask> subtasks;
  bool isCompleted;

  Task({
    required this.id,
    required this.title,
    this.subtasks = const [],
    this.isCompleted = false,
  });
}


