import 'package:flutter/material.dart';
import 'settings_page.dart';

/// Entry point for the Profile Page
void main() {
  runApp(MaterialApp(
    home: const ProfilePage(userId: 'demoUser'),
    theme: ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: Colors.black,
      primaryColor: Colors.blue,
      cardColor: Colors.grey[850],
      appBarTheme: const AppBarTheme(backgroundColor: Colors.blue),
    ),
    debugShowCheckedModeBanner: false,
  ));
}

class ProfilePage extends StatelessWidget {
  final String userId;
  final Map<String, dynamic>? profile;
  final bool isLoading;
  final String errorMsg;

  const ProfilePage({
    super.key,
    required this.userId,
    this.profile,
    this.isLoading = false,
    this.errorMsg = '',
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          profile?['username'] ?? 'Profile',
          style: const TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => SettingsPage(userId: userId),
                ),
              );
            },
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMsg.isNotEmpty
          ? Center(
        child: Text(
          errorMsg,
          style: const TextStyle(color: Colors.white),
        ),
      )
          : Column(
        children: [
          Container(
            color: Colors.grey[900],
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (_) => AlertDialog(
                        backgroundColor: Colors.grey[900],
                        title: const Text('Profile Picture', style: TextStyle(color: Colors.white)),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ListTile(
                              leading: const Icon(Icons.photo_camera, color: Colors.white),
                              title: const Text('Change Picture', style: TextStyle(color: Colors.white)),
                              onTap: () => Navigator.pop(context),
                            ),
                            ListTile(
                              leading: const Icon(Icons.delete, color: Colors.white),
                              title: const Text('Delete Picture', style: TextStyle(color: Colors.white)),
                              onTap: () => Navigator.pop(context),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                  child: CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.blue,
                    child: const Icon(Icons.person, color: Colors.white, size: 40),
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        profile?['username'] ?? 'Username',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        profile?['bio'] ?? 'Bio goes here...',
                        style: const TextStyle(fontSize: 14, color: Colors.white),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          const Text('Followers', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                          const SizedBox(width: 10),
                          Text(
                            (profile?['followers'] ?? 0).toString(),
                            style: const TextStyle(fontSize: 16, color: Colors.blue),
                          ),
                          const SizedBox(width: 20),
                          const Text('Following', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                          const SizedBox(width: 10),
                          Text(
                            (profile?['following'] ?? 0).toString(),
                            style: const TextStyle(fontSize: 16, color: Colors.blue),
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
              padding: const EdgeInsets.all(8),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 4,
                mainAxisSpacing: 4,
              ),
              itemCount: profile?['posts']?.length ?? 0,
              itemBuilder: (_, index) {
                final postImage = profile!['posts'][index] as String;
                return ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.network(postImage, fit: BoxFit.cover),
                      const Align(
                        alignment: Alignment.center,
                        child: Icon(Icons.play_circle_fill, color: Colors.white, size: 40),
                      ),
                    ],
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

/// Gym Buddies listing page
class GymBuddiesPage extends StatelessWidget {
  final List<String> buddies = ['IanW', 'JacobM', 'FassihK', 'TidankayS', 'JazminC'];

  GymBuddiesPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Gym Buddies')),
      body: ListView.builder(
        itemCount: buddies.length,
        itemBuilder: (_, i) => ListTile(
          leading: const Icon(Icons.person, color: Colors.white),
          title: Text(buddies[i], style: const TextStyle(color: Colors.white)),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => UserProfilePage(username: buddies[i])),
          ),
        ),
      ),
    );
  }
}

/// Public profile for another user
class UserProfilePage extends StatelessWidget {
  final String username;
  const UserProfilePage({super.key, required this.username});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(username)),
      body: Column(
        children: [
          Container(
            color: Colors.grey[900],
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                CircleAvatar(radius: 40, backgroundColor: Colors.blue, child: const Icon(Icons.person, color: Colors.white, size: 40)),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(username, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white)),
                      const SizedBox(height: 5),
                      const Text('User bio or details go here...', style: TextStyle(fontSize: 14, color: Colors.white)),
                      const SizedBox(height: 10),
                      Card(
                        color: Theme.of(context).cardColor,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: const [
                              Icon(Icons.fitness_center, color: Colors.white),
                              SizedBox(width: 8),
                              Text('Gym Buddies: XXX', style: TextStyle(color: Colors.white)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Expanded(
            child: Center(
              child: Text('Placeholder for images/reels', style: TextStyle(fontSize: 16, color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }
}
