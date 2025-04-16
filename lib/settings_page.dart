// settings_page.dart
import 'package:flutter/material.dart';
import 'winterark_home.dart'; // For sign-out redirection
import 'account_settings.dart'; // For account section navigation (if needed)
import 'api_service.dart';

class SettingsPage extends StatefulWidget {
  final String userId;
  const SettingsPage({Key? key, required this.userId}) : super(key: key);

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final Color frostBlue = Color(0xFF3B82F6);
  final Color cardGray = Color(0xFF1F2937);
  final Color textSnow = Color(0xFFF9FAFB);

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

  // Show a confirmation dialog before signing out.
  Future<bool> _showSignOutConfirmation() async {
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Confirm Sign Out"),
        content: const Text("Are you sure you want to sign out?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text("Sign Out"),
          ),
        ],
      ),
    ) ??
        false;
  }

  Future<void> _confirmAndSignOut() async {
    final confirmed = await _showSignOutConfirmation();
    if (confirmed) {
      // Add any cleanup logic here (e.g., clearing tokens or user data)
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => WinterArkHome()),
      );
    }
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
              padding: EdgeInsets.only(top: 0),
              children: [
                _buildSection("General", generalItems),
                _buildSection("Account", accountItems),
                _buildRoastNotificationLevel(),
              ],
            ),
          ),
          // Log Out Button now calls the confirmation prompt
          Padding(
            padding: const EdgeInsets.all(20),
            child: ElevatedButton.icon(
              icon: Icon(Icons.logout),
              label: Text('Log Out'),
              onPressed: _confirmAndSignOut,
              style: ElevatedButton.styleFrom(
                backgroundColor: frostBlue,
                foregroundColor: Colors.white,
                minimumSize: Size(double.infinity, 52),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                textStyle: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Custom header with a back button (goes to previous page, not sign out)
  Widget _buildCustomHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 48, 20, 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          IconButton(
            icon: Icon(Icons.arrow_back, color: frostBlue, size: 32),
            onPressed: () => Navigator.pop(context),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "WinterArk's Settings",
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: textSnow,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  "Welcome back, winter warrior — let’s personalize your grind.",
                  style: TextStyle(fontSize: 14, color: Colors.grey[400]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Streak Badge Widget fetching live data.
  Widget _buildStreakBadge() {
    return FutureBuilder<int>(
      future: ApiService.getUserStreak(widget.userId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container(
            decoration: BoxDecoration(
              color: cardGray,
              borderRadius: BorderRadius.circular(16),
            ),
            margin: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            padding: EdgeInsets.all(20),
            child: Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation(frostBlue),
              ),
            ),
          );
        }
        if (snapshot.hasError) {
          return Container(
            decoration: BoxDecoration(
              color: cardGray,
              borderRadius: BorderRadius.circular(16),
            ),
            margin: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            padding: EdgeInsets.all(20),
            child: Text(
              'Error loading streak.',
              style: TextStyle(color: Colors.red),
            ),
          );
        }
        final streakCount = snapshot.data ?? 0;
        double progressValue = (streakCount >= 10) ? 1.0 : streakCount / 10;
        return Container(
          decoration: BoxDecoration(
            color: cardGray,
            borderRadius: BorderRadius.circular(16),
          ),
          margin: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          padding: EdgeInsets.all(20),
          child: Row(
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 56,
                    height: 56,
                    child: CircularProgressIndicator(
                      value: progressValue,
                      strokeWidth: 5,
                      backgroundColor: Colors.grey[800],
                      valueColor: AlwaysStoppedAnimation(frostBlue),
                    ),
                  ),
                  Icon(Icons.local_fire_department, color: frostBlue, size: 28),
                ],
              ),
              SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '🔥 ${streakCount}-Day Streak!',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: textSnow,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'The ice never sleeps. You’re locked in.',
                      style: TextStyle(color: Colors.grey[400], fontSize: 14),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // Section Builder: If "Account" is tapped, navigates to Account Settings.
  Widget _buildSection(String title, List<_SettingsItem> items) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
            child: Text(
              title.toUpperCase(),
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.grey[500],
              ),
            ),
          ),
          ...items.map(
                (item) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: ListTile(
                contentPadding: EdgeInsets.symmetric(vertical: 4),
                leading: Icon(
                  item.icon,
                  color: item.highlight ? frostBlue : Colors.white70,
                ),
                title: Text(
                  item.label,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: item.highlight ? FontWeight.bold : FontWeight.normal,
                    color: item.highlight ? frostBlue : textSnow,
                  ),
                ),
                onTap: () {
                  if (item.label.toLowerCase() == "account") {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AccountSettingsPage(userId: widget.userId),
                      ),
                    );
                  } else {
                    // Handle other settings items if needed
                  }
                },
              ),
            ),
          ),
          SizedBox(height: 12),
        ],
      ),
    );
  }

  // Roast Notification Level Selector remains unchanged.
  Widget _buildRoastNotificationLevel() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
          child: Text(
            'ROAST NOTIFICATION LEVEL',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.grey[500],
            ),
          ),
        ),
        SizedBox(
          height: 42,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: 16),
            itemCount: roastLevels.length,
            itemBuilder: (context, index) {
              String roast = roastLevels[index];
              return Padding(
                padding: const EdgeInsets.only(right: 12.0),
                child: OutlinedButton(
                  onPressed: () {
                    setState(() {
                      selectedRoast = roast;
                    });
                  },
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(
                      color: selectedRoast == roast ? frostBlue : Colors.white24,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    foregroundColor: selectedRoast == roast ? frostBlue : Colors.white,
                  ),
                  child: Text(roast),
                ),
              );
            },
          ),
        ),
        SizedBox(height: 20),
      ],
    );
  }
}

class _SettingsItem {
  final IconData icon;
  final String label;
  final bool highlight;

  _SettingsItem({
    required this.icon,
    required this.label,
    this.highlight = false,
  });
}
