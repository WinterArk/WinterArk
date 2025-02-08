// api_service.dart
import 'package:http/http.dart' as http;
import 'dart:convert';

class ApiService {
  static const String BASE_URL = 'http://18.234.214.233:3000';

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

  static Future<Map<String, dynamic>> signIn(String identifier, String password) async {
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
