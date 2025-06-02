// lib/notification_service.dart
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;


const AndroidNotificationChannel chatChannel = AndroidNotificationChannel(
  'chat_message_channel',
  'Chat Messages',
  description: 'Notifications for chat messages',
  importance: Importance.max,
);

const AndroidNotificationChannel workoutChannel = AndroidNotificationChannel(
  'workout_reminder_channel',
  'Workout Reminders',
  description: 'Reminders for scheduled workouts',
  importance: Importance.max,
);

final FlutterLocalNotificationsPlugin notificationsPlugin =
    FlutterLocalNotificationsPlugin();

Future<void> initializeNotifications() async {
  const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
  const initSettings = InitializationSettings(android: androidInit);

  await notificationsPlugin.initialize(initSettings);

  // Explicitly create the two channels on Android
  final android = notificationsPlugin.resolvePlatformSpecificImplementation<
      AndroidFlutterLocalNotificationsPlugin>();

  await android?.createNotificationChannel(chatChannel);
  await android?.createNotificationChannel(workoutChannel);
}

Future<void> showChatNotification({
  required String title,
  required String body,
  String? payload,
}) async {
  await notificationsPlugin.show(
    1,
    title,
    body,
    NotificationDetails(
      android: AndroidNotificationDetails(
        chatChannel.id,
        chatChannel.name,
        channelDescription: chatChannel.description,
        importance: Importance.max,
        priority: Priority.high,
      ),
    ),
    payload: payload,
  );
}

Future<void> scheduleWorkoutReminder(
  DateTime workoutDateTime,
  String muscleGroup,
) async {
  final now = tz.TZDateTime.now(tz.local);
  final reminderTime = workoutDateTime.subtract(const Duration(seconds: 10));
  final scheduledDate = tz.TZDateTime.from(reminderTime, tz.local);

  if (scheduledDate.isBefore(now)) {
    print('scheduleWorkoutReminder: chosen time is in the past – skipping.');
    return;
  }

  await notificationsPlugin.zonedSchedule(
    0,
    'Workout Reminder',
    'Your workout for $muscleGroup starts soon!',
    scheduledDate,
    NotificationDetails(
      android: AndroidNotificationDetails(
        workoutChannel.id,
        workoutChannel.name,
        channelDescription: workoutChannel.description,
        importance: Importance.max,
        priority: Priority.high,
      ),
    ),
    androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    matchDateTimeComponents: DateTimeComponents.dateAndTime,
    payload: 'WorkoutReminder',
  );
}

Future<void> showImmediateReminder(String muscleGroup) async {
  await notificationsPlugin.show(
    0,
    'Workout Reminder',
    'Your workout for $muscleGroup starts now!',
    NotificationDetails(
      android: AndroidNotificationDetails(
        workoutChannel.id,
        workoutChannel.name,
        channelDescription: workoutChannel.description,
        importance: Importance.max,
        priority: Priority.high,
      ),
    ),
    payload: 'WorkoutReminder',
  );
}
