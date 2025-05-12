import 'dart:math';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:workmanager/workmanager.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:intl/intl.dart';
import 'api_service.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:flutter/material.dart';
import 'dart:typed_data';
import 'dart:convert';
import 'package:flutter/services.dart';

class _RoastLoader {
  static Map<String, dynamic>? _cache;
  static Future<Map<String, dynamic>> load() async {
    if (_cache != null) return _cache!;
    final raw = await rootBundle.loadString('assets/roasts.json');
    _cache = json.decode(raw) as Map<String, dynamic>;
    return _cache!;
  }
}
// Returns a random roast message based on a randomly chosen muscle group
Future<String> getRandomRoastMessage(
  List<String>? muscleGroups,
  String selectedDifficulty,
) async {
  
  final roastByLevel = await _RoastLoader.load();
  final levelMap = (roastByLevel[selectedDifficulty]
      ?? roastByLevel['Soft Serve Roasts 🍦😋']) as Map<String, dynamic>;
  final rnd = Random();
  if (muscleGroups == null || muscleGroups.isEmpty) {
    return 'You skipped your workout, pathetic!';
  }

  List<dynamic> messages;
  if (muscleGroups != null && muscleGroups.isNotEmpty) {
    final chosenMuscle = muscleGroups[rnd.nextInt(muscleGroups.length)].toLowerCase();
    messages = (levelMap[chosenMuscle] as List<dynamic>?)
        ?? levelMap.values.expand((l) => (l as List).cast<dynamic>()).toList();
  } else {
    messages = levelMap.values.expand((l) => (l as List).cast<dynamic>()).toList();
  }
  return messages[rnd.nextInt(messages.length)] as String;
}
void callbackDispatcher() {
   AwesomeNotifications().initialize(
    null,
    [
      NotificationChannel(
        channelKey: 'workout_reminder',
        channelName: 'Workout Reminders',
        channelDescription: 'Reminders for scheduled workouts',
        defaultColor: Color(0xFF00BFFF),   
        ledColor: Color(0xFF00BFFF),
        importance: NotificationImportance.High,
        enableLights: true,
        channelShowBadge: true,
        playSound: true,
        enableVibration: true,
      ),
      NotificationChannel(
        channelKey: 'roast_notifications',
        channelName: 'Roast Notifications',
        channelDescription:
            'Channel for roast notifications when a planned workout is missed',
        defaultColor: Color(0xFF1E1E1E),
        ledColor: Colors.deepOrange,
        importance: NotificationImportance.High,
        enableLights: true,
        channelShowBadge: true,
        playSound: true,
        enableVibration: true,
      ),
    ],
  );

  Workmanager().executeTask((task, inputData) async {
    tz.initializeTimeZones();
    print("Local timezone: ${tz.local.name}");
    final prefs = await SharedPreferences.getInstance();

    bool roastEnabled = prefs.getBool('roastNotifications') ?? false;
    if (!roastEnabled) {
      return Future.value(true);
    }

    String? userId = prefs.getString('userId');
    if (userId == null) {
      return Future.value(true);
    }

    List<String>? plannedMuscleGroups = prefs.getStringList('plannedMuscleGroups');
    String? roastLevel = prefs.getString('roastLevel') ?? 'Soft Serve Roasts 🍦😋';
    String? plannedWorkoutDateStr = prefs.getString('plannedWorkoutDate');
    String? plannedWorkoutName = prefs.getString('plannedWorkoutName');

    DateTime plannedWorkoutDate;
    if (plannedWorkoutDateStr != null) {
      try {
        plannedWorkoutDate = DateTime.parse(plannedWorkoutDateStr);
      } catch (e) {
        plannedWorkoutDate = DateTime.now();
      }
    } else {
      plannedWorkoutDate = DateTime.now();
    }

    // For testing, we want the roast notification to fire 1 minute after the planned workout date
    // For production, use 24 hours
    final Duration delayDuration = const Duration(hours: 24);
    DateTime scheduledDate = plannedWorkoutDate.add(delayDuration);

    final DateTime now = DateTime.now();
    if (!scheduledDate.isAfter(now)) {
      scheduledDate = now.add(delayDuration);
    }

    String dateKey = DateFormat('yyyy-MM-dd').format(plannedWorkoutDate);
    final notificationSchedule = NotificationCalendar(
      year: scheduledDate.year,
      month: scheduledDate.month,
      day: scheduledDate.day,
      hour: scheduledDate.hour,
      minute: scheduledDate.minute,
      second: scheduledDate.second,
      millisecond: 0,
      repeats: false,
      timeZone: 'America/Los_Angeles',
    );

    try {
      List<dynamic> workouts = await ApiService.getWorkoutsForDay(userId, dateKey);
      if (workouts.isEmpty) {
        final roastMessage = await getRandomRoastMessage(plannedMuscleGroups, roastLevel);
        await AwesomeNotifications().createNotification(
          content: NotificationContent(
            id: 200,
            channelKey: 'roast_notifications',
            title: '🔥 You Missed Your $plannedWorkoutName Workout!',
            body: roastMessage,
            notificationLayout: NotificationLayout.BigText, 
            color: Colors.deepOrangeAccent,  
            autoDismissible: true,
            displayOnBackground: true,
            displayOnForeground: true, 
          ),
          schedule: notificationSchedule
        );
      }
      else{
        print("Workouts logged for the day: $workouts");
      }
    } catch (error) {
      print("Error in callbackDispatcher: $error");
    }
    return Future.value(true);
  });
}