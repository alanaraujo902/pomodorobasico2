import 'timer_settings.dart';

class Subtask {
  String id;
  String title;
  TimerSettings timerSettings;
  bool isCompleted;
  Duration timeSpent;

  Subtask({
    required this.id,
    required this.title,
    required this.timerSettings,
    this.isCompleted = false,
    this.timeSpent = Duration.zero,
  });
}