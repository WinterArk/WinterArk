// lib/roast_notifications_settings_page.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RoastNotificationsSettingsPage extends StatefulWidget {
  const RoastNotificationsSettingsPage({Key? key}) : super(key: key);

  @override
  _RoastNotificationsSettingsPageState createState() => _RoastNotificationsSettingsPageState();
}

class _RoastNotificationsSettingsPageState extends State<RoastNotificationsSettingsPage> {
  bool roastEnabled = false;
  double roastIntensity = 0.5; 

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      roastEnabled = prefs.getBool('roastNotifications') ?? false;
      roastIntensity = prefs.getDouble('roastIntensity') ?? 0.5;
    });
  }

  Future<void> _updateSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('roastNotifications', roastEnabled);
    await prefs.setDouble('roastIntensity', roastIntensity);
  }

  void _enableRoastNotifications() {
    setState(() {
      roastEnabled = true;
    });
    _updateSettings();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Roast Notifications Settings"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text("Enable Roast Notifications"),
              value: roastEnabled,
              onChanged: (value) {
                _enableRoastNotifications();
                setState(() {
                  roastEnabled = value;
                });
                _updateSettings();
              },
            ),
            const SizedBox(height: 16),
            Text("Roast Intensity: ${ (roastIntensity * 100).toInt() }", style: const TextStyle(fontWeight: FontWeight.bold)),
            Slider(
              value: roastIntensity,
              onChanged: (newValue) {
                setState(() {
                  roastIntensity = newValue;
                });
                _updateSettings();
              },
              min: 0.0,
              max: 1.0,
              divisions: 10,
              label: (roastIntensity * 100).toInt().toString(),
            ),
          ],
        ),
      ),
    );
  }
}
