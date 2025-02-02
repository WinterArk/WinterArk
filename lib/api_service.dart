// api_service.dart
import 'package:http/http.dart' as http;
import 'dart:convert';

class ApiService {
  // Use the correct BASE_URL for your emulator or device.
  static const String BASE_URL = 'http://54.163.59.178:3000';

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
}
