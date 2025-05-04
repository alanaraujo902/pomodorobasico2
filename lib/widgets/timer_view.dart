import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/pomodoro_timer.dart';
import '../models/timer_state.dart';

class TimerView extends StatelessWidget {
  const TimerView({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<PomodoroTimer>(
      builder: (context, timer, child) {
        String formattedTime =
            "${timer.remainingTime.inMinutes.toString().padLeft(2, '0')}:${(timer.remainingTime.inSeconds % 60).toString().padLeft(2, '0')}";

        return Card(
          elevation: 2.0,
          margin: const EdgeInsets.all(16.0),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  formattedTime,
                  style: Theme.of(context).textTheme.displayLarge?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  _getCurrentStateText(timer.currentState),
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                if (timer.currentTask != null)
                  Text(
                    "Task: ${timer.currentTask!.title}",
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                if (timer.currentSubtask != null)
                  Text(
                    "Subtask: ${timer.currentSubtask!.title}",
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                  ),
                if (timer.currentState != TimerState.initial && timer.currentState != TimerState.finished)
                  Text(
                    "Round: ${timer.currentRound}",
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                const SizedBox(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    if (timer.currentState == TimerState.initial ||
                        timer.currentState == TimerState.pausedFocus ||
                        timer.currentState == TimerState.pausedShortBreak ||
                        timer.currentState == TimerState.pausedLongBreak ||
                        timer.currentState == TimerState.finished)
                      ElevatedButton.icon(
                        icon: const Icon(Icons.play_arrow),
                        label: Text(timer.currentState == TimerState.initial || timer.currentState == TimerState.finished ? 'Start' : 'Resume'),
                        onPressed: () => timer.startTimer(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green.shade600,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    if (timer.currentState == TimerState.runningFocus ||
                        timer.currentState == TimerState.runningShortBreak ||
                        timer.currentState == TimerState.runningLongBreak)
                      ElevatedButton.icon(
                        icon: const Icon(Icons.pause),
                        label: const Text('Pause'),
                        onPressed: () => timer.pauseTimer(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange.shade600,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    if (timer.currentState != TimerState.initial && timer.currentState != TimerState.finished)
                      TextButton.icon(
                        icon: const Icon(Icons.skip_next),
                        label: const Text('Skip'),
                        onPressed: () => timer.skipSession(),
                      ),
                    if (timer.currentState != TimerState.initial && timer.currentState != TimerState.finished)
                      TextButton.icon(
                        icon: const Icon(Icons.stop),
                        label: const Text('Reset'),
                        onPressed: () => timer.resetTimer(),
                        style: TextButton.styleFrom(foregroundColor: Colors.red.shade600),
                      ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _getCurrentStateText(TimerState state) {
    switch (state) {
      case TimerState.runningFocus:
      case TimerState.pausedFocus:
        return 'Focus';
      case TimerState.runningShortBreak:
      case TimerState.pausedShortBreak:
        return 'Short Break';
      case TimerState.runningLongBreak:
      case TimerState.pausedLongBreak:
        return 'Long Break';
      case TimerState.initial:
        return 'Ready to Start';
      case TimerState.finished:
        return 'Finished';
      default:
        return '';
    }
  }
}
