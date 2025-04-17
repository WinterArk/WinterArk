// lib/notification_settings.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:android_intent_plus/android_intent.dart';

// ──────────────────────────────────────────────────────────────
// Prefix‑import the helpers so the analyzer can find them.
import 'package:winterark/notification_service.dart' as notify;
// ──────────────────────────────────────────────────────────────

// Opens Android’s exact‑alarm permission page for this app
void openExactAlarmSettings() {
  const intent = AndroidIntent(
    action: 'android.settings.REQUEST_SCHEDULE_EXACT_ALARM',
    package: 'com.example.winterark',
  );
  intent.launch();
}

class NotificationSettingsPage extends StatefulWidget {
  const NotificationSettingsPage({super.key});

  @override
  State<NotificationSettingsPage> createState() =>
      _NotificationSettingsPageState();
}

class _NotificationSettingsPageState extends State<NotificationSettingsPage> {
  bool workoutReminders = false;
  bool roastNotifications = false;

  @override
  void initState() {
    super.initState();
    tz.initializeTimeZones();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      workoutReminders = prefs.getBool('workoutReminders') ?? false;
      roastNotifications = prefs.getBool('roastNotifications') ?? false;
    });
  }

  Future<void> _updateSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('workoutReminders', workoutReminders);
    await prefs.setBool('roastNotifications', roastNotifications);
  }

  Future<void> _pickWorkoutReminderTime() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (pickedDate == null) return;

    final pickedTime =
    await showTimePicker(context: context, initialTime: TimeOfDay.now());
    if (pickedTime == null) return;

    final workoutDateTime = DateTime(
      pickedDate.year,
      pickedDate.month,
      pickedDate.day,
      pickedTime.hour,
      pickedTime.minute,
    );

    await notify.scheduleWorkoutReminder(workoutDateTime, 'Chest');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Workout reminder scheduled.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Notification Settings')),
      body: ListView(
        children: [
          SwitchListTile(
            title: const Text('Workout Reminders'),
            value: workoutReminders,
            onChanged: (v) {
              setState(() => workoutReminders = v);
              _updateSettings();
            },
          ),
          SwitchListTile(
            title: const Text('Roast Notifications'),
            value: roastNotifications,
            onChanged: (v) {
              setState(() => roastNotifications = v);
              _updateSettings();
            },
          ),
          ListTile(
            title: const Text('Schedule Workout Reminder'),
            onTap: _pickWorkoutReminderTime,
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: ElevatedButton(
              onPressed: () {
                notify.showImmediateReminder('Chest');
              },
              child: const Text('Test Workout Reminder Now'),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: ElevatedButton(
              onPressed: () {
                notify.showChatNotification(
                  title: 'Test Chat Notification',
                  body: 'This is a test chat notification.',
                  payload: 'test_chat_payload',
                );
              },
              child: const Text('Test Chat Notification'),
            ),
          ),
          ListTile(
            title: const Text('Exact Alarm Permission'),
            subtitle: const Text('Allow app to schedule exact alarms'),
            trailing: ElevatedButton(
              onPressed: openExactAlarmSettings,
              child: const Text('Open Settings'),
            ),
          ),
        ],
      ),
    );
  }
}