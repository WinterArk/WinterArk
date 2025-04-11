// main.dart
import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:timezone/data/latest.dart' as tz;

import 'firebase_options.dart';
import 'notification_service.dart';
import 'winterark_home.dart';
import 'global_state.dart' as globals;

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print('🔄 Background message: ${message.messageId}');
}

const String backendBaseUrl = 'http://10.0.0.116:3000';

Future<String?> getCurrentUserId() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString('currentUserId'); // ✅ Must match what login_screen.dart saves
}


Future<void> sendTokenToBackend(String token) async {
  final userId = await getCurrentUserId();
  if (userId == null || token.isEmpty) {
    print('⚠️ Cannot send token: missing userId or token');
    return;
  }

  final uri = Uri.parse('$backendBaseUrl/api/users/$userId/device-token');

  try {
    final resp = await http.put(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'deviceToken': token}),
    ).timeout(const Duration(seconds: 5));

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
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  final settings = await FirebaseMessaging.instance.requestPermission();
  print('🔔 Permission status: ${settings.authorizationStatus}');

  tz.initializeTimeZones();
  await initializeNotifications();

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  final token = await FirebaseMessaging.instance.getToken();
  if (token != null) {
    print('📲 Initial FCM Token: $token');
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
