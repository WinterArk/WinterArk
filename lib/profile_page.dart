import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'api_service.dart';
import 'settings_page.dart'; 

void main() {
  runApp(MaterialApp(
    home: ProfilePage(),
    theme: ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: Colors.black,
      primaryColor: Colors.blue,
      cardColor: Colors.grey[850],
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.blue,
      ),
    ),
    debugShowCheckedModeBanner: false,
  ));
}

class ProfilePage extends StatelessWidget {
  // Optional userId and profile data.
  final String? userId;
  // For demo purposes, this profile map might eventually come from an API.
  final Map<String, dynamic>? profile;
  // Dummy indicators for loading and errors.
  final bool isLoading;
  final String errorMsg;
  
  ProfilePage({
    Key? key,
    this.userId,
    this.profile,
    this.isLoading = false,
    this.errorMsg = "",
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // Disable automatic back arrow
        automaticallyImplyLeading: false,
        title: Text(
          profile?['username'] ?? "Profile",
          style: const TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SettingsPage(userId: userId ?? ""),
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
                  child: Text(errorMsg,
                      style: const TextStyle(color: Colors.white)),
                )
              : Column(
                  children: [
                    Container(
                      color: Colors.grey[900],
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          // Tapping the profile picture will display options.
                          GestureDetector(
                            onTap: () {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    backgroundColor: Colors.grey[900],
                                    title: const Text("Profile Picture",
                                        style: TextStyle(color: Colors.white)),
                                    content: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        ListTile(
                                          leading: const Icon(Icons.photo_camera,
                                              color: Colors.white),
                                          title: const Text("Change Picture",
                                              style:
                                                  TextStyle(color: Colors.white)),
                                          onTap: () {
                                            Navigator.pop(context);
                                            // Logic for changing picture goes here
                                          },
                                        ),
                                        ListTile(
                                          leading: const Icon(Icons.delete,
                                              color: Colors.white),
                                          title: const Text("Delete Picture",
                                              style:
                                                  TextStyle(color: Colors.white)),
                                          onTap: () {
                                            Navigator.pop(context);
                                            // Logic for deleting picture goes here
                                          },
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              );
                            },
                            child: CircleAvatar(
                              radius: 40,
                              backgroundColor: Colors.blue,
                              child: const Icon(
                                Icons.person,
                                color: Colors.white,
                                size: 40,
                              ),
                            ),
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
                                    const Text(
                                      "Followers",
                                      style: TextStyle(
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
                                    const Text(
                                      "Following",
                                      style: TextStyle(
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
                                )
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
                        itemCount: 21,
                        itemBuilder: (context, index) {
                          final postImage = profile?['posts']?[index] ??
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

class GymBuddiesPage extends StatelessWidget {
  final List<String> buddies = [
    'IanW',
    'JacobM',
    'FassihK',
    'TidankayS',
    'JazminC',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Gym Buddies"),
      ),
      body: ListView.builder(
        itemCount: buddies.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(buddies[index]),
            leading: const Icon(Icons.person, color: Colors.white),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      UserProfilePage(username: buddies[index]),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class UserProfilePage extends StatelessWidget {
  final String username;

  const UserProfilePage({Key? key, required this.username}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(username),
      ),
      body: Column(
        children: [
          Container(
            color: Colors.grey[900],
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundColor: Colors.blue,
                  child: const Icon(Icons.person, color: Colors.white, size: 40),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        username,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 5),
                      const Text(
                        "User bio or details go here...",
                        style: TextStyle(fontSize: 14, color: Colors.white),
                      ),
                      const SizedBox(height: 10),
                      Card(
                        color: Theme.of(context).cardColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.fitness_center, color: Colors.white),
                              const SizedBox(width: 8),
                              const Text(
                                "Gym Buddies: XXX",
                                style: TextStyle(color: Colors.white),
                              ),
                            ],
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: const Center(
              child: Text(
                "Placeholder for images/reels",
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
            ),
          )
        ],
      ),
    );
  }
}
