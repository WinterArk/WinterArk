import 'package:flutter/material.dart';
import 'api_service.dart';

class StreakLeaderboardPage extends StatelessWidget {
  const StreakLeaderboardPage({super.key});

  /// Fetch leaderboard data and augment each streak with the username
  Future<List<Map<String, dynamic>>> _fetchLeaderboardWithUsernames() async {
    final List<dynamic> streaks = await ApiService.getStreakLeaderboard();
    final List<Map<String, dynamic>> leaderboard = [];
    for (var entry in streaks) {
      final userId = entry['user_id'] as String;
      final streakCount = entry['streakCount'] as int? ?? 0;
      String username;
      try {
        final profile = await ApiService.getUserProfile(userId);
        username = profile['username'] as String? ?? userId;
      } catch (e) {
        username = userId;
      }
      leaderboard.add({
        'username': username,
        'streakCount': streakCount,
      });
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
              child: Text('Error: \${snapshot.error}', style: const TextStyle(color: Colors.white)),
            );
          }
          final leaderboard = snapshot.data ?? [];
          return Column(
            children: [
              const SizedBox(height: 20),
              const Icon(Icons.emoji_events, color: Colors.amber, size: 80),
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
                    final username = entry['username'] as String;
                    final streak = entry['streakCount'] as int;

                    Color iconColor;
                    if (index == 0) {
                      iconColor = Colors.amber;
                    } else if (index == 1) {
                      iconColor = Colors.grey;
                    } else if (index == 2) {
                      iconColor = const Color(0xFFB85C3B);
                    } else {
                      iconColor = Colors.orange;
                    }

                    return ListTile(
                      leading: Icon(Icons.whatshot, color: iconColor, size: 30),
                      title: Text(username, style: const TextStyle(color: Colors.white, fontSize: 18)),
                      trailing: Text(
                        streak.toString(),
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
