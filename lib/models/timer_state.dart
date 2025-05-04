enum TimerState {
  initial, // Before starting
  runningFocus, // Timer running during a focus session
  pausedFocus, // Timer paused during a focus session
  runningShortBreak, // Timer running during a short break
  pausedShortBreak, // Timer paused during a short break
  runningLongBreak, // Timer running during a long break
  pausedLongBreak, // Timer paused during a long break
  finished // All rounds completed or timer stopped manually
}

