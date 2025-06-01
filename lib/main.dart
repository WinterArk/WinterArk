// main.dart
import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';

// Firebase packages:
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

// HTTP & SharedPreferences:
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

// Timezone package:
import 'package:timezone/data/latest.dart' as tz;

// Notification packages:
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:workmanager/workmanager.dart';

import 'firebase_options.dart';
import 'notification_service.dart';
import 'winterark_home.dart';
import 'background_tasks.dart';

import 'global_state.dart' as globals;


Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print('Background message: ${message.messageId}');
}


const String backendBaseUrl = 'http://18.234.214.233:3000';

Future<String?> getCurrentUserId() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString('currentUserId');
}

Future<void> sendTokenToBackend(String token) async {
  final userId = await getCurrentUserId();
  if (userId == null || token.isEmpty) {
    print('Cannot send token: missing userId or token');
    return;
  }
  final uri = Uri.parse('$backendBaseUrl/api/users/$userId/device-token');
  try {
    final resp = await http
        .put(
          uri,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'deviceToken': token}),
        )
        .timeout(const Duration(seconds: 5));
    if (resp.statusCode == 200) {
      print('Token uploaded');
    } else {
      print('Upload failed: ${resp.statusCode} - ${resp.body}');
    }
  } catch (e) {
    print('Network error while uploading token: $e');
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  final settings = await FirebaseMessaging.instance.requestPermission();
  print('Permission status: ${settings.authorizationStatus}');

  tz.initializeTimeZones();

  await initializeNotifications();

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
    debug: true,
  );

  final allowed = await AwesomeNotifications().isNotificationAllowed();
  if (!allowed) {
    AwesomeNotifications().requestPermissionToSendNotifications();
  }

  Workmanager().initialize(callbackDispatcher, isInDebugMode: false);

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  final token = await FirebaseMessaging.instance.getToken();
  if (token != null) {
    print('Initial FCM Token: $token');
    unawaited(sendTokenToBackend(token));
  }
  FirebaseMessaging.instance.onTokenRefresh.listen(sendTokenToBackend);

  FirebaseMessaging.onMessage.listen((RemoteMessage m) {
    final chatId = m.data['chatId'] ?? '';
    final title = m.notification?.title ?? 'New message';
    final body = m.notification?.body ?? 'You have a new message';

    if (globals.activeChatId == null || globals.activeChatId != chatId) {
      showChatNotification(title: title, body: body, payload: chatId);
    }
  });
  
  runApp(const WinterArkApp());
}

final blueGrotto = const Color.fromARGB(255, 45, 178, 250); 
final aquamarine = const Color.fromARGB(255, 167, 223, 248); 
final babyBlue   = const Color.fromARGB(255, 212, 242, 255);

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