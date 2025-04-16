// main.dart
import 'package:flutter/material.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'winterark_home.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:workmanager/workmanager.dart';
import 'background_tasks.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  AwesomeNotifications().initialize(
    null,
    [
      NotificationChannel(
        channelKey: 'workout_reminder',
        channelName: 'Workout Reminders',
        channelDescription: 'Reminders for scheduled workouts',
        defaultColor: Colors.blue,
        ledColor: Colors.white,
        importance: NotificationImportance.High,
        playSound: true,
        enableVibration: true,
      ),
      NotificationChannel(
        channelKey: 'roast_notifications',
        channelName: 'Roast Notifications',
        channelDescription: 'Channel for roast notifications when a planned workout is missed',
        defaultColor: Colors.red,
        ledColor: Colors.white,
        importance: NotificationImportance.High,
      ),
    ],
    debug: true,
  );

  tz.initializeTimeZones();
  Workmanager().initialize(callbackDispatcher, isInDebugMode: false);
  runApp(const WinterArkApp());
}

class WinterArkApp extends StatelessWidget {
  const WinterArkApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'WinterArk',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: Colors.black,
        primaryColor: Colors.blueAccent,
      ),
      home: const WinterArkHome(),
    );
  }
}
