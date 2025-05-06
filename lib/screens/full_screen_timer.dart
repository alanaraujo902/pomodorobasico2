import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/pomodoro_timer.dart';
import '../models/timer_state.dart';
import 'dart:math';

class FullScreenTimerView extends StatelessWidget {
  const FullScreenTimerView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FD),
      body: SafeArea(
        child: Consumer<PomodoroTimer>(
          builder: (context, timer, _) {
            final secondsTotal = timer.isFocusSession
                ? timer.settings.focusDuration.inSeconds
                : (timer.currentState == TimerState.runningShortBreak ||
                timer.currentState == TimerState.pausedShortBreak)
                ? timer.settings.shortBreakDuration.inSeconds
                : timer.settings.longBreakDuration.inSeconds;

            final secondsLeft = timer.remainingTime.inSeconds;
            final progress = 1 - (secondsLeft / secondsTotal);

            final minutes = (timer.remainingTime.inMinutes).toString().padLeft(2, '0');
            final seconds = (timer.remainingTime.inSeconds % 60).toString().padLeft(2, '0');

            return Column(
              children: [
                Align(
                  alignment: Alignment.topLeft,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 16.0, left: 16.0),
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.black87),
                      tooltip: 'Voltar',
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                if (timer.currentSubtask != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    margin: const EdgeInsets.symmetric(horizontal: 24),
                    decoration: BoxDecoration(
                      color: Colors.purple.shade50,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      timer.currentSubtask!.title,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.purple,
                      ),
                    ),
                  ),
                const SizedBox(height: 16),
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CustomPaint(
                          painter: _RadialTimerPainter(progress),
                          child: SizedBox(
                            width: 260,
                            height: 260,
                            child: Center(
                              child: Text(
                                "$minutes:$seconds",
                                style: const TextStyle(
                                  fontSize: 36,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF2C2E43),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 40),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            GestureDetector(
                              onTap: () {
                                if (timer.currentState == TimerState.runningFocus ||
                                    timer.currentState == TimerState.runningShortBreak ||
                                    timer.currentState == TimerState.runningLongBreak) {
                                  timer.pauseTimer();
                                } else {
                                  timer.startTimer();
                                }
                              },
                              child: CircleAvatar(
                                radius: 28,
                                backgroundColor: Colors.white,
                                child: Icon(
                                  (timer.currentState == TimerState.runningFocus ||
                                      timer.currentState == TimerState.runningShortBreak ||
                                      timer.currentState == TimerState.runningLongBreak)
                                      ? Icons.pause
                                      : Icons.play_arrow,
                                  color: Colors.purple,
                                  size: 32,
                                ),
                              ),
                            ),
                            const SizedBox(width: 24),
                            GestureDetector(
                              onTap: () => timer.resetTimer(),
                              child: CircleAvatar(
                                radius: 28,
                                backgroundColor: Colors.purple,
                                child: const Icon(Icons.stop, color: Colors.white, size: 28),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _RadialTimerPainter extends CustomPainter {
  final double progress;

  _RadialTimerPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 10;
    const strokeWidth = 10.0;

    final backgroundPaint = Paint()
      ..color = Colors.grey.withOpacity(0.1)
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final progressPaint = Paint()
      ..shader = SweepGradient(
        colors: [Colors.purple, Colors.pinkAccent],
        startAngle: 0.0,
        endAngle: 2 * pi,
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, backgroundPaint);

    final angle = 2 * pi * progress;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi / 2,
      angle,
      false,
      progressPaint,
    );

    final tickPaint = Paint()
      ..color = Colors.grey.shade300
      ..strokeWidth = 2;

    for (int i = 0; i < 60; i++) {
      final double tickAngle = (2 * pi / 60) * i;
      final Offset start = Offset(
        center.dx + (radius - 6) * cos(tickAngle),
        center.dy + (radius - 6) * sin(tickAngle),
      );
      final Offset end = Offset(
        center.dx + radius * cos(tickAngle),
        center.dy + radius * sin(tickAngle),
      );
      canvas.drawLine(start, end, tickPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _RadialTimerPainter oldDelegate) =>
      oldDelegate.progress != progress;
}
