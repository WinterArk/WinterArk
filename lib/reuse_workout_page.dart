// workout_reuse_page.dart
import 'package:flutter/material.dart';
import 'workout_planner.dart';
import 'api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

class WorkoutReusePage extends StatefulWidget {
  const WorkoutReusePage({super.key});

  @override
  _WorkoutReusePageState createState() => _WorkoutReusePageState();
}

class _WorkoutReusePageState extends State<WorkoutReusePage> {
  List<Map<String, dynamic>> pastWorkouts = [];
  Map<String, List<Map<String, dynamic>>> workoutsByDate = {};
  Future<String?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('userId');
  }

  @override
  void initState() {
    super.initState();
    _fetchPastWorkouts();
  }

  Future<void> _fetchPastWorkouts() async {
    try {
      // Assume ApiService.getWorkouts(userId) returns a List of workouts.
      // Replace "yourUserId" with the actual user id from shared_preferences.
      final String? userId = await getUserId();
      if (userId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("User not logged in.")),
        );
        return;
      }
      List<dynamic> allWorkouts = await ApiService.getPastWorkouts(userId);
      Map<String, List<Map<String, dynamic>>> grouped = {};
      for (var workout in allWorkouts) {
        DateTime dt = DateTime.parse(workout['date']);
        String key = DateFormat('yyyy-MM-dd').format(dt);
        if (!grouped.containsKey(key)) {
          grouped[key] = [];
        }
        grouped[key]!.add(workout);
      }
      setState(() {
        workoutsByDate = grouped;
      });
    } catch (e) {
      print("Error fetching workouts: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error fetching workouts: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Get a sorted list of dates.
    List<String> dates = workoutsByDate.keys.toList();
    return Scaffold(
      appBar: AppBar(title: const Text("Reuse Past Workout")),
      body: dates.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: dates.length,
              itemBuilder: (context, index) {
                String dateKey = dates[index];
                List<Map<String, dynamic>> dayWorkouts = workoutsByDate[dateKey]!;
                // For a summary, we take the workout split from the first workout entry (if available)
                String workoutSplit = dayWorkouts.isNotEmpty ? dayWorkouts.first['exercise_type'] : "";
                return ListTile(
                  key: Key("reuse-day-$dateKey"),
                  title: Text(workoutSplit),
                  subtitle: Text(dateKey),
                  trailing: const Icon(Icons.keyboard_arrow_right),
                  onTap: () {
                    // Navigate to the Workout Tracker with the prefilled workouts for that day.
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => WorkoutTrackerScreen(prefillWorkouts: dayWorkouts),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}