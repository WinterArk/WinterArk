// api_service.dart
// ignore_for_file: constant_identifier_names

import 'package:http/http.dart' as http;
import 'dart:convert';

class ApiService {
  // static const String BASE_URL = 'http://18.234.214.233:3000';
  static const String BASE_URL = 'http://18.234.214.233:3000';

  // 1) SIGN UP a new user
  static Future<Map<String, dynamic>> signUp(
      String name,
      String username,
      String email,
      String password,
      ) async {
    final url = Uri.parse('$BASE_URL/api/users/register');
    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: json.encode({
        "name": name,
        "username": username,
        "email": email,
        "password": password,
      }),
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      return json.decode(response.body) as Map<String, dynamic>;
    }
    throw Exception('Failed to sign up: ${response.body}');
  }

  // 2) SIGN IN an existing user
  static Future<Map<String, dynamic>> signIn(
      String identifier,
      String password,
      ) async {
    final url = Uri.parse('$BASE_URL/api/users/login');
    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: json.encode({
        "identifier": identifier,
        "password": password,
      }),
    );
    if (response.statusCode == 200) {
      return json.decode(response.body) as Map<String, dynamic>;
    }
    throw Exception('Failed to sign in: ${response.body}');
  }

  // 3) VERIFY user account
  static Future<Map<String, dynamic>> verify(
      String email,
      String code,
      ) async {
    final url = Uri.parse('$BASE_URL/api/users/verify');
    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: json.encode({"email": email, "code": code}),
    );
    if (response.statusCode == 200) {
      return json.decode(response.body) as Map<String, dynamic>;
    }
    throw Exception('Verification failed: ${response.body}');
  }

  // 4) RESEND verification email
  static Future<Map<String, dynamic>> resendVerification(
      String email,
      ) async {
    final url = Uri.parse('$BASE_URL/api/users/resend-verification');
    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: json.encode({"email": email}),
    );
    if (response.statusCode == 200) {
      return json.decode(response.body) as Map<String, dynamic>;
    }
    throw Exception('Failed to resend verification email: ${response.body}');
  }

  // 5) SEARCH users
  static Future<List<dynamic>> searchUsers(
      String query,
      String filter,
      ) async {
    final url = Uri.parse('$BASE_URL/api/users/search?query=$query&filter=$filter');
    final response = await http.get(
      url,
      headers: {"Content-Type": "application/json"},
    );
    if (response.statusCode == 200) {
      return json.decode(response.body) as List<dynamic>;
    }
    throw Exception('Failed to search users: ${response.body}');
  }

  // 6) ADD gym buddy
  static Future<Map<String, dynamic>> addGymBuddy(
      String userId,
      String buddyId,
      ) async {
    final url = Uri.parse('$BASE_URL/api/gymbuddies');
    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: json.encode({"userId": userId, "buddyId": buddyId}),
    );
    if (response.statusCode == 201) {
      return json.decode(response.body) as Map<String, dynamic>;
    }
    throw Exception('Failed to add gym buddy: ${response.body}');
  }

  // 7) FETCH a user's gym buddies
  static Future<List<dynamic>> fetchUserBuddies(
      String userId,
      ) async {
    final url = Uri.parse('$BASE_URL/api/gymbuddies/$userId');
    final response = await http.get(
      url,
      headers: {"Content-Type": "application/json"},
    );
    if (response.statusCode == 200) {
      return json.decode(response.body) as List<dynamic>;
    }
    throw Exception('Failed to fetch buddies: ${response.body}');
  }

  // 8) UPDATE buddy status (accept/decline)
  static Future<Map<String, dynamic>> updateBuddyStatus(
      String docId,
      String newStatus,
      ) async {
    final url = Uri.parse('$BASE_URL/api/gymbuddies/$docId');
    final response = await http.patch(
      url,
      headers: {"Content-Type": "application/json"},
      body: json.encode({"status": newStatus}),
    );
    if (response.statusCode == 200) {
      return json.decode(response.body) as Map<String, dynamic>;
    }
    throw Exception('Failed to update buddy status: ${response.body}');
  }

  // 9) ADD WORKOUT
  static Future<Map<String, dynamic>> addWorkout({
  required String userId,
  required String exerciseName,
  required String exerciseType,
  required int sets,
  required int reps,
  required double weight,
  required String weightUnit,
  DateTime? date,
  String? notes,
  String? trainingStyle,
  }) async {
  final url = Uri.parse('$BASE_URL/api/workouts/add');
  final response = await http.post(
  url,
  headers: {"Content-Type": "application/json"},
  body: json.encode({
  "user_id": userId,
  "exercise_name": exerciseName,
  "exercise_type": exerciseType.toLowerCase(),
  "sets": sets,
  "reps": reps,
  "weight": weight,
  "weightUnit": weightUnit,
  "date": date?.toIso8601String(),
  "notes": notes,
  "training_style": trainingStyle,
  }),
  );
  if (response.statusCode == 200 || response.statusCode == 201) {
  return json.decode(response.body);
  } else {
  throw Exception("Failed to add workout: ${response.body}");
  }
  }

  // 10) Get workouts for a specific day for a given user
  static Future<List<dynamic>> getWorkoutsForDay(
  String userId, String date) async {
  final url = Uri.parse('$BASE_URL/api/workouts/day/$userId?date=$date');
  final response = await http.get(
  url,
  headers: {"Content-Type": "application/json"},
  );

  if (response.statusCode == 200) {
  return json.decode(response.body);
  } else {
  throw Exception('Failed to fetch workouts for day: ${response.body}');
  }
  }

  // 11) Update a workout
  static Future<Map<String, dynamic>> updateWorkout(
  String workoutId, Map<String, dynamic> updateData) async {
  final url = Uri.parse('$BASE_URL/api/workouts/$workoutId');
  final response = await http.put(
  url,
  headers: {"Content-Type": "application/json"},
  body: json.encode(updateData),
  );
  if (response.statusCode == 200) {
  return json.decode(response.body);
  } else {
  throw Exception("Failed to update workout: ${response.body}");
  }
  }

  // 12) Delete a workout
  static Future<Map<String, dynamic>> deleteWorkout(String workoutId) async {
  final url = Uri.parse('$BASE_URL/api/workouts/$workoutId');
  final response = await http.delete(
  url,
  headers: {"Content-Type": "application/json"},
  );
  if (response.statusCode == 200) {
  return json.decode(response.body);
  } else {
  throw Exception("Failed to delete workout: ${response.body}");
  }
  }

  // 12.5) Get past workouts for a user
  static Future<List<dynamic>> getPastWorkouts(String userId) async {
  final url = Uri.parse('$BASE_URL/api/workouts/$userId');
  final response = await http.get(url, headers: {"Content-Type": "application/json"});
  if (response.statusCode == 200) {
  return json.decode(response.body);
  } else {
  throw Exception('Failed to fetch workouts: ${response.body}');
  }
  }

  // 13) Create or retrieve a chat between two users
  static Future<Map<String, dynamic>> createChat(
  String userId1, String userId2) async {
  final url = Uri.parse('$BASE_URL/api/chat');
  final response = await http.post(
  url,
  headers: {"Content-Type": "application/json"},
  body: json.encode({"participants": [userId1, userId2]}),
  );
  if (response.statusCode == 200 || response.statusCode == 201) {
  return json.decode(response.body);
  } else {
  throw Exception('Failed to create chat: ${response.body}');
  }
  }

  // 14) Get messages for a chat
  static Future<List<dynamic>> getMessages(String chatId) async {
  final url = Uri.parse('$BASE_URL/api/chat/$chatId/messages');
  final response =
  await http.get(url, headers: {"Content-Type": "application/json"});
  if (response.statusCode == 200) {
  return json.decode(response.body);
  } else {
  throw Exception('Failed to get messages: ${response.body}');
  }
  }

  // 15) Send a message in a chat
  static Future<Map<String, dynamic>> sendMessage(String chatId, String senderId,
  String content, {List<String>? attachments}) async {
  final url = Uri.parse('$BASE_URL/api/chat/$chatId/message');
  final response = await http.post(
  url,
  headers: {"Content-Type": "application/json"},
  body: json.encode({
  "senderId": senderId,
  "content": content,
  "attachments": attachments ?? []
  }),
  );
  if (response.statusCode == 201) {
  return json.decode(response.body);
  } else {
  throw Exception('Failed to send message: ${response.body}');
  }
  }

  // 16) Mark a message as read
  static Future<Map<String, dynamic>> markMessageAsRead(
  String chatId, String messageId) async {
  final url = Uri.parse('$BASE_URL/api/chat/$chatId/message/$messageId/read');
  final response =
  await http.patch(url, headers: {"Content-Type": "application/json"});
  if (response.statusCode == 200) {
  return json.decode(response.body);
  } else {
  throw Exception('Failed to mark message as read: ${response.body}');
  }
  }

  // 17) Get unread count for a chat for the current user
  static Future<int> getUnreadCount(String chatId, String currentUserId) async {
  final url = Uri.parse('$BASE_URL/api/chat/$chatId/unread_count?currentUserId=$currentUserId');
  final response =
  await http.get(url, headers: {"Content-Type": "application/json"});
  if (response.statusCode == 200) {
  final data = json.decode(response.body);
  return data['unread_count'] as int;
  } else {
  throw Exception('Failed to get unread count: ${response.body}');
  }
  }

  // 18) CREATE a new post (for Shared Dashboard)
    static Future<Map<String, dynamic>> createPost (
        String userId, {
        String? description,
        String? workoutId,
    }) async {
  final url = Uri.parse('$BASE_URL/api/posts');
  final response = await http.post(
  url,
  headers: {"Content-Type": "application/json"},
            body: json.encode({
          "userId": userId,
          if (description != null && description.isNotEmpty)
            "description": description,
          if (workoutId != null) "workoutId": workoutId,
        }),
  );
  if (response.statusCode == 201) {
  return json.decode(response.body);
  } else {
  throw Exception('Failed to create post: ${response.body}');
  }
  }

  // 19) FETCH posts for Shared Dashboard
  static Future<List<dynamic>> fetchPosts() async {
  final url = Uri.parse('$BASE_URL/api/posts');
  final response = await http.get(url, headers: {"Content-Type": "application/json"});
  if (response.statusCode == 200) {
  return json.decode(response.body);
  } else {
  throw Exception('Failed to fetch posts: ${response.body}');
  }
  }

  // 20) Like a post
  static Future<Map<String, dynamic>> likePost(String postId, String userId) async {
  final url = Uri.parse('$BASE_URL/api/posts/$postId/like');
  final response = await http.post(
  url,
  headers: {"Content-Type": "application/json"},
  body: json.encode({"userId": userId}),
  );
  if (response.statusCode == 200) {
  return json.decode(response.body);
  } else {
  throw Exception('Failed to like post: ${response.body}');
  }
  }

  // 21) Dislike a post
  static Future<Map<String, dynamic>> dislikePost(String postId, String userId) async {
  final url = Uri.parse('$BASE_URL/api/posts/$postId/dislike');
  final response = await http.post(
  url,
  headers: {"Content-Type": "application/json"},
  body: json.encode({"userId": userId}),
  );
  if (response.statusCode == 200) {
  return json.decode(response.body);
  } else {
  throw Exception('Failed to dislike post: ${response.body}');
  }
  }

  // 22) Comment on a post
  static Future<Map<String, dynamic>> commentOnPost(String postId, String userId, String text) async {
  final url = Uri.parse('$BASE_URL/api/posts/$postId/comment');
  final response = await http.post(
  url,
  headers: {"Content-Type": "application/json"},
  body: json.encode({
  "userId": userId,
  "text": text,
  }),
  );
  if (response.statusCode == 201) {
  return json.decode(response.body);
  } else {
  throw Exception('Failed to comment on post: ${response.body}');
  }
  }

  static Future<Map<String, dynamic>> updatePost(String postId, String description) async {
  final url = Uri.parse('$BASE_URL/api/posts/$postId');
  final response = await http.put(
  url,
  headers: {"Content-Type": "application/json"},
  body: json.encode({"description": description}),
  );
  if (response.statusCode == 200) {
  return json.decode(response.body);
  } else {
  throw Exception('Failed to update post: ${response.body}');
  }
  }

  // 22) DELETE a post
  static Future<Map<String, dynamic>> deletePost(String postId) async {
  final url = Uri.parse('$BASE_URL/api/posts/$postId');
  final response = await http.delete(url, headers: {"Content-Type": "application/json"});
  if (response.statusCode == 200) {
  return json.decode(response.body);
  } else {
  throw Exception('Failed to delete post: ${response.body}');
  }
  }

  // 23) FETCH reels
  static Future<List<dynamic>> fetchReels() async {
  final url = Uri.parse('$BASE_URL/api/reels');
  final response = await http.get(url, headers: {"Content-Type": "application/json"});
  if (response.statusCode == 200) {
  return json.decode(response.body);
  } else {
  throw Exception('Failed to fetch reels: ${response.body}');
  }
  }

  // 24) Like a reel
  static Future<Map<String, dynamic>> likeReel(String reelId) async {
  final url = Uri.parse('$BASE_URL/api/reels/$reelId/like');
  final response = await http.post(url, headers: {"Content-Type": "application/json"});
  if (response.statusCode == 200) {
  return json.decode(response.body);
  } else {
  throw Exception('Failed to like reel: ${response.body}');
  }
  }

  // 25) Comment on a reel
  static Future<Map<String, dynamic>> commentOnReel(String reelId, String userId, String text) async {
  final url = Uri.parse('$BASE_URL/api/reels/$reelId/comment');
  final response = await http.post(
  url,
  headers: {"Content-Type": "application/json"},
  body: json.encode({
  "userId": userId,
  "text": text,
  }),
  );
  if (response.statusCode == 201) {
  return json.decode(response.body);
  } else {
  throw Exception('Failed to comment on reel: ${response.body}');
  }
  }

  // 26) Get user streak count
  static Future<int> getUserStreak(String userId) async {
  final url = Uri.parse('$BASE_URL/api/streaks/$userId');
  final response = await http.get(url, headers: {"Content-Type": "application/json"});
  if (response.statusCode == 200) {
  final data = json.decode(response.body);
  return data['streakCount'] ?? 0;
  } else {
  throw Exception("Failed to fetch streak: ${response.body}");
  }
  }

  // 27) Update streak count
  static Future<Map<String, dynamic>> updateStreak(String userId, String workoutDate) async {
  final url = Uri.parse('$BASE_URL/api/streaks/$userId/update');
  final response = await http.post(
  url,
  headers: {"Content-Type": "application/json"},
  body: json.encode({
  "workoutDate": workoutDate,
  }),
  );
  if (response.statusCode == 200) {
  return json.decode(response.body);
  } else {
  throw Exception("Failed to update streak: ${response.body}");
  }
  }
  // 28) Get streak leaderboard
  static Future<List<dynamic>> getStreakLeaderboard() async {
  final url = Uri.parse('$BASE_URL/api/streaks/leaderboard');
  final response = await http.get(url, headers: {"Content-Type": "application/json"});
  if (response.statusCode == 200) {
  return json.decode(response.body);
  } else {
  throw Exception('Failed to fetch streak leaderboard: ${response.body}');
  }
  }

  // 29) SHARE a workout to the dashboard
  static Future<Map<String, dynamic>> shareWorkout(String workoutId) async {
    final url = Uri.parse('$BASE_URL/api/workouts/share/$workoutId');
    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      // no body needed—workoutId is in the path
    );
    if (response.statusCode == 201) {
      return json.decode(response.body) as Map<String, dynamic>;
    } else {
      throw Exception('Failed to share workout: ${response.body}');
    }
  }

  // 31) Update username endpoint
  static Future<Map<String, dynamic>> updateUsername(
      String userId,
      String newUsername,
      ) async {
    final url = Uri.parse('$BASE_URL/api/users/$userId/username');
    final response = await http.put(
      url,
      headers: {"Content-Type": "application/json"},
      body: json.encode({"username": newUsername}),
    );
    if (response.statusCode == 200) {
      return json.decode(response.body) as Map<String, dynamic>;
    }
    throw Exception('Failed to update username: ${response.body}');
  }

  // 32) Update password endpoint
  static Future<Map<String, dynamic>> updatePassword(
      String userId,
      String oldPassword,
      String newPassword,
      ) async {
    final url = Uri.parse('$BASE_URL/api/users/$userId/password');
    final response = await http.put(
      url,
      headers: {"Content-Type": "application/json"},
      body: json.encode({"oldPassword": oldPassword, "newPassword": newPassword}),
    );
    if (response.statusCode == 200) {
      return json.decode(response.body) as Map<String, dynamic>;
    }
    throw Exception('Failed to update password: ${response.body}');
  }

  // 33) Add planned workout
  static Future<Map<String, dynamic>> addPlannedWorkout({
    required String userId,
    required String workoutName,
    required List<String> muscleGroups,
    required DateTime scheduledDatetime,
    required bool roastEnabled,
  }) async {
    final url = Uri.parse('$BASE_URL/api/plannedWorkouts');
    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: json.encode({
        "user_id": userId,
        "workout_name": workoutName,
        "muscle_groups": muscleGroups,
        "scheduled_datetime": scheduledDatetime.toIso8601String(),
        "roast_enabled": roastEnabled,
      }),
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      return json.decode(response.body) as Map<String, dynamic>;
    }
    throw Exception('Failed to create planned workout: ${response.body}');
  }

  // 34) Update profile picture endpoint
  static Future<Map<String, dynamic>> updateProfilePicture(
      String userId,
      ) async {
    final url = Uri.parse('$BASE_URL/api/users/$userId/profile-picture');
    final response = await http.put(
      url,
      headers: {"Content-Type": "application/json"},
    );
    if (response.statusCode == 200) {
      return json.decode(response.body) as Map<String, dynamic>;
    }
    throw Exception('Failed to update profile picture: ${response.body}');
  }

  // 35) GET a user's profile by ID
  static Future<Map<String, dynamic>> getUserProfile(String userId) async {
    final url = Uri.parse('$BASE_URL/api/users/$userId');
    final response = await http.get(
      url,
      headers: {"Content-Type": "application/json"},
    );
    if (response.statusCode == 200) {
      return json.decode(response.body) as Map<String, dynamic>;
    }
    throw Exception('Failed to fetch user profile: ${response.body}');
  }
}