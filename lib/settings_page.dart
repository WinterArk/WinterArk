import 'package:flutter/material.dart';
import 'winterark_home.dart';
import 'account_settings.dart';
import 'notification_settings.dart';
import 'api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'button_effects/ui_helpers.dart';

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
    _SettingsItem(icon: Icons.logout, label: 'Log out', iconColor: Colors.redAccent,
    textColor: Colors.redAccent),
  ];

  Future<bool> _showSignOutConfirmation() async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,                   
      builder: (_) => AlertDialog(
        backgroundColor: Colors.grey[900],         
        shape: RoundedRectangleBorder(             
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          "Log out of Winter Ark?",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: Colors.white,
            // optional glow:
            shadows: glowShadows(aquamarine, radii: [8,16,24]),
          ),
        ),
        actionsAlignment: MainAxisAlignment.center,
        actionsPadding: const EdgeInsets.only(bottom: 12),
        actions: [
          TextButton(
            style: TextButton.styleFrom(
              foregroundColor: Colors.white,        
            ),
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          const SizedBox(width: 16),
          TextButton(
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,          
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Sign Out"),
          ),
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
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            glowingIcon(Icons.settings, textSnow, 28),
            const SizedBox(width: 8),
            Text(
              "WinterArk’s Settings",
              style: glowingTextStyle(
                textSnow,
                size: 26,
              ),
            ),
          ],
        ),
        backgroundColor: Colors.black,
        centerTitle: true,
        leading: IconButton(
          icon: glowingIcon(Icons.arrow_back, textSnow, 24),
          onPressed: () => Navigator.of(context).maybePop(),
          tooltip: 'Back',
        ),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(40),
          child: Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Text(
              "Welcome back, winter warrior — let’s personalize your grind.",
              style: TextStyle(fontSize: 14, color: Colors.grey[400]),
            ),
          ),
        ), 
      ),
      backgroundColor: Colors.black,
      body: Column(
        children: [
          // _buildCustomHeader(),
          _buildStreakBadge(),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _buildSection('GENERAL', generalItems),
                _buildSection('ACCOUNT', accountItems),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomHeader() => Padding(
    padding: const EdgeInsets.fromLTRB(20, 48, 20, 12),
    child: Stack(
      alignment: Alignment.center,
      children: [
        // 1) back arrow at left
        Align(
          alignment: Alignment.centerLeft,
          child: IconButton(
            icon: glowingIcon(Icons.arrow_back, babyBlue, 25),
            onPressed: () => Navigator.pop(context),
          ),
        ),

        // 2) title + subtitle centered
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "WinterArk’s Settings",
              style: glowingTextStyle(textSnow, size: 26),
            ),
            const SizedBox(height: 20),
            Text(
              "Welcome back, winter warrior — let’s personalize your grind.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey[400]),
            ),
          ],
        ),

        // 3) phantom widget on right to balance the arrow
        Align(
          alignment: Alignment.centerRight,
          child: SizedBox(width: 48),
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

  Widget _streakContainer({ required Widget child }) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 0, 16),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.black,               
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.symmetric(
          vertical: 20,
          horizontal: 0,                      
        ),
        child: child,
      ),
    );
  }

  Widget _buildSection(String title, List<_SettingsItem> items) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 8),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Text(title, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.grey[500]!)),
        ),
        ...items.map((item) {
          final isLogout = item.label.toLowerCase() == 'log out';
          final iconColor = item.iconColor ??
              (item.highlight ? frostBlue : Colors.white70);
          final textColor = item.textColor ??
              (item.highlight ? frostBlue : textSnow);

          return ListTile(
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            leading: Icon(item.icon, color: iconColor),
            title: Text(
              item.label,
              style: TextStyle(
                color: textColor,
                fontWeight:
                    item.highlight ? FontWeight.bold : FontWeight.normal,
                fontSize: 16,
              ),
            ),
            onTap: () {
              if (isLogout) {
                _confirmAndSignOut();
              } else if (item.label.toLowerCase() == 'account') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        AccountSettingsPage(userId: widget.userId),
                  ),
                );
              } else if (item.label.toLowerCase() == 'notifications') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const NotificationSettingsPage(),
                  ),
                );
              }
            },
          );
        }),
      ],
    ),
  );

}

class _SettingsItem {
  final IconData icon;
  final String label;
  final bool highlight;
  final Color? iconColor;   
  final Color? textColor;

  const _SettingsItem({
    required this.icon,
    required this.label,
    this.highlight = false,
    this.iconColor,
    this.textColor,
  });
}
