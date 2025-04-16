import 'package:flutter/material.dart';
import 'winterark_home.dart';
import 'account_settings.dart';
import 'notification_settings.dart';
import 'api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsPage extends StatefulWidget {
  final String userId;
  const SettingsPage({super.key, required this.userId});

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final Color frostBlue = const Color(0xFF3B82F6);
  final Color cardGray = const Color(0xFF1F2937);
  final Color textSnow = const Color(0xFFF9FAFB);

  final List<_SettingsItem> generalItems = [
    _SettingsItem(icon: Icons.notifications, label: 'Notifications'),
    _SettingsItem(icon: Icons.lock, label: 'Privacy', highlight: true),
    _SettingsItem(icon: Icons.security, label: 'Security'),
  ];

  final List<_SettingsItem> accountItems = [
    _SettingsItem(icon: Icons.person, label: 'Account'),
    _SettingsItem(icon: Icons.help_outline, label: 'Help'),
    _SettingsItem(icon: Icons.info_outline, label: 'About'),
  ];

  final List<String> roastLevels = [
    '🥶 Ice Cold',
    '🧊 Chill But Honest',
    '🔥 Spicy Motivation',
    '💀 Ruthless Gym Goblin'
  ];

  String selectedRoast = '🥶 Ice Cold';

  Future<bool> _showSignOutConfirmation() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Confirm Sign Out"),
        content: const Text("Are you sure you want to sign out?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Cancel")),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text("Sign Out")),
        ],
      ),
    );
    return result ?? false;
  }

  Future<void> _confirmAndSignOut() async {
    final confirmed = await _showSignOutConfirmation();
    if (!confirmed) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
    } catch (e) {
      debugPrint('Logout error: $e');
    }

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const WinterArkHome()),
          (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Column(
        children: [
          _buildCustomHeader(),
          _buildStreakBadge(),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _buildSection('GENERAL', generalItems),
                _buildSection('ACCOUNT', accountItems),
                _buildRoastNotificationLevel(),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: ElevatedButton.icon(
              icon: const Icon(Icons.logout),
              label: const Text('Log Out'),
              onPressed: _confirmAndSignOut,
              style: ElevatedButton.styleFrom(
                backgroundColor: frostBlue,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 52),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                textStyle: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomHeader() => Padding(
    padding: const EdgeInsets.fromLTRB(20, 48, 20, 12),
    child: Row(
      children: [
        IconButton(
          icon: Icon(Icons.arrow_back, color: frostBlue, size: 32),
          onPressed: () => Navigator.pop(context),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('WinterArk\'s Settings', style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: textSnow)),
              const SizedBox(height: 6),
              Text('Welcome back, winter warrior — let’s personalize your grind.', style: TextStyle(fontSize: 14, color: Colors.grey[400])),
            ],
          ),
        ),
      ],
    ),
  );

  Widget _buildStreakBadge() => FutureBuilder<int>(
    future: ApiService.getUserStreak(widget.userId),
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return _streakContainer(child: const CircularProgressIndicator());
      }
      if (snapshot.hasError) {
        return _streakContainer(child: const Text('Error loading streak.', style: TextStyle(color: Colors.red)));
      }
      final streak = snapshot.data ?? 0;
      final progress = streak >= 10 ? 1.0 : streak / 10;
      return _streakContainer(
        child: Row(
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(width: 56, height: 56, child: CircularProgressIndicator(value: progress, strokeWidth: 5, backgroundColor: Colors.grey[800], valueColor: AlwaysStoppedAnimation(frostBlue))),
                Icon(Icons.local_fire_department, color: frostBlue, size: 28),
              ],
            ),
            const SizedBox(width: 20),
            Text('🔥 $streak-Day Streak!', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textSnow)),
          ],
        ),
      );
    },
  );

  Widget _streakContainer({required Widget child}) => Container(
    decoration: BoxDecoration(color: cardGray, borderRadius: BorderRadius.circular(16)),
    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    padding: const EdgeInsets.all(20),
    child: child,
  );

  Widget _buildSection(String title, List<_SettingsItem> items) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 8),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Text(title, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.grey[500]!)),
        ),
        ...items.map((item) => ListTile(
          leading: Icon(item.icon, color: item.highlight ? frostBlue : Colors.white70),
          title: Text(item.label, style: TextStyle(fontSize: 16, fontWeight: item.highlight ? FontWeight.bold : FontWeight.normal, color: item.highlight ? frostBlue : textSnow)),
          onTap: () {
            if (item.label.toLowerCase() == 'notifications') {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationSettingsPage()));
            } else if (item.label.toLowerCase() == 'account') {
              Navigator.push(context, MaterialPageRoute(builder: (_) => AccountSettingsPage(userId: widget.userId)));
            }
          },
        )),
      ],
    ),
  );

  Widget _buildRoastNotificationLevel() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Padding(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Text('ROAST NOTIFICATION LEVEL', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.grey)),
      ),
      SizedBox(
        height: 42,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: roastLevels.length,
          itemBuilder: (_, i) {
            final roast = roastLevels[i];
            return Padding(
              padding: const EdgeInsets.only(right: 12),
              child: OutlinedButton(
                onPressed: () => setState(() => selectedRoast = roast),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: selectedRoast == roast ? frostBlue : Colors.white24),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  foregroundColor: selectedRoast == roast ? frostBlue : Colors.white,
                ),
                child: Text(roast),
              ),
            );
          },
        ),
      ),
      const SizedBox(height: 20),
    ],
  );
}

class _SettingsItem {
  final IconData icon;
  final String label;
  final bool highlight;

  const _SettingsItem({required this.icon, required this.label, this.highlight = false});
}
