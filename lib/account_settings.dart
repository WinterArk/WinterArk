// account_settings_page.dart
import 'package:flutter/material.dart';
import 'api_service.dart';

class AccountSettingsPage extends StatefulWidget {
  final String userId;
  const AccountSettingsPage({Key? key, required this.userId}) : super(key: key);

  @override
  _AccountSettingsPageState createState() => _AccountSettingsPageState();
}

class _AccountSettingsPageState extends State<AccountSettingsPage> {
  final _usernameController = TextEditingController();
  final _oldPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;
  String _message = '';

  void _updateUsername() async {
    setState(() {
      _isLoading = true;
      _message = '';
    });
    try {
      final result = await ApiService.updateUsername(
          widget.userId, _usernameController.text.trim());
      setState(() {
        _message = 'Username updated successfully to ${result["username"]}';
      });
    } catch (e) {
      setState(() {
        _message = 'Error updating username: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _updatePassword() async {
    if (_newPasswordController.text.trim() != _confirmPasswordController.text.trim()) {
      setState(() {
        _message = 'New passwords do not match.';
      });
      return;
    }
    setState(() {
      _isLoading = true;
      _message = '';
    });
    try {
      final result = await ApiService.updatePassword(
        widget.userId,
        _oldPasswordController.text.trim(),
        _newPasswordController.text.trim(),
      );
      setState(() {
        _message = result["message"] ?? 'Password updated successfully';
      });
    } catch (e) {
      setState(() {
        _message = 'Error updating password: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _updateProfilePicture() async {
    setState(() {
      _isLoading = true;
      _message = '';
    });
    try {
      final result = await ApiService.updateProfilePicture(widget.userId);
      setState(() {
        _message = result["message"] ?? 'Profile picture update placeholder';
      });
    } catch (e) {
      setState(() {
        _message = 'Error updating profile picture: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Account Settings"),
        backgroundColor: Colors.black,
      ),
      backgroundColor: Colors.black,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Username Change Section
            Text("Change Username",
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            TextField(
              controller: _usernameController,
              style: TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: "Enter new username",
                hintStyle: TextStyle(color: Colors.white54),
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 8),
            ElevatedButton(
              onPressed: _isLoading ? null : _updateUsername,
              child: Text("Update Username"),
            ),
            SizedBox(height: 16),
            // Password Change Section
            Text("Change Password",
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            TextField(
              controller: _oldPasswordController,
              obscureText: true,
              style: TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: "Enter old password",
                hintStyle: TextStyle(color: Colors.white54),
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 8),
            TextField(
              controller: _newPasswordController,
              obscureText: true,
              style: TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: "Enter new password",
                hintStyle: TextStyle(color: Colors.white54),
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 8),
            TextField(
              controller: _confirmPasswordController,
              obscureText: true,
              style: TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: "Confirm new password",
                hintStyle: TextStyle(color: Colors.white54),
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 8),
            ElevatedButton(
              onPressed: _isLoading ? null : _updatePassword,
              child: Text("Update Password"),
            ),
            SizedBox(height: 16),
            // Profile Picture Change Section (Placeholder)
            Text("Change Profile Picture",
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            ElevatedButton(
              onPressed: _isLoading ? null : _updateProfilePicture,
              child: Text("Update Profile Picture (Placeholder)"),
            ),
            SizedBox(height: 16),
            if (_message.isNotEmpty)
              Text(_message, style: TextStyle(color: Colors.white)),
          ],
        ),
      ),
    );
  }
}
