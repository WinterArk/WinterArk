import 'package:flutter/material.dart';
import 'api_service.dart';
import 'button_effects/ui_helpers.dart';
import 'button_effects/neon_button_onpressed.dart';

class AccountSettingsPage extends StatefulWidget {
  final String userId;
  const AccountSettingsPage({super.key, required this.userId});

  @override
  _AccountSettingsPageState createState() => _AccountSettingsPageState();
}

class _AccountSettingsPageState extends State<AccountSettingsPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _oldPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  bool _isLoading = false;
  String _message = '';

  Future<void> _updateUsername() async {
    setState(() {
      _isLoading = true;
      _message = '';
    });
    try {
      final result = await ApiService.updateUsername(
        widget.userId,
        _usernameController.text.trim(),
      );
      setState(() {
        _message = 'Username updated successfully to ${result['username']}';
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

  Future<void> _updatePassword() async {
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
        _message = result['message'] ?? 'Password updated successfully';
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

  Future<void> _updateProfilePicture() async {
    setState(() {
      _isLoading = true;
      _message = '';
    });
    try {
      final result = await ApiService.updateProfilePicture(widget.userId);
      setState(() {
        _message = result['message'] ?? 'Profile picture updated successfully';
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
    _isLoading = false;
    _message = '';
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(width: 8),
          Text(
            "Account Settings",
            style: glowingTextStyle(
              Colors.white,
              size: 26,
            ),
          ),
        ],
      ),
        backgroundColor: Colors.black,
        centerTitle: true,
        leading: IconButton(
          icon: glowingIcon(Icons.arrow_back, Colors.white, 24),
          onPressed: () => Navigator.of(context).maybePop(),
          tooltip: 'Back',
        ),  
      ),
      backgroundColor: Colors.black,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Change Username',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _usernameController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                hintText: 'Enter new username',
                hintStyle: TextStyle(color: Colors.white54),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            NeonButton(
              onPressed: _isLoading ? null : _updateUsername,
              glowColor: Colors.white,
              backgroundColor: Colors.black,
              label: 'Update Username',
            ),
            const SizedBox(height: 16),
            const Text(
              'Change Password',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _oldPasswordController,
              obscureText: true,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                hintText: 'Enter old password',
                hintStyle: TextStyle(color: Colors.white54),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _newPasswordController,
              obscureText: true,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                hintText: 'Enter new password',
                hintStyle: TextStyle(color: Colors.white54),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _confirmPasswordController,
              obscureText: true,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                hintText: 'Confirm new password',
                hintStyle: TextStyle(color: Colors.white54),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            NeonButton(
              onPressed: _isLoading ? null : _updatePassword,
              glowColor: Colors.white,
              backgroundColor: Colors.black,
              label: 'Update Passoword',
            ),
            const SizedBox(height: 16),
            const Text(
              'Change Profile Picture',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            NeonButton(
              onPressed: _isLoading ? null : _updateProfilePicture,
              glowColor: Colors.white,
              backgroundColor: Colors.black,
              label: 'Update Profile Picture',
            ),
            const SizedBox(height: 16),
            if (_message.isNotEmpty)
              Text(
                _message,
                style: const TextStyle(color: Colors.white),
              ),
          ],
        ),
      ),
    );
  }
}
