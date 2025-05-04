import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/timer_settings.dart';
import '../models/timer_state.dart';
import '../models/subtask.dart';
import '../models/task.dart';
import 'task_manager.dart';

class PomodoroTimer extends ChangeNotifier {
  final TimerSettings _defaultSettings;
  Timer? _timer;
  TimerSettings _settings;
  TimerState _currentState = TimerState.initial;
  Duration _remainingTime;
  int _currentRound = 0;
  bool _isFocusSession = true;

  Subtask? _currentSubtask;
  Task? _currentTask;

  PomodoroTimer(TimerSettings settings)
      : _defaultSettings = settings.copyWith(),
        _settings = settings.copyWith(),
        _remainingTime = settings.focusDuration {
    settings.addListener(() {
      updateSettings(settings);
    });
  }

  TimerState get currentState => _currentState;
  Duration get remainingTime => _remainingTime;
  int get currentRound => _currentRound;
  bool get isFocusSession => _isFocusSession;
  TimerSettings get settings => _settings;

  Subtask? get currentSubtask => _currentSubtask;
  Task? get currentTask => _currentTask;

  void updateSettings(TimerSettings newSettings) {
    _defaultSettings
      ..focusDuration = newSettings.focusDuration
      ..shortBreakDuration = newSettings.shortBreakDuration
      ..longBreakDuration = newSettings.longBreakDuration
      ..roundsBeforeLongBreak = newSettings.roundsBeforeLongBreak;

    _settings = newSettings.copyWith();

    if (_currentState == TimerState.initial || _currentState == TimerState.finished) {
      resetTimer();
    }

    notifyListeners();
  }

  void startTimer() {
    if (_currentState == TimerState.initial || _currentState == TimerState.finished) {
      _isFocusSession = true;
      _currentRound = 1;
      _remainingTime = _settings.focusDuration;
      _currentState = TimerState.runningFocus;
    } else if (_currentState == TimerState.pausedFocus ||
        _currentState == TimerState.pausedShortBreak ||
        _currentState == TimerState.pausedLongBreak) {
      _currentState = _isFocusSession
          ? TimerState.runningFocus
          : (_currentRound % _settings.roundsBeforeLongBreak == 0
          ? TimerState.runningLongBreak
          : TimerState.runningShortBreak);
    } else {
      return;
    }

    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), _tick);
    notifyListeners();
  }

  void pauseTimer() {
    if (_currentState == TimerState.runningFocus ||
        _currentState == TimerState.runningShortBreak ||
        _currentState == TimerState.runningLongBreak) {
      _timer?.cancel();
      _currentState = _isFocusSession
          ? TimerState.pausedFocus
          : (_currentRound % _settings.roundsBeforeLongBreak == 0
          ? TimerState.pausedLongBreak
          : TimerState.pausedShortBreak);
      notifyListeners();
    }
  }

  void resetTimer() {
    _timer?.cancel();
    _isFocusSession = true;
    _currentRound = 0;

    // Sempre obtém os valores atualizados do ChangeNotifier TimerSettings
    _defaultSettings
      ..focusDuration = _settings.focusDuration
      ..shortBreakDuration = _settings.shortBreakDuration
      ..longBreakDuration = _settings.longBreakDuration
      ..roundsBeforeLongBreak = _settings.roundsBeforeLongBreak;

    if (_currentSubtask != null) {
      // Aplica os novos valores da configuração global também à subtarefa
      _currentSubtask!.timerSettings = _defaultSettings.copyWith();
      _settings = _currentSubtask!.timerSettings;
    } else {
      _settings = _defaultSettings.copyWith();
    }

    _remainingTime = _settings.focusDuration;
    _currentState = TimerState.initial;
    notifyListeners();
  }

  void skipSession() {
    _timer?.cancel();
    _handleSessionCompletion();
  }

  void _tick(Timer timer) {
    if (_remainingTime > Duration.zero) {
      _remainingTime -= const Duration(seconds: 1);
    } else {
      _timer?.cancel();
      _handleSessionCompletion();
    }
    notifyListeners();
  }

  void _handleSessionCompletion() {
    if (_isFocusSession) {
      _isFocusSession = false;
      if (_currentRound % _settings.roundsBeforeLongBreak == 0) {
        _remainingTime = _settings.longBreakDuration;
        _currentState = TimerState.runningLongBreak;
      } else {
        _remainingTime = _settings.shortBreakDuration;
        _currentState = TimerState.runningShortBreak;
      }
    } else {
      _isFocusSession = true;
      _currentRound++;
      _remainingTime = _settings.focusDuration;
      _currentState = TimerState.runningFocus;
    }

    _timer = Timer.periodic(const Duration(seconds: 1), _tick);
    notifyListeners();
  }

  void startTimerForSubtask(Subtask subtask, TaskManager taskManager) {
    final isSameSubtask = _currentSubtask?.id == subtask.id;

    if (isSameSubtask &&
        (_currentState == TimerState.runningFocus ||
            _currentState == TimerState.runningShortBreak ||
            _currentState == TimerState.runningLongBreak)) {
      return;
    }

    subtask.timerSettings = _defaultSettings.copyWith();

    if (!isSameSubtask && _currentSubtask != null) {
      _currentSubtask!.timerSettings = _currentSubtask!.timerSettings.copyWith(
        focusDuration: _remainingTime,
      );
    }

    _currentTask = taskManager.tasks.firstWhere(
          (task) => task.subtasks.any((st) => st.id == subtask.id),
      orElse: () => Task(id: '', title: 'Unknown', subtasks: []),
    );
    _currentSubtask = subtask;

    final wasPaused = _currentState == TimerState.pausedFocus ||
        _currentState == TimerState.pausedShortBreak ||
        _currentState == TimerState.pausedLongBreak;

    _settings = subtask.timerSettings;

    if (wasPaused) {
      _currentState = _isFocusSession
          ? TimerState.runningFocus
          : (_currentRound % _settings.roundsBeforeLongBreak == 0
          ? TimerState.runningLongBreak
          : TimerState.runningShortBreak);

      _timer?.cancel();
      _timer = Timer.periodic(const Duration(seconds: 1), _tick);
      notifyListeners();
      return;
    }

    if (_currentState == TimerState.initial || _currentState == TimerState.finished) {
      _remainingTime = _settings.focusDuration;
      _currentRound = 1;
      _isFocusSession = true;
      _currentState = TimerState.runningFocus;

      _timer?.cancel();
      _timer = Timer.periodic(const Duration(seconds: 1), _tick);
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
