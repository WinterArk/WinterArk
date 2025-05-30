import 'package:flutter/material.dart';
import 'button_effects/ui_helpers.dart';
import 'settings_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'api_service.dart';
import 'gymbuddy.dart';
import 'past_workouts.dart';
import 'profile_post.dart';
import 'dart:typed_data';
import 'dart:io';
import 'package:video_thumbnail/video_thumbnail.dart';
import 'video_player_page.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;

class ProfilePage extends StatefulWidget {
  final String userId;
 
  const ProfilePage({super.key, required this.userId});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late Future<Map<String, dynamic>> _profileFuture;  
  late Future<List<ProfilePost>> _postsFuture;
  int _buddyCount = 0;

  @override
  void initState() {
    super.initState();
    _profileFuture = ApiService.getUserProfile(widget.userId);
    _postsFuture = ApiService.getUserPosts(widget.userId);
    _loadBuddyCount();
  }

  // Future<void> _loadProfile() async {
  //   _profileFuture = ApiService.getUserProfile(widget.userId);
  // }

  Future<void> _loadBuddyCount() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _buddyCount = prefs.getInt('connected_buddies_count') ?? 0;
    });
  }

  Future<String?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('userId');
  }

  Future<Uint8List?> _makeVideoThumb(String url) async {
    // 1) Download to temp file
    final resp = await http.get(Uri.parse(url));
    final tmp = await getTemporaryDirectory();
    final f = File('${tmp.path}/${DateTime.now().millisecondsSinceEpoch}.mp4');
    await f.writeAsBytes(resp.bodyBytes);

    // 2) Generate thumbnail
    return VideoThumbnail.thumbnailData(
      video: f.path,
      imageFormat: ImageFormat.JPEG,
      maxWidth: 200,
      quality: 75,
    );
  }

  Widget _buildGridCell(ProfilePost p) {
    final isVideo = p.mediaType == 'video';
    return GestureDetector(
      onTap: isVideo
          ? () => Navigator.push(context, MaterialPageRoute(
        builder: (_) => VideoPlayerPage(
          url: p.mediaUrl,
          fitStyle: BoxFit.cover,   // or BoxFit.contain
        ),
      )): null, 
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Stack(fit: StackFit.expand, children: [
          // 1) if it's an image, show it directly
          if (!isVideo)
            Image.network(p.mediaUrl, fit: BoxFit.cover)

          // 2) if it's a video, asynchronously load a thumbnail
          else
            FutureBuilder<Uint8List?>(
              future: VideoThumbnail.thumbnailData(
                video: p.mediaUrl,
                imageFormat: ImageFormat.JPEG,
                maxWidth: 200, // thumbnail width
                quality: 75,
              ),
              builder: (ctx, snap) {
                final data = snap.data;
                if (snap.connectionState != ConnectionState.done)
                  return Container(color: Colors.black26);
                if (data == null) // failed to generate
                  return Container(color: Colors.black26);
                return Image.memory(data, fit: BoxFit.cover);
              },
            ),

          // overlay a play icon for videos
          if (isVideo)
            const Center(
              child: Icon(
                Icons.play_circle_fill,
                color: Colors.white70,
                size: 40,
              ),
            ),
        ]),
      ),
    );
  }

  Widget _buildGrid(List<ProfilePost> posts) {
    return GridView.builder(
      padding: const EdgeInsets.all(8),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 4,
        crossAxisSpacing: 4,
      ),
      itemCount: posts.length,
      itemBuilder: (_, i) => _buildGridCell(posts[i]),
    );
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
            icon: glowingIcon(Icons.calendar_today, Colors.white, 24),
            tooltip: 'Workout History',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => PastWorkoutsCalendar(),
                ),
              );
            },
          ),
          const SizedBox(width: 5),
          IconButton(
            icon: glowingIcon(Icons.settings, Colors.white, 24),
            tooltip: 'Settings',
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
              final name = profile['name'] as String? ?? 'Unknown';
              final bio      = profile['bio']      as String? ?? '';
              final initial = name.isNotEmpty ? name[0].toUpperCase() : '?';
              final hash    = name.hashCode;
              final swatch  = Colors.primaries[hash % Colors.primaries.length];
              final avatarColor = swatch.shade700;

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
                      onTap: () { /* … */ },
                      child: CircleAvatar(
                        radius: 40,
                        backgroundColor: avatarColor,
                        child: Text(
                          initial,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            name,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            username,
                            style: const TextStyle(color: Colors.white70),
                          ),
                          //  ``const SizedBox(height: 5),
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
                                  builder: (ctx) => GymBuddyScreen(currentUserId: widget.userId, showBackArrow: true),
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
                                      "Gym Buddies: $_buddyCount",
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
            child: FutureBuilder<List<ProfilePost>>(
              future: _postsFuture,
              builder: (ctx, snap) {
                if (snap.connectionState != ConnectionState.done)
                  return Center(child: CircularProgressIndicator());
                if (snap.hasError)
                  return Center(child: Text("Error loading posts"));

                final all   = snap.data!;
                final images = all.where((p) => p.mediaType == 'image').toList();
                final reels  = all.where((p) => p.mediaType == 'video').toList();

                return DefaultTabController(
                  length: 2,
                  child: Column(
                    children: [
                      TabBar(
                        // active tab label color
                        labelColor: blueGrotto,
                        // inactive tab label color
                        unselectedLabelColor: Colors.white70,
                        // the little line under the active tab
                        indicatorColor: blueGrotto,
                        // how thick that line should be
                        indicatorWeight: 3,
                        tabs: const [
                          Tab(text: "Images"),
                          Tab(text: "Reels"),
                        ],
                      ),
                      // this Expanded gives TabBarView a bounded height
                      Expanded(
                        child: TabBarView(
                          children: [
                            _buildGrid(images),       
                            _buildGrid(reels),        
                          ],
                        ),
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