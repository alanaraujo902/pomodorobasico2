import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/pomodoro_timer.dart';
import '../models/timer_state.dart';

class FullScreenTimerView extends StatelessWidget {
  const FullScreenTimerView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Consumer<PomodoroTimer>(
          builder: (context, timer, child) {
            final formattedTime = "${timer.remainingTime.inMinutes.toString().padLeft(2, '0')}:${(timer.remainingTime.inSeconds % 60).toString().padLeft(2, '0')}";

            return Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 48.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    formattedTime,
                    style: Theme.of(context).textTheme.displayLarge?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(_getCurrentStateText(timer.currentState),
                      style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 8),
                  if (timer.currentTask != null)
                    Text("Task: ${timer.currentTask!.title}",
                        style: Theme.of(context).textTheme.titleMedium),
                  if (timer.currentSubtask != null)
                    Text("Subtask: ${timer.currentSubtask!.title}",
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Theme.of(context).colorScheme.secondary,
                        )),
                  const SizedBox(height: 32),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
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
                      if (timer.currentState == TimerState.pausedFocus ||
                          timer.currentState == TimerState.pausedShortBreak ||
                          timer.currentState == TimerState.pausedLongBreak)
                        ElevatedButton.icon(
                          icon: const Icon(Icons.play_arrow),
                          label: const Text('Resume'),
                          onPressed: () => timer.startTimer(),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green.shade600,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      const SizedBox(width: 16),
                      TextButton.icon(
                        icon: const Icon(Icons.stop),
                        label: const Text('Reset'),
                        onPressed: () => timer.resetTimer(),
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.red.shade600,
                        ),
                      ),
                      const SizedBox(width: 16),
                      TextButton.icon(
                        icon: const Icon(Icons.close),
                        label: const Text('Close'),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  )
                ],
              ),
            );
          },
        ),
      ),
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
    }
  }
}
