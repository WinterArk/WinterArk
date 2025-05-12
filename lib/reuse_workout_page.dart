// workout_reuse_page.dart
import 'package:flutter/material.dart';
import 'workout_planner.dart';
import 'api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'button_effects/flash_press.dart';
import 'button_effects/ui_helpers.dart';

class WorkoutReusePage extends StatefulWidget {
  const WorkoutReusePage({super.key});

  @override
  _WorkoutReusePageState createState() => _WorkoutReusePageState();
}

class _WorkoutReusePageState extends State<WorkoutReusePage> {
  List<Map<String, dynamic>> pastWorkouts = [];
  Map<String, List<Map<String, dynamic>>> workoutsByDate = {};
  final Set<String> _expandedDates = {};
  final babyBlue   = const Color.fromARGB(255, 212, 242, 255);  // #D6E2E8
  final aquamarine = const Color.fromARGB(255, 167, 223, 248);  // #91C1D8
  final blueGrotto = const Color.fromARGB(255, 45, 178, 250);  // #0070AC
  final navyBlue   = const Color(0xFF003371);  // #003371

  Set<String> _flashingRows = {};
  Duration _flashDuration = const Duration(milliseconds: 300);

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
      final String? userId = await getUserId();
      if (userId == null) {
        showShortFadeSnack(context, "User not logged in.");
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
      showShortFadeSnack(context, "Error fetching workouts: $e");
    }
  }

  String prettifySplitList(String raw) {
    final parts = raw
        .split(',')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();

    final capped = parts.map((s) {
      return s[0].toUpperCase() + s.substring(1);
    }).toList();

    if (capped.length > 1) {
      final allButLast = capped.sublist(0, capped.length - 1).join(', ');
      final last = capped.last;
      return '$allButLast and $last';
    } else if (capped.isNotEmpty) {
      return capped.first;
    } else {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final dates = workoutsByDate.keys.toList()..sort((a, b) => b.compareTo(a));
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: glowingIcon(Icons.arrow_back, babyBlue, 24),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            glowingIcon(Icons.history, babyBlue, 28),
            const SizedBox(width: 8),
            Text("Reuse Your Workout!", style: glowingTextStyle(babyBlue, size: 24)),
          ],
        ),
        backgroundColor: Colors.black,
        centerTitle: true,
      ),
      body: dates.isEmpty
        ? const Center(child: CircularProgressIndicator())
        : ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 16),
        itemCount: dates.length,
        itemBuilder: (ctx, dateIdx) {
          final dateKey   = dates[dateIdx];
          final workouts  = workoutsByDate[dateKey]!;

          return Padding(
            padding: const EdgeInsets.only(bottom: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    DateFormat.yMMMMd().format(DateTime.parse(dateKey)),
                    style: glowingTextStyle(babyBlue, size:18).copyWith(
                      shadows: glowShadows(babyBlue, radii:[4,8,12]),
                    ),
                  ),
                ),
                const SizedBox(height: 15),

                ...workouts.asMap().entries.map((e) {
                  final wkIdx = e.key;
                  final wk    = e.value;
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
                    child: FlashOnPress(
                      glowColor: aquamarine,
                      flashColor: aquamarine,
                      onTap: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (_) => WorkoutTrackerScreen(prefillWorkouts: workouts),
                          ),
                        );
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: glowShadows(babyBlue, radii: [4]).map((s) =>
                          BoxShadow(color: s.color.withOpacity(1), blurRadius: s.blurRadius, spreadRadius: s.spreadRadius)
                        ).toList(),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                        child: Row(
                          children: [
                            glowingIcon(Icons.fitness_center, babyBlue, 20),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                prettifySplitList(wk['exercise_type'] ?? "",),
                                style: const TextStyle(color: Colors.white70, fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                            ),
                            const SizedBox(width: 8),
                            glowingIcon(Icons.keyboard_arrow_right, babyBlue, 24),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
                const SizedBox(height: 12),
              ],
            ),
          );
        },
      ),
    );
  }
}