// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'api_service.dart';
import 'package:intl/intl.dart';

// Helper function to convert month/day to YYYY-MM-DD format.
String getDateString(String monthName, int day) {
  final currentYear = DateTime.now().year;
  final monthsMap = {
    "January": "01",
    "February": "02",
    "March": "03",
    "April": "04",
    "May": "05",
    "June": "06",
    "July": "07",
    "August": "08",
    "September": "09",
    "October": "10",
    "November": "11",
    "December": "12",
  };

  final monthNum = monthsMap[monthName] ?? "01";
  final dayStr = day.toString().padLeft(2, '0');
  return "$currentYear-$monthNum-$dayStr";
}

Future<String?> getUserId() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString('userId');
}

class PastWorkoutsCalendar extends StatefulWidget {
  final String? buddyId;
  final String? buddyName;
  // const PastWorkoutsCalendar({Key? key}) : super(key: key);
  const PastWorkoutsCalendar({
    Key? key,
    this.buddyId, // if null, it might mean "my workouts"
    this.buddyName,
  }) : super(key: key);

  @override
  _PastWorkoutsCalendarState createState() => _PastWorkoutsCalendarState();
}

class _PastWorkoutsCalendarState extends State<PastWorkoutsCalendar> {

  final List<Map<String, dynamic>> months = const [
    {"name": "January", "days": 31},
    {"name": "February", "days": 28},
    {"name": "March", "days": 31},
    {"name": "April", "days": 30},
    {"name": "May", "days": 31},
    {"name": "June", "days": 30},
    {"name": "July", "days": 31},
    {"name": "August", "days": 31},
    {"name": "September", "days": 30},
    {"name": "October", "days": 31},
    {"name": "November", "days": 30},
    {"name": "December", "days": 31},
  ];

  void _showWorkoutsForDate(BuildContext context, String monthName, int day) async {
    // day++;
    final dateStr = getDateString(monthName, day);
    // Use buddyId if provided; otherwise, use the current user's id.
    final String? userId = widget.buddyId ?? await getUserId();
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("User not logged in.")),
      );
      return;
    }
    try {
      final workouts = await ApiService.getWorkoutsForDay(userId, dateStr);
      showModalBottomSheet(
        context: context,
        backgroundColor: Colors.black,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        builder: (BuildContext context) {
          return Padding(
            padding: const EdgeInsets.all(20.0),
            child: workouts.isEmpty
                ? const Center(
                    child: Text(
                      'No workouts recorded for this day.',
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                  )
                : ListView.builder(
                    itemCount: workouts.length,
                    itemBuilder: (context, index) {
                      final workout = workouts[index];
                      final utcDate = DateTime.parse(workout['date'] as String);
                      // final localDate = utcDate.toLocal();
                      // Format the time portion using intl's DateFormat.jm()
                      final String timeStr = DateFormat.jm().format(utcDate);
                      // Build the basic details string
                      final String details = "${workout['exercise_type']} - ${workout['sets']} sets x ${workout['reps']} reps, ${workout['weight']} ${workout['weightUnit']} at $timeStr";
                      // If notes exist and are not empty, add them on a new line
                      final String notes = (workout['notes'] != null && workout['notes'].toString().trim().isNotEmpty)
                          ? "\n${workout['notes']}"
                          : "";
                      return ListTile(
                        title: Text(
                          workout['exercise_name'] ?? "Unknown Exercise",
                          style: const TextStyle(color: Colors.white),
                        ),
                        subtitle: Text(
                          details + notes,
                          style: const TextStyle(color: Colors.white70),
                        ),
                        // Open the options dialog
                        onTap: widget.buddyId == null
                            ? () => _showWorkoutOptions(context, workout)
                            : null,                        
                      );
                    },
                  ),
          );
        },
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error fetching workouts: $e")),
      );
    }
  }

  void _showWorkoutOptions(BuildContext context, Map<String, dynamic> workout) {
  // Create controllers pre-filled with the current values
  final TextEditingController exerciseNameController = TextEditingController(text: workout['exercise_name']);
  final TextEditingController setsController = TextEditingController(text: workout['sets'].toString());
  final TextEditingController repsController = TextEditingController(text: workout['reps'].toString());
  final TextEditingController weightController = TextEditingController(text: workout['weight'].toString());
  String localWeightUnit = workout['weightUnit'] ?? 'lbs';
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Edit Workout"),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: exerciseNameController,
                  decoration: const InputDecoration(labelText: "Exercise Name"),
                ),
                TextField(
                  controller: setsController,
                  decoration: const InputDecoration(labelText: "Sets"),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: repsController,
                  decoration: const InputDecoration(labelText: "Reps"),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: weightController,
                  decoration: const InputDecoration(labelText: "Weight"),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 10),
                Row(
                    children: [
                      const Text("Unit: "),
                      DropdownButton<String>(
                        value: localWeightUnit,
                        dropdownColor: Colors.grey[800],
                        style: const TextStyle(color: Colors.white),
                        items: <String>["lbs", "kg"].map((String unit) {
                          return DropdownMenuItem<String>(
                            value: unit,
                            child: Text(unit),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          if (newValue != null) {
                            setState(() {
                              localWeightUnit = newValue;
                            });
                          }
                        },
                      ),
                    ],
                  ),
              ],
            ),
          ),
          actions: [
            // Delete button
            TextButton(
              onPressed: () async {
                try {
                  await ApiService.deleteWorkout(workout['_id']);
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Workout deleted successfully.")),
                  );
                  // Refresh the workouts list here.
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Failed to delete workout: $e")),
                  );
                }
              },
              child: const Text("Delete", style: TextStyle(color: Colors.red)),
            ),
            // Update button
            TextButton(
              onPressed: () async {
                final updateData = {
                  "exercise_name": exerciseNameController.text.trim(),
                  "sets": int.tryParse(setsController.text.trim()),
                  "reps": int.tryParse(repsController.text.trim()),
                  "weight": double.tryParse(weightController.text.trim()),
                  "weightUnit": localWeightUnit,
                };

                try {
                  await ApiService.updateWorkout(workout['_id'], updateData);
                  Navigator.of(context).pop(); // Close the dialog
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Workout updated successfully.")),
                  );
                  // Refresh the workouts list here.
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Failed to update workout: $e")),
                  );
                }
              },
              child: const Text("Update"),
            ),
          ],
        );
      },
    );
  }

  bool _isToday(int monthIndex, int day) {
    DateTime today = DateTime.now();
    // Check if the current month and day match the given month and day
    return today.month == (monthIndex + 1) && today.day == day;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(
          widget.buddyName != null
              ? '${widget.buddyName}\'s Past Workouts'
              : 'Past Workouts',
          style: const TextStyle(color: Colors.lightBlue),
        ),
        centerTitle: true,
      ),
      body: ListView.builder(
        itemCount: months.length,
        itemBuilder: (context, index) {
          final month = months[index];
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Month Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Text(
                  month['name'],
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.lightBlue,
                  ),
                ),
              ),
              // Days Grid
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Wrap(
                  spacing: 8.0,
                  runSpacing: 8.0,
                  children: List.generate(month['days'], (dayIndex) {
                    final isToday = _isToday(index, dayIndex + 1);

                    return GestureDetector(
                      onTap: () => _showWorkoutsForDate(
                        context,
                        month['name'], dayIndex + 1
                      ),
                      child: Container(
                        width: 40,
                        height: 40,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: isToday
                              ? Colors.lightBlue
                              : Colors.grey[900],
                          borderRadius: BorderRadius.circular(5),
                          border: isToday
                              ? Border.all(color: Colors.white, width: 2)
                              : null,
                        ),
                        child: Text(
                          '${dayIndex + 1}',
                          style: TextStyle(
                            fontSize: 16,
                            color: isToday ? Colors.black : Colors.white,
                            fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ),
              const SizedBox(height: 16),
            ],
          );
        },
      ),
    );
  }
}