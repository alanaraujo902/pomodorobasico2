import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/timer_settings.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late TextEditingController _focusController;
  late TextEditingController _shortBreakController;
  late TextEditingController _longBreakController;
  late TextEditingController _roundsController;

  @override
  void initState() {
    super.initState();
    final timerSettings = Provider.of<TimerSettings>(context, listen: false);
    _focusController = TextEditingController(text: timerSettings.focusDuration.inMinutes.toString());
    _shortBreakController = TextEditingController(text: timerSettings.shortBreakDuration.inMinutes.toString());
    _longBreakController = TextEditingController(text: timerSettings.longBreakDuration.inMinutes.toString());
    _roundsController = TextEditingController(text: timerSettings.roundsBeforeLongBreak.toString());
  }

  @override
  void dispose() {
    _focusController.dispose();
    _shortBreakController.dispose();
    _longBreakController.dispose();
    _roundsController.dispose();
    super.dispose();
  }

  void _saveSettings() {
    final timerSettings = Provider.of<TimerSettings>(context, listen: false);
    final focusMinutes = int.tryParse(_focusController.text) ?? timerSettings.focusDuration.inMinutes;
    final shortBreakMinutes = int.tryParse(_shortBreakController.text) ?? timerSettings.shortBreakDuration.inMinutes;
    final longBreakMinutes = int.tryParse(_longBreakController.text) ?? timerSettings.longBreakDuration.inMinutes;
    final rounds = int.tryParse(_roundsController.text) ?? timerSettings.roundsBeforeLongBreak;

    timerSettings.update(
      focusDuration: Duration(minutes: focusMinutes),
      shortBreakDuration: Duration(minutes: shortBreakMinutes),
      longBreakDuration: Duration(minutes: longBreakMinutes),
      roundsBeforeLongBreak: rounds,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Settings saved!')),
    );

    Navigator.pop(context); // Go back after saving
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            Text('Timer Durations (minutes)', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            _buildDurationField(
              controller: _focusController,
              label: 'Focus Duration',
            ),
            _buildDurationField(
              controller: _shortBreakController,
              label: 'Short Break Duration',
            ),
            _buildDurationField(
              controller: _longBreakController,
              label: 'Long Break Duration',
            ),
            const SizedBox(height: 24),
            Text('Pomodoro Rounds', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            _buildDurationField(
              controller: _roundsController,
              label: 'Rounds before Long Break',
              isRound: true,
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _saveSettings,
              child: const Text('Save Settings'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDurationField({
    required TextEditingController controller,
    required String label,
    bool isRound = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          suffixText: isRound ? '' : 'minutes',
        ),
        keyboardType: TextInputType.number,
      ),
    );
  }
}
