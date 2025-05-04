import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'services/pomodoro_timer.dart';
import 'services/task_manager.dart';
import 'models/timer_settings.dart';
import 'models/task.dart';
import 'models/subtask.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const PomodoroApp());
}

class PomodoroApp extends StatelessWidget {
  const PomodoroApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<TaskManager>(
          create: (_) {
            final manager = TaskManager();
            final uuid = const Uuid();
            final initialSettings = TimerSettings();
            final task = Task(
              id: uuid.v4(),
              title: 'Minha Tarefa Padrão',
              subtasks: [
                Subtask(
                  id: uuid.v4(),
                  title: 'Minha Subtarefa Padrão',
                  timerSettings: initialSettings,
                ),
              ],
            );
            manager.loadInitialTasks([task]);
            return manager;
          },
        ),
        ChangeNotifierProvider<TimerSettings>(
          create: (_) => TimerSettings(),
        ),
        ChangeNotifierProxyProvider<TimerSettings, PomodoroTimer>(
          create: (context) => PomodoroTimer(context.read<TimerSettings>()),
          update: (context, timerSettings, previousTimer) =>
          previousTimer!..updateSettings(timerSettings),
        ),
      ],
      child: MaterialApp(
        title: 'Pomodoro App',
        theme: ThemeData(
          brightness: Brightness.light,
          primarySwatch: Colors.blue,
          colorScheme: ColorScheme.light(
            primary: Colors.blue.shade600,
            secondary: Colors.lightBlue.shade400,
            background: Colors.grey.shade100,
            surface: Colors.white,
            onPrimary: Colors.white,
            onSecondary: Colors.black,
            onBackground: Colors.black87,
            onSurface: Colors.black87,
          ),
          useMaterial3: true,
          textTheme: const TextTheme(
            headlineMedium: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
            bodyMedium: TextStyle(fontSize: 14.0),
          ),
          appBarTheme: AppBarTheme(
            backgroundColor: Colors.blue.shade600,
            foregroundColor: Colors.white,
          ),
        ),
        home: const HomeScreen(),
      ),
    );
  }
}
