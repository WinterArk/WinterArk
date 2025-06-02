// lib/notification_settings.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:android_intent_plus/android_intent.dart';
import 'button_effects/ui_helpers.dart';
import 'button_effects/neon_toggle.dart';
import 'button_effects/neon_button_ontap.dart';
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
  bool showExplicitRoasts = false;

  @override
  void initState() {
    super.initState();
    tz.initializeTimeZones();
    _loadSettings();
    _loadPrefs();
  }

  Future<void> _loadPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      showExplicitRoasts = prefs.getBool('showExplicitRoasts') ?? false;
    });
  }

  Future<void> _updatePrefs(bool v) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('showExplicitRoasts', v);
    setState(() => showExplicitRoasts = v);
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
    showShortFadeSnack(context, 'Workout reminder scheduled.');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(width: 8),
            Text(
              "Notification Settings",
              style: glowingTextStyle(
                Colors.white,
                size: 26,
              ),
            ),
          ],
        ),
        backgroundColor: Colors.black,
        centerTitle: true,
        leading: IconButton(
          icon: glowingIcon(Icons.arrow_back, Colors.white, 24),
          onPressed: () => Navigator.of(context).maybePop(),
          tooltip: 'Back',
        ),
      ),
      body: ListView(
        children: [
          ListTile(
            title: const Text('Exact Alarm Permission'),
            subtitle: const Text('Allow app to schedule exact alarms'),
            trailing: NeonButton(
              label: 'Open Settings',
              glowColor: Colors.red,
              backgroundColor: Colors.black,
              onTap: openExactAlarmSettings,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Allow explicit roasts',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Enable the roast intensity that includes swearing',
                        style: TextStyle(
                          color: Colors.grey[500],
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                NeonToggle(
                  label: '',
                  value: showExplicitRoasts,
                  glowColor: Colors.red,
                  activeColor: Colors.red,
                  inactiveTrackColor: Colors.black,
                  onChanged: (v) {
                    _updatePrefs(v);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
