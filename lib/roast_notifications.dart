// lib/roast_notifications_settings_page.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'button_effects/ui_helpers.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'background_tasks.dart';
import 'button_effects/flash_press.dart';

class RoastNotificationsSettingsPage extends StatefulWidget {
  const RoastNotificationsSettingsPage({super.key});

  @override
  _RoastNotificationsSettingsPageState createState() => _RoastNotificationsSettingsPageState();
}

class _RoastNotificationsSettingsPageState extends State<RoastNotificationsSettingsPage> {
  bool debugMode = true;
  bool roastEnabled = false;
  double roastIntensity = 0.5; 
  final babyBlue   = const Color.fromARGB(255, 212, 242, 255);  // #D6E2E8
  final aquamarine = const Color.fromARGB(255, 167, 223, 248);  // #91C1D8
  final blueGrotto = const Color.fromARGB(255, 45, 178, 250);  // #0070AC

  bool showExplicitRoasts = false;
  String explicitRoast = 'Lift or Get Lit the F*** Up 💪🔥';
  String selectedRoast = 'Soft Serve Roasts 🍦😋';
  final List<String> roastLevels = [
    'Soft Serve Roasts 🍦😋',
    'Funny But It Hurts 🤡💔',
    'Classy But Ruthless 🎩☠️',
    'Lift or Get Lit the F*** Up 💪🔥',
  ];

  bool _switchFlashing = false;
  Duration _switchFlashDuration = const Duration(milliseconds: 100);

  final Set<String> _flashingRoasts = {};
  final Duration _flashDuration = const Duration(milliseconds: 300);
  bool _isSwitchFlashing = false;
  void _clearSwitchFlash() {
    Future.delayed(_flashDuration, () {
      if (mounted) setState(() => _isSwitchFlashing = false);
    });
  }

  @override
  void initState() {
    super.initState();
    _loadSettings();
    _loadPrefs();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      roastEnabled = prefs.getBool('roastNotifications') ?? false;
      roastIntensity = prefs.getDouble('roastIntensity') ?? 0.5;
      selectedRoast  = prefs.getString('roastLevel') ?? roastLevels.first;
    });
  }

  Future<void> _updateSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('roastNotifications', roastEnabled);
    await prefs.setDouble('roastIntensity', roastIntensity);
    await prefs.setString('roastLevel', selectedRoast);
  }

  Future<void> _loadPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      showExplicitRoasts = prefs.getBool('showExplicitRoasts') ?? false;
    });
  }

  void _enableRoastNotifications() {
    setState(() {
      roastEnabled = true;
    });
    _updateSettings();
  }

  Widget glowingIcon(IconData icon, Color color, double size) {
    return Text(
      String.fromCharCode(icon.codePoint),
      style: TextStyle(
        fontFamily: icon.fontFamily,
        package: icon.fontPackage,
        fontSize: size,
        color: color,
        shadows: [
          Shadow(color: color.withOpacity(0.9), blurRadius: 12),
          Shadow(color: color.withOpacity(0.6), blurRadius: 24),
          Shadow(color: color.withOpacity(0.3), blurRadius: 36),
        ],
      ),
    );
  }

  TextStyle glowingTextStyle(Color color, {double size=16}) => TextStyle(
    fontSize: size,
    fontWeight: FontWeight.bold,
    color: color,
    shadows: [
      ...glowShadows(color, radii: [8,16,24]),
      BoxShadow(color: color.withOpacity(0.3), blurRadius: 36),
    ],
  );
  
  List<BoxShadow> glowShadows(
    Color baseColor, {
    List<double> radii = const [12, 24, 36],
    List<double>? opacities,
  }) {
    final count = radii.length;
    final alphas = opacities ??
        List.generate(count, (i) => 1.0 - (i * (1.0 / count))).toList();
    return List.generate(radii.length, (i) {
      return BoxShadow(
        color: baseColor.withOpacity(alphas[i].clamp(0.0, 1.0)),
        blurRadius: radii[i],
        offset: const Offset(0, 0),
      );
    });
  }

  Widget neonSwitchTile({
    required String label,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(color: Colors.white70, fontSize: 16),
        ),
        Transform.scale(
          scale: 1.3,
          child: Switch(
            activeColor: blueGrotto,
            inactiveThumbColor: Colors.grey[700],
            inactiveTrackColor: Colors.grey[800],
            value: value,
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }

  Widget _neonToggle({
    required String label,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label, style: glowingTextStyle(aquamarine, size: 18)),
        const SizedBox(width: 12),

        AnimatedContainer(
          duration: _flashDuration,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              if (value)
                BoxShadow(
                  color: blueGrotto.withOpacity(0.6),
                  blurRadius: 8,
                  spreadRadius: 2,
                ),

              if (_isSwitchFlashing) ...[
                BoxShadow(
                  color: Colors.white.withOpacity(0.9),
                  blurRadius: 16,
                  spreadRadius: 4,
                ),
                BoxShadow(
                  color: Colors.white.withOpacity(0.5),
                  blurRadius: 32,
                  spreadRadius: 8,
                ),
              ],
            ],
          ),
          child: Switch(
            value: value,
            inactiveTrackColor: Colors.black,
            activeColor: aquamarine,
            activeTrackColor: aquamarine.withOpacity(0.3),
            onChanged: (v) {
              onChanged(v);
              setState(() => _isSwitchFlashing = true);
              Future.delayed(_flashDuration, () {
                if (mounted) setState(() => _isSwitchFlashing = false);
              });
            },
          ),
        ),
      ],
    );
  }

  Widget _neonRoastChip(String roast) {
    final isSelected = roast == selectedRoast;
    final isFlashing = _flashingRoasts.contains(roast);

    final List<BoxShadow> shadows = [
      if (isSelected) ...glowShadows(blueGrotto, radii: [4,8,16]),
      if (isFlashing) ...[
        BoxShadow(color: Colors.white.withOpacity(0.8), blurRadius: 4, spreadRadius: 1),
        BoxShadow(color: Colors.white.withOpacity(0.4), blurRadius: 8, spreadRadius: 2),
      ],
    ];

    return GestureDetector(
      onTapDown:   (_) => setState(() => _flashingRoasts.add(roast)),
      onTapUp:     (_) {
        Future.delayed(_flashDuration, () {
          if (mounted) setState(() => _flashingRoasts.remove(roast));
        });
        setState(() => selectedRoast = roast);
        _updateSettings();
      },
      onTapCancel: () => setState(() => _flashingRoasts.remove(roast)),
      child: AnimatedContainer(
        decoration: BoxDecoration(
        color: (isSelected || isFlashing)
          ? blueGrotto.withOpacity(isSelected ? 1.0 : 0.2)
          : Colors.grey[900],
          borderRadius: BorderRadius.circular(20),
          boxShadow: shadows,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        duration: _flashDuration,
        child: Text(
          roast,
          style: TextStyle(
            color: isSelected ? Colors.black : Colors.white70,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildInstantRoastButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: FlashOnPress(
        glowColor: Colors.red,     
        flashColor: Colors.yellow,   
        onTap: _sendImmediateRoast, 
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(12),
            boxShadow: glowShadows(
              Colors.red,
              radii: [4, 8, 16],
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(width: 8),
              Text(
                "😡 Roast Me Now",
                style: glowingTextStyle(
                Colors.red,
                size:16,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _sendImmediateRoast() async {
    final prefs = await SharedPreferences.getInstance();
    final groups = prefs.getStringList('plannedMuscleGroups') ?? [];
    final level = prefs.getString('roastLevel') ?? roastLevels.first;
    final roastMessage = await getRandomRoastMessage(groups, selectedRoast);
    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: 999,
        channelKey: 'roast_notifications',
        title: '🔥 Roast Incoming!',
        body: roastMessage,
        notificationLayout: NotificationLayout.BigText, 
        color: Colors.deepOrangeAccent,  
        autoDismissible: true,
        displayOnBackground: true,
        displayOnForeground: true, 
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          glowingIcon(Icons.whatshot, blueGrotto, 28),
          const SizedBox(width: 8),
          Text(
            "Roast Notifications",
            style: glowingTextStyle(
              blueGrotto,
              size: 26,
            ),
          ),
        ],
      ),
        backgroundColor: Colors.black,
        centerTitle: true,
        leading: IconButton(
          icon: glowingIcon(Icons.arrow_back, babyBlue, 24),
          onPressed: () => Navigator.of(context).maybePop(),
          tooltip: 'Back',
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: AnimatedContainer(
          duration: Duration(milliseconds: 400),
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(12),
            boxShadow: roastEnabled
              ? glowShadows(blueGrotto, radii: [8,16,24])
              : [BoxShadow(color: Colors.white10, blurRadius:4)],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center, 
            children: [
              Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,      
                  children: [
                    Text(
                      "Enable Roasts",
                      style: glowingTextStyle(
                      aquamarine,
                      size:18,
                      ),
                    ),
                    _neonToggle(
                      label: "",
                      value: roastEnabled,
                      onChanged: (v) {
                        setState(() => roastEnabled = v);
                        _updateSettings();
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
              Center(child: Text("Intensity Level", style: glowingTextStyle(aquamarine, size:18))),
              const SizedBox(height: 12),
              Wrap(
                spacing: 200,
                runSpacing: 12,
                alignment: WrapAlignment.center,
                children: [
                  for (final level in roastLevels)
                    if (level != explicitRoast || showExplicitRoasts)
                      _neonRoastChip(level),
                ],
              ),
              const SizedBox(height: 40),
              if (debugMode)
                _buildInstantRoastButton(),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}
