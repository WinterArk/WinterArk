// profile_page.dart
import 'package:flutter/material.dart';
import 'api_service.dart';
import 'settings_page.dart';  // Import the settings page file

class ProfilePage extends StatefulWidget {
  final String userId;
  const ProfilePage({super.key, required this.userId});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  Map<String, dynamic>? profile;
  bool isLoading = true;
  String errorMsg = '';

  @override
  void initState() {
    super.initState();
    fetchProfile();
  }

  Future<void> fetchProfile() async {
    try {
      final data = await ApiService.getUserProfile(widget.userId);
      setState(() {
        profile = data;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMsg = e.toString();
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        // Disable automatic back arrow
        automaticallyImplyLeading: false,
        title: Text(
          profile?['username'] ?? "Profile",
          style: const TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Colors.blue,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.white),
            onPressed: () {
              // Navigate to the Settings Page with userId
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => SettingsPage(userId: widget.userId)),
              );
            },
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMsg.isNotEmpty
          ? Center(
          child: Text(errorMsg,
              style: const TextStyle(color: Colors.white)))
          : Column(
        children: [
          Container(
            color: Colors.grey[900],
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundColor: Colors.blue,
                  child: const Icon(Icons.person,
                      color: Colors.white, size: 40),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        profile?['username'] ?? "Username",
                        style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: Colors.white),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        profile?['bio'] ?? "Bio goes here...",
                        style: const TextStyle(
                            fontSize: 14, color: Colors.white),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Text(
                            "Followers",
                            style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            profile?['followers']?.toString() ?? "0",
                            style: const TextStyle(
                                fontSize: 16, color: Colors.blue),
                          ),
                          const SizedBox(width: 20),
                          Text(
                            "Following",
                            style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            profile?['following']?.toString() ?? "0",
                            style: const TextStyle(
                                fontSize: 16, color: Colors.blue),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(8.0),
              gridDelegate:
              const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 4.0,
                mainAxisSpacing: 4.0,
              ),
              // Assume profile['posts'] is an array of image URLs
              itemCount: profile?['posts']?.length ?? 0,
              itemBuilder: (context, index) {
                final postImage = profile?['posts'][index] ??
                    'https://via.placeholder.com/150';
                return Container(
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.network(
                          postImage,
                          fit: BoxFit.cover,
                        ),
                        const Align(
                          alignment: Alignment.center,
                          child: Icon(Icons.play_circle_fill,
                              color: Colors.white, size: 40),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}