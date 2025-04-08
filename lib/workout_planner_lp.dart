// workout_planner_lp.dart
import 'package:flutter/material.dart';
import 'workout_planner.dart';
import 'reuse_workout_page.dart';

class WorkoutTrackerLandingPage extends StatelessWidget {
  const WorkoutTrackerLandingPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Calculate button size based on screen width.
    double buttonSize = MediaQuery.of(context).size.width * 0.3;
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,  // Disable the automatic back arrow.
        title: const Text("Workout Tracker"),
      ),
      body: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Create New Workout Button
            InkWell(
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
                  color: Colors.grey[850],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.add, color: Colors.blue, size: 32),
                    SizedBox(height: 8),
                    Text(
                      "New Workout",
                      style: TextStyle(color: Colors.blue, fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 20),
            // Reuse Past Workout Button
            InkWell(
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
                  color: Colors.grey[850],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.history, color: Colors.green, size: 32),
                    SizedBox(height: 8),
                    Text(
                      "Reuse Workout",
                      style: TextStyle(color: Colors.green, fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
