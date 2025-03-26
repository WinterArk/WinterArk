import 'package:flutter/material.dart';
import 'api_service.dart';

class StreakLeaderboardPage extends StatelessWidget {
  const StreakLeaderboardPage({Key? key}) : super(key: key);

  // Fetch leaderboard data and augment each streak with the username
  Future<List<Map<String, dynamic>>> _fetchLeaderboardWithUsernames() async {
    // Call leaderboard API route
    List<dynamic> streaks = await ApiService.getStreakLeaderboard();
    List<Map<String, dynamic>> leaderboard = [];
    for (var streak in streaks) {
      try {
        // Fetch the user profile using the user id from the streak
        Map<String, dynamic> profile = await ApiService.getUserProfile(streak['user_id']);
        streak['username'] = profile['username'];
      } catch (e) {
        streak['username'] = "Unknown";
      }
      leaderboard.add(Map<String, dynamic>.from(streak));
    }
    return leaderboard;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Streak Leaderboard'),
        backgroundColor: Colors.black,
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _fetchLeaderboardWithUsernames(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}', style: const TextStyle(color: Colors.white)),
            );
          }
          final leaderboard = snapshot.data ?? [];
          return Column(
            children: [
              const SizedBox(height: 20),
              // Giant trophy icon at the top
              const Icon(
                Icons.emoji_events,
                color: Colors.amber,
                size: 80,
              ),
              const SizedBox(height: 10),
              const Text(
                'Top Streaks',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: ListView.builder(
                  itemCount: leaderboard.length,
                  itemBuilder: (context, index) {
                    final entry = leaderboard[index];
                    final username = entry['username'] ?? 'Unknown';
                    final streakCount = entry['streakCount'] ?? 0;

                    // Choose icon color based on ranking
                    Color iconColor;
                    if (index == 0) {
                      iconColor = Colors.amber; 
                    } else if (index == 1) {
                      iconColor = Colors.grey; 
                    } else if (index == 2) {
                      iconColor = Color(0xFFB85C3B); 
                    } else {
                      iconColor = Colors.orange;
                    }

                    return ListTile(
                      leading: Icon(
                        Icons.whatshot,
                        color: iconColor,
                        size: 30,
                      ),
                      title: Text(
                        username,
                        style: const TextStyle(color: Colors.white, fontSize: 18),
                      ),
                      trailing: Text(
                        streakCount.toString(),
                        style: const TextStyle(color: Colors.white, fontSize: 18),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
