// workout_planner_lp.dart
import 'package:flutter/material.dart';
import 'workout_planner.dart';
import 'reuse_workout_page.dart';
import 'plan_future_workout.dart';
import 'button_effects/flash_press.dart';

class WorkoutTrackerLandingPage extends StatelessWidget {
  const WorkoutTrackerLandingPage({super.key});

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

  TextStyle glowingTextStyle(Color color) => TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: color,
        shadows: [
          Shadow(color: color.withOpacity(0.9), blurRadius: 12),
          Shadow(color: color.withOpacity(0.6), blurRadius: 24),
          Shadow(color: color.withOpacity(0.3), blurRadius: 36),
          Shadow(color: color.withOpacity(0.2), blurRadius: 48),
        ],
      );

  @override
  Widget build(BuildContext context) {
    double buttonSize = MediaQuery.of(context).size.width * 0.3;
    final babyBlue = const Color.fromARGB(255, 212, 242, 255); // #D6E2E8
    final aquamarine = const Color.fromARGB(255, 167, 223, 248); // #91C1D8
    final blueGrotto = const Color.fromARGB(255, 45, 178, 250); // #0070AC
    final navyBlue = const Color(0xFF003371); // #003371
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [],
        ),
        backgroundColor: Colors.black,
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Create New Workout Button
            FlashOnPress(
              glowColor: blueGrotto,
              flashColor: blueGrotto,
              flashDuration: Duration(milliseconds: 300),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const WorkoutTrackerScreen()),
                );
              },
              child: Container(
                width: buttonSize,
                height: buttonSize,
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    glowingIcon(Icons.add, blueGrotto, 32),
                    const SizedBox(height: 0),
                    Text('New Workout', style: glowingTextStyle(blueGrotto)),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FlashOnPress(
                  glowColor: aquamarine,
                  flashColor: aquamarine,
                  flashDuration: Duration(milliseconds: 300),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const PlanWorkoutPage()),
                    );
                  },
                  child: Container(
                    width: buttonSize,
                    height: buttonSize,
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        glowingIcon(Icons.event_note, aquamarine, 32),
                        const SizedBox(height: 0),
                        Text('Plan Workout',
                            style: glowingTextStyle(aquamarine)),
                        const SizedBox(height: 8),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 40),
                // Reuse Past Workout Button
                FlashOnPress(
                  glowColor: babyBlue,
                  flashColor: babyBlue,
                  flashDuration: Duration(milliseconds: 300),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const WorkoutReusePage()),
                    );
                  },
                  child: Container(
                    width: buttonSize,
                    height: buttonSize,
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        glowingIcon(Icons.history, babyBlue, 32),
                        const SizedBox(height: 0),
                        Text('Reuse Workout',
                            style: glowingTextStyle(babyBlue)),
                        const SizedBox(height: 8),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 60),
          ],
        ),
      ),
    );
  }
}
