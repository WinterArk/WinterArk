// api_service.dart
// ignore_for_file: constant_identifier_names

import 'package:http/http.dart' as http;
import 'dart:convert';

class ApiService {
  // Use the correct BASE_URL for your emulator or device.
  // For localhost
  // http://10.0.2.2:3000
  // Web Server
  // http://18.234.214.233:3000
  static const String BASE_URL = 'http://18.234.214.233:3000';

  // Updated Sign Up Method that accepts a name
  static Future<Map<String, dynamic>> signUp(String name, String email, String password) async {
    final url = Uri.parse('$BASE_URL/api/users/register');
    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: json.encode({
        "name": name,        // Now including name
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

  // Sign In Method remains the same
  static Future<Map<String, dynamic>> signIn(String email, String password) async {
    final url = Uri.parse('$BASE_URL/api/users/login');
    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: json.encode({
        "email": email,
        "password": password,
      }),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to sign in: ${response.body}');
    }
  }

   // Verify Method for confirming email verification code
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

   // Resend Verification method
  static Future<Map<String, dynamic>> resendVerification(String email) async {
    final url = Uri.parse('$BASE_URL/api/users/resend-verification');
    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: json.encode({
        "email": email,
      }),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to resend verification email: ${response.body}');
    }
  }
}
