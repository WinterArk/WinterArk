import 'dart:math';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:workmanager/workmanager.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:intl/intl.dart';
import 'api_service.dart';
import 'package:timezone/data/latest.dart' as tz;

// Returns a random roast message based on a randomly chosen muscle group
String getRandomRoastMessage(List<String>? muscleGroups) {
  Map<String, List<String>> roastMessages = {
    'legs': [
      "Of course you skipped legs, Mr. Chicken Legger!",
      "Leg day? More like nap day—no leg gains here!",
      "Skipping leg day again? Those chicken legs won't cut it!",
      "Legs are the foundation, but you just couldn't build one!"
    ],
    'chest': [
      "Didn't hit chest? Looks like a pancake to me!",
      "Your chest is so flat, I mistook it for a board!",
      "Skipping chest day means no push-ups—except if you're pushing your luck!",
      "Chest day? More like rest day—where's the pump?"
    ],
    'arms': [
      "Arm day? More like no arms day!",
      "Your arms are so soft, they might as well be made of jelly!",
      "Skipping arms won't make you strong—try lifting some dumbbells!",
      "No curls? Your biceps are crying out for help!"
    ],
    'back': [
      "Back day is important—oops, you missed it again!",
      "An empty back equals no pull-ups—time to pull your weight!",
      "Your back is as empty as your promise to work out!",
      "Skipping back day? You'll be leaning on excuses all day!"
    ],
    'shoulders': [
      "Shoulders are for power—guess you're all weak today!",
      "No shoulder workout? That's like trying to carry the world with no support!",
      "Skipping shoulders? Your arms are doomed to carry all the load!",
      "Your shoulder strength is as missing as your motivation!"
    ],
    'core': [
      "Your core is so weak, it might as well be cardboard!",
      "No core workout means no abs—you might as well be flat!",
      "Skipping core day? That’s a recipe for a wobbly midsection!",
      "Your abs are taking a vacation if you skip core workouts!"
    ],
  };

  // If muscle groups are provided and not empty, pick one randomly
  if (muscleGroups != null && muscleGroups.isNotEmpty) {
    final random = Random();
    String chosenGroup = muscleGroups[random.nextInt(muscleGroups.length)].toLowerCase();
    final messages = roastMessages[chosenGroup] ?? ['You skipped your workout, pathetic!'];
    return messages[random.nextInt(messages.length)];
  } else {
    return 'You skipped your workout, pathetic!';
  }
}

void callbackDispatcher() {
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
      // Query the API to fetch workouts logged for the day of the planned workout
      List<dynamic> workouts = await ApiService.getWorkoutsForDay(userId, dateKey);
      // If no workout was logged for that day, schedule a roast notification
      if (workouts.isEmpty) {
        String roastMessage = getRandomRoastMessage(plannedMuscleGroups);
        await AwesomeNotifications().createNotification(
          content: NotificationContent(
            id: 200,
            channelKey: 'roast_notifications',
            title: 'You Missed Your $plannedWorkoutName Workout!',
            body: roastMessage,
            notificationLayout: NotificationLayout.Default,
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