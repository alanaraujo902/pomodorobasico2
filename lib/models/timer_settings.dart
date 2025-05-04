import 'package:flutter/foundation.dart';

class TimerSettings extends ChangeNotifier {
  Duration focusDuration;
  Duration shortBreakDuration;
  Duration longBreakDuration;
  int roundsBeforeLongBreak;

  TimerSettings({
    this.focusDuration = const Duration(minutes: 25),
    this.shortBreakDuration = const Duration(minutes: 5),
    this.longBreakDuration = const Duration(minutes: 15),
    this.roundsBeforeLongBreak = 4,
  });

  void update({
    Duration? focusDuration,
    Duration? shortBreakDuration,
    Duration? longBreakDuration,
    int? roundsBeforeLongBreak,
  }) {
    this.focusDuration = focusDuration ?? this.focusDuration;
    this.shortBreakDuration = shortBreakDuration ?? this.shortBreakDuration;
    this.longBreakDuration = longBreakDuration ?? this.longBreakDuration;
    this.roundsBeforeLongBreak = roundsBeforeLongBreak ?? this.roundsBeforeLongBreak;
    notifyListeners();
  }

  TimerSettings copyWith({
    Duration? focusDuration,
    Duration? shortBreakDuration,
    Duration? longBreakDuration,
    int? roundsBeforeLongBreak,
  }) {
    return TimerSettings(
      focusDuration: focusDuration ?? this.focusDuration,
      shortBreakDuration: shortBreakDuration ?? this.shortBreakDuration,
      longBreakDuration: longBreakDuration ?? this.longBreakDuration,
      roundsBeforeLongBreak: roundsBeforeLongBreak ?? this.roundsBeforeLongBreak,
    );
  }
}
