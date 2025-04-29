import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';
import 'package:intl/intl.dart';
import 'package:timezone/timezone.dart' as tz;
import 'api_service.dart';
import 'workout_reminders.dart'; 
import 'roast_notifications.dart'; 
import 'package:awesome_notifications/awesome_notifications.dart';
import 'dart:math';
import 'package:workmanager/workmanager.dart';

class PlanWorkoutPage extends StatefulWidget {
  const PlanWorkoutPage({Key? key}) : super(key: key);

  @override
  _PlanWorkoutPageState createState() => _PlanWorkoutPageState();
}

class _PlanWorkoutPageState extends State<PlanWorkoutPage> {
  final TextEditingController workoutNameController = TextEditingController();
  List<String> selectedMuscleGroups = [];
  DateTime? scheduledDate;
  TimeOfDay? scheduledTime;
  bool roastEnabled = false;

  @override
  void initState() {
    super.initState();
    _loadRoastSetting();
  }

  Future<String?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('userId');
  }

  DateTime? getScheduledDateTime() {
    if (scheduledDate != null && scheduledTime != null) {
      return DateTime(
        scheduledDate!.year,
        scheduledDate!.month,
        scheduledDate!.day,
        scheduledTime!.hour,
        scheduledTime!.minute,
      );
    }
    return null;
  }

  Future<void> _loadRoastSetting() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      roastEnabled = prefs.getBool('roastNotifications') ?? false;
    });
  }

  Future<void> _submitPlannedWorkout() async {
    final userId = await getUserId();
    if (userId == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("User not logged in.")));
      return;
    }
    if (workoutNameController.text.isEmpty ||
        selectedMuscleGroups.isEmpty ||
        getScheduledDateTime() == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Please complete all fields.")));
      return;
    }

    try {
      _storePlannedWorkoutSettings(workoutNameController.text.trim(), getScheduledDateTime().toString(), selectedMuscleGroups, roastEnabled);
      await ApiService.addPlannedWorkout(
        userId: userId,
        workoutName: workoutNameController.text.trim(),
        muscleGroups: selectedMuscleGroups,
        scheduledDatetime: getScheduledDateTime()!,
        roastEnabled: roastEnabled,
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Planned workout created successfully.")),
      );
      // Schedule the background task for roast notifications.
      await Workmanager().registerOneOffTask(
        "roast_notification_task", 
        "roastNotificationTask",   
        // set to 1 minutes for immediate testing; change to 24 hours for production
        initialDelay: const Duration(hours: 24),  
        inputData: {},
      );
    } 
  
    catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Error: $e")));
    }
    
  }

  Future<void> _storePlannedWorkoutSettings(String workoutName, String workoutDateIso, List<String> muscleGroups, bool roastEnabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('plannedWorkoutName', workoutName);
    await prefs.setString('plannedWorkoutDate', workoutDateIso);
    await prefs.setStringList('plannedMuscleGroups', muscleGroups);
    await prefs.setBool('plannedRoastEnabled', roastEnabled);
  }

  @override
  void dispose() {
    workoutNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Workout Planner"),
        backgroundColor: const Color.fromARGB(255, 253, 180, 225),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            const Center(
              child: Text(
                "Plan Your Workout",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(255, 253, 180, 225),
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Workout Name
            TextField(
              controller: workoutNameController,
              decoration: const InputDecoration(
                label: Center(
                  child: Text(
                    "Workout Name",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white70),
                  ),
                ),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            MultiSelectDialogField<String>(
              items: [
                MultiSelectItem('Chest', 'Chest'),
                MultiSelectItem('Shoulders', 'Shoulders'),
                MultiSelectItem('Arms', 'Arms'),
                MultiSelectItem('Back', 'Back'),
                MultiSelectItem('Legs', 'Legs'),
                MultiSelectItem('Core', 'Core'),
              ],
              itemsTextStyle: const TextStyle(color: Colors.white, fontSize: 16),
              title: const Text("Select Muscle Groups"),
              selectedColor: Colors.blueAccent,
              decoration: BoxDecoration(
                color: Colors.grey[850],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.black, width: 1),
              ),
              buttonText: Text.rich(
                TextSpan(
                  children: [
                    WidgetSpan(
                      child: SizedBox(width: MediaQuery.of(context).size.width * 0.2) 
                    ),
                    const TextSpan(
                      text: "What muscle are you hitting?",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                textAlign: TextAlign.center,
              ),
              onConfirm: (selected) {
                selectedMuscleGroups = selected;
              },
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const WorkoutReminderSettingsPage()),
                );
              },
              child: const Text("Want a Workout Reminder?"),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const RoastNotificationsSettingsPage()),
                );
              },
              child: const Text("Do you want to be roasted?"),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      final pickedDate = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2100),
                      );
                      if (pickedDate != null) {
                        setState(() {
                          scheduledDate = pickedDate;
                        });
                      }
                    },
                    child: Text(scheduledDate == null
                        ? "Pick Date"
                        : "${scheduledDate!.month}/${scheduledDate!.day}/${scheduledDate!.year}"),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      final pickedTime = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.now(),
                      );
                      if (pickedTime != null) {
                        setState(() {
                          scheduledTime = pickedTime;
                        });
                      }
                    },
                    child: Text(scheduledTime == null ? "Pick Time" : scheduledTime!.format(context)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            // Submit button
            ElevatedButton(
              onPressed: _submitPlannedWorkout,
              style: ElevatedButton.styleFrom(
                backgroundColor: Color.fromARGB(255, 253, 180, 225),
                padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 40),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text(
                "Submit Planned Workout",
                style: TextStyle(color: Colors.black, fontSize: 16),

              ),
            ),
          ],
        ),
      ),
    );
  }
}
