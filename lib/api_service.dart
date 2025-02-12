import 'package:http/http.dart' as http;
import 'dart:convert';

class ApiService {
  // http://18.234.214.233:3000
  // http://10.0.2.2:3000
  static const String BASE_URL = 'http://18.234.214.233:3000';

  // 1) SIGN UP a new user
  static Future<Map<String, dynamic>> signUp(
      String name, String username, String email, String password) async {
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
      return json.decode(response.body);
    } else {
      throw Exception('Failed to sign up: ${response.body}');
    }
  }

  // 2) SIGN IN an existing user
  static Future<Map<String, dynamic>> signIn(
      String identifier, String password) async {
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
      return json.decode(response.body);
    } else {
      throw Exception('Failed to sign in: ${response.body}');
    }
  }

  // 3) VERIFY user account
  static Future<Map<String, dynamic>> verify(String email, String code) async {
    final url = Uri.parse('$BASE_URL/api/users/verify');
    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: json.encode({
        "email": email,
        "code": code,
      }),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Verification failed: ${response.body}');
    }
  }

  // 4) RESEND verification email
  static Future<Map<String, dynamic>> resendVerification(String email) async {
    final url = Uri.parse('$BASE_URL/api/users/resend-verification');
    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: json.encode({"email": email}),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to resend verification email: ${response.body}');
    }
  }

  // 5) SEARCH users
  static Future<List<dynamic>> searchUsers(String query, String filter) async {
    final url = Uri.parse('$BASE_URL/api/users/search?query=$query&filter=$filter');
    final response = await http.get(
      url,
      headers: {"Content-Type": "application/json"},
    );
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to search users: ${response.body}');
    }
  }

  // 6) ADD gym buddy
  static Future<Map<String, dynamic>> addGymBuddy(String userId, String buddyId) async {
    final url = Uri.parse('$BASE_URL/api/gymbuddies');
    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: json.encode({
        "userId": userId,
        "buddyId": buddyId,
      }),
    );
    if (response.statusCode == 201) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to add gym buddy: ${response.body}');
    }
  }

  // 7) FETCH a user's gym buddies
  static Future<List<dynamic>> fetchUserBuddies(String userId) async {
    final url = Uri.parse('$BASE_URL/api/gymbuddies/$userId');
    final response = await http.get(
      url,
      headers: {"Content-Type": "application/json"},
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to fetch buddies: ${response.body}');
    }
  }

  // 8) UPDATE buddy status (accept/decline)
  static Future<Map<String, dynamic>> updateBuddyStatus(String docId, String newStatus) async {
    final url = Uri.parse('$BASE_URL/api/gymbuddies/$docId');
    final response = await http.patch(
      url,
      headers: {"Content-Type": "application/json"},
      body: json.encode({"status": newStatus}),
    );
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to update buddy status: ${response.body}');
    }
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
        "date": date != null ? date.toIso8601String() : null,
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
  static Future<List<dynamic>> getWorkoutsForDay(String userId, String date) async {
    // Build the URL with the userId and date query parameter
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
  static Future<Map<String, dynamic>> updateWorkout(String workoutId, Map<String, dynamic> updateData) async {
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
}
