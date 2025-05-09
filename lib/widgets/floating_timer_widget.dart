import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/pomodoro_timer.dart';
import '../models/timer_state.dart';
import '../screens/full_screen_timer.dart';

class FloatingTimerWidget extends StatelessWidget {
  const FloatingTimerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<PomodoroTimer>(
      builder: (context, timer, _) {
        if (timer.currentTask == null || timer.currentSubtask == null) {
          return const SizedBox.shrink(); // Esconde só se não tiver tarefa ativa
        }

        final secondsTotal = timer.isFocusSession
            ? timer.settings.focusDuration.inSeconds
            : (timer.currentState == TimerState.runningShortBreak ||
            timer.currentState == TimerState.pausedShortBreak)
            ? timer.settings.shortBreakDuration.inSeconds
            : timer.settings.longBreakDuration.inSeconds;

        final progress = 1 - (timer.remainingTime.inSeconds / secondsTotal);
        final minutes = timer.remainingTime.inMinutes.toString().padLeft(2, '0');

        return Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            margin: const EdgeInsets.only(bottom: 32),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.black87,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const FullScreenTimerView()),
                    );
                  },
                  child: _CircularProgressTime(minutes: minutes, progress: progress),
                ),
                const SizedBox(width: 16),
                if (timer.currentState == TimerState.runningFocus ||
                    timer.currentState == TimerState.runningShortBreak ||
                    timer.currentState == TimerState.runningLongBreak)
                  IconButton(
                    icon: const Icon(Icons.pause, color: Colors.white),
                    onPressed: () => timer.pauseTimer(),
                  )
                else
                  IconButton(
                    icon: const Icon(Icons.play_arrow, color: Colors.white),
                    onPressed: () => timer.startTimer(),
                  ),
                if (timer.currentState != TimerState.initial &&
                    timer.currentState != TimerState.finished)
                  IconButton(
                    icon: const Icon(Icons.stop, color: Colors.white),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          title: Row(
                            children: const [
                              Icon(Icons.timer, color: Colors.red),
                              SizedBox(width: 8),
                              Text('Deseja reiniciar este pomodoro?'),
                            ],
                          ),
                          content: const Text('Tem certeza que quer parar o timer?'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Cancelar'),
                            ),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                                foregroundColor: Colors.white,
                              ),
                              onPressed: () {
                                timer.resetTimer();
                                Navigator.pop(context); // fecha o alerta
                              },
                              child: const Text('Reiniciar'),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _CircularProgressTime extends StatelessWidget {
  final String minutes;
  final double progress;

  const _CircularProgressTime({
    required this.minutes,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _CircularProgressPainter(progress),
      child: SizedBox(
        width: 48,
        height: 48,
        child: Center(
          child: Text(
            minutes,
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}

class _CircularProgressPainter extends CustomPainter {
  final double progress;

  _CircularProgressPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final strokeWidth = 4.0;
    final radius = (size.width - strokeWidth) / 2;
    final center = Offset(size.width / 2, size.height / 2);

    final backgroundPaint = Paint()
      ..color = Colors.white12
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    final progressPaint = Paint()
      ..color = Colors.redAccent
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, backgroundPaint);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi / 2,
      2 * pi * progress,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _CircularProgressPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
