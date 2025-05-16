import 'package:flutter/material.dart';
import 'button_effects/ui_helpers.dart';
import 'settings_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'api_service.dart';

class ProfilePage extends StatefulWidget {
  final String userId;
 
  const ProfilePage({super.key, required this.userId});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}


class _ProfilePageState extends State<ProfilePage> {
  late Future<Map<String, dynamic>> _profileFuture;
  
  // final Map<String, dynamic>? profile;
  // final bool isLoading;
  // final String errorMsg;

  // ProfilePage({
  //   super.key,
  //   required this.userId,
  //   this.profile,
  //   this.isLoading = false,
  //   this.errorMsg = '',
  // });

  final List<String> buddies = [
    'IanW',
    'JacobM',
    'FassihK',
    'TidankayS',
    'JazminC',
  ];

  @override
  void initState() {
    super.initState();
    // Kick off the network call as soon as the page loads
    _profileFuture = ApiService.getUserProfile(widget.userId);
  }

  Future<String?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('userId');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Profile", style: glowingTextStyle(Colors.white, size: 24)),
        centerTitle: true,
        automaticallyImplyLeading: false,
        backgroundColor: Colors.black,
        elevation: 0,
        actions: [
          IconButton(
            icon: glowingIcon(Icons.settings, Colors.white, 24),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => SettingsPage(userId: widget.userId),
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          FutureBuilder<Map<String, dynamic>>(
            future: _profileFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState != ConnectionState.done) {
                return Container(
                  height: 160,
                  color: Colors.grey[900],
                  child: const Center(child: CircularProgressIndicator()),
                );
              }
              if (snapshot.hasError) {
                return Container(
                  height: 160,
                  color: Colors.grey[900],
                  child: Center(
                    child: Text(
                      'Error loading profile',
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                );
              }

              final profile  = snapshot.data!;
              final username = profile['username'] as String? ?? 'Unknown';
              final bio      = profile['bio']      as String? ?? '';

              return Container(
                height: 160,
                width: double.infinity,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color(0xFF0A1529),
                      Color(0xFF1A2C48),
                      Color(0xFF284C7A),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    // profile avatar + picker
                    GestureDetector(
                      onTap: () {
                        // ...
                      },
                      child: CircleAvatar(
                        radius: 40,
                        backgroundColor: Theme.of(context).primaryColor,
                        child: Icon(Icons.person, color: Colors.white, size: 40),
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
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
                          // Bio here
                          if (bio.isNotEmpty)
                            Text(
                              bio,
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.white70,
                              ),
                            ),
                          const SizedBox(height: 10),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (ctx) => GymBuddiesPage(buddies: buddies),
                                ),
                              );
                            },
                            child: Card(
                              color: Colors.black,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.fitness_center, color: Colors.white),
                                    const SizedBox(width: 8),
                                    Text(
                                      "Gym Buddies: ${buddies.length}",
                                      style: const TextStyle(color: Colors.white),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          Expanded(
            child: GridView.builder(
              padding: EdgeInsets.all(8.0),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 4.0,
                mainAxisSpacing: 4.0,
              ),
              itemCount: 21,
              itemBuilder: (context, index) {
                return Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.network(
                          'https://picsum.photos/200/300?random=$index',
                          fit: BoxFit.cover,
                        ),
                        Align(
                          alignment: Alignment.center,
                          child: Icon(
                            Icons.play_circle_fill,
                            color: Colors.white,
                            size: 40,
                          ),
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
  final List<String> buddies;

  const GymBuddiesPage({super.key, required this.buddies});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("My Gym Buddies")),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0A1529), Color(0xFF1A2C48), Color(0xFF284C7A)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: ListView.builder(
          itemCount: buddies.length,
          itemBuilder: (context, index) {
            return ListTile(
              title: Text(
                buddies[index],
                style: TextStyle(color: Colors.white),
              ),
              leading: Icon(Icons.person, color: Colors.white),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (context) => UserProfilePage(username: buddies[index]),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class UserProfilePage extends StatelessWidget {
  final String username;
  const UserProfilePage({super.key, required this.username});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(username)),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0A1529), Color(0xFF1A2C48), Color(0xFF284C7A)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: Theme.of(context).primaryColor,
                    child: Icon(Icons.person, color: Colors.white, size: 40),
                  ),
                  SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          username,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 5),
                        Text(
                          "User bio or details go here...",
                          style: TextStyle(fontSize: 14, color: Colors.white),
                        ),
                        SizedBox(height: 10),
                        Card(
                          color: Theme.of(context).cardColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.fitness_center, color: Colors.white),
                                SizedBox(width: 8),
                                Text(
                                  "Gym Buddies: XXX",
                                  style: TextStyle(color: Colors.white),
                                ),
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
            Expanded(
              child: GridView.builder(
                padding: EdgeInsets.all(8.0),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 4.0,
                  mainAxisSpacing: 4.0,
                ),
                itemCount: 21,
                itemBuilder: (context, index) {
                  return Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          Image.network(
                            'https://picsum.photos/200/300?random=$index',
                            fit: BoxFit.cover,
                          ),
                          Align(
                            alignment: Alignment.center,
                            child: Icon(
                              Icons.play_circle_fill,
                              color: Colors.white,
                              size: 40,
                            ),
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
      ),
    );
  }
}