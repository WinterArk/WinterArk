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
import 'dart:typed_data';

// Notification packages:
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:workmanager/workmanager.dart';

// Your own files:
import 'firebase_options.dart';
import 'notification_service.dart';
import 'winterark_home.dart';
import 'background_tasks.dart';

// Global state (for example, activeChatId) used by chat notifications.
import 'global_state.dart' as globals;

//
// Firebase background message handler.
//
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print('🔄 Background message: ${message.messageId}');
}

//
// Backend base URL and helper functions for token handling.
//
const String backendBaseUrl = 'http://18.234.214.233:3000';

Future<String?> getCurrentUserId() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString('currentUserId'); // Must match what login_screen.dart saves
}

Future<void> sendTokenToBackend(String token) async {
  final userId = await getCurrentUserId();
  if (userId == null || token.isEmpty) {
    print('⚠️ Cannot send token: missing userId or token');
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
      print('✅ Token uploaded');
    } else {
      print('❌ Upload failed: ${resp.statusCode} - ${resp.body}');
    }
  } catch (e) {
    print('❌ Network error while uploading token: $e');
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase.
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  
  // Request FCM permissions.
  final settings = await FirebaseMessaging.instance.requestPermission();
  print('🔔 Permission status: ${settings.authorizationStatus}');
  
  // Initialize timezone data.
  tz.initializeTimeZones();
  
  // Initialize your local notifications service (if needed).
  await initializeNotifications();
  
  // Initialize Awesome Notifications with the desired channels.
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
  
  // Initialize Workmanager for background tasks (e.g., roast notifications).
  Workmanager().initialize(callbackDispatcher, isInDebugMode: false);
  
  // Set up Firebase Messaging background handler.
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  
  // Get initial FCM token and send it to backend.
  final token = await FirebaseMessaging.instance.getToken();
  if (token != null) {
    print('📲 Initial FCM Token: $token');
    unawaited(sendTokenToBackend(token));
  }
  FirebaseMessaging.instance.onTokenRefresh.listen(sendTokenToBackend);
  
  // Listen for foreground FCM messages.
  FirebaseMessaging.onMessage.listen((RemoteMessage m) {
    final chatId = m.data['chatId'] ?? '';
    final title = m.notification?.title ?? 'New message';
    final body = m.notification?.body ?? 'You have a new message';
  
    // Only show chat notification if not already in that chat.
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