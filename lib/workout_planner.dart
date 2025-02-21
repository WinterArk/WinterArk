// workout_planner.dart
// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';

class ExerciseEntry {
  final TextEditingController exerciseNameController = TextEditingController();
  final TextEditingController setsController = TextEditingController();
  final TextEditingController repsController = TextEditingController();
  final TextEditingController weightController = TextEditingController();
  final TextEditingController notesController = TextEditingController();

  bool showNotes = false;
  String weightUnit;
  ExerciseEntry({this.weightUnit = "lbs"});

  void dispose() {
    exerciseNameController.dispose();
    setsController.dispose();
    repsController.dispose();
    weightController.dispose();
    notesController.dispose();
  }
}

class WorkoutTrackerScreen extends StatefulWidget {
  static final GlobalKey<FormFieldState> workoutSplitKey = GlobalKey<FormFieldState>();
  const WorkoutTrackerScreen({super.key});
  
  @override
  _WorkoutTrackerScreenState createState() => _WorkoutTrackerScreenState();
}

class _WorkoutTrackerScreenState extends State<WorkoutTrackerScreen> {
  List<bool> daysSelected = [false, false, false, false, false, false, false];
  bool sendReminder = false;
  bool sendRoasts = false;
  DateTime? selectedDate;
  TimeOfDay? selectedTime;
  
  // New state variables for workout details
  final List<String> trainingStyles = ['strength', 'size', 'endurance', 'flexibility'];
  List<ExerciseEntry> exerciseEntries = [];
  String? selectedExerciseType;
  String? selectedTrainingStyle;

  List<String> workoutSplitOptions = [
  'Push',
  'Pull',
  'Legs',
  'Full Upper',
  'Full Lower',
  'Full Body',
  'Back',
  'Chest',
  'Shoulders',
  'Arms',
  'Core',
  'Custom'
  ];
  List<String> selectedWorkoutSplits = [];
  TextEditingController customWorkoutSplitController = TextEditingController();

  Future<String?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('userId');
  }
  
  @override
  void initState() {
    super.initState();
    // Start with one exercise entry.
    exerciseEntries.add(ExerciseEntry());
  }

  @override
  void dispose() {
    // Dispose all controllers for each entry.
    for (var entry in exerciseEntries) {
      entry.dispose();
    }
    super.dispose();
  }


Future<void> _submitWorkout() async {
  // Validate that at least one exercise entry is filled out.
  bool valid = false;
  for (var entry in exerciseEntries) {
    if (entry.exerciseNameController.text.trim().isNotEmpty &&
        entry.setsController.text.trim().isNotEmpty &&
        entry.repsController.text.trim().isNotEmpty &&
        entry.weightController.text.trim().isNotEmpty) {
      valid = true;
      break;
    }
  }
  if (!valid) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Please fill in at least one exercise completely.")),
    );
    return;
  }
  if (selectedWorkoutSplits.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Please select a workout split.")),
    );
    return;
  }
  if (selectedDate == null || selectedTime == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Please pick a date and time for your workout.")),
    );
    return;
  }

  // If Custom split is selected, Combine the selected workout splits into one string
  String workoutSplitValue;
  if (selectedWorkoutSplits.contains("Custom")) {
    List<String> splits = List.from(selectedWorkoutSplits);
    splits.remove("Custom");
    final customValue = customWorkoutSplitController.text.trim();
    if (customValue.isNotEmpty) {
      splits.add(customValue);
    }
    workoutSplitValue = splits.join(', ');
  } 
  else {
    workoutSplitValue = selectedWorkoutSplits.join(', ');
  }

  // Combine selected date and time into a DateTime object.
  final DateTime workoutDate = DateTime(
    selectedDate!.year,
    selectedDate!.month,
    selectedDate!.day,
    selectedTime!.hour,
    selectedTime!.minute,
  );

  final String? userId = await getUserId();
  if (userId == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("User not logged in.")),
    );
    return;
  }
  
  bool allSuccess = true;
  for (var entry in exerciseEntries) {
    // Skip incomplete entries.
    if (entry.exerciseNameController.text.trim().isEmpty ||
        entry.setsController.text.trim().isEmpty ||
        entry.repsController.text.trim().isEmpty ||
        entry.weightController.text.trim().isEmpty) {
      continue;
    }
    try {
      await ApiService.addWorkout(
        userId: userId,
        exerciseName: entry.exerciseNameController.text.trim(),
        exerciseType: workoutSplitValue,
        sets: int.parse(entry.setsController.text.trim()),
        reps: int.parse(entry.repsController.text.trim()),
        weight: double.parse(entry.weightController.text.trim()),
        weightUnit: entry.weightUnit,
        date: workoutDate,
        notes: entry.notesController.text.trim(),
        // trainingStyle: selectedTrainingStyle,
      );
    } catch (e) {
      allSuccess = false;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error adding an exercise: $e")),
      );
    }
  }

  if (allSuccess) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Workout added successfully!")),
    );
    setState(() {
      for (var entry in exerciseEntries) {
        entry.dispose();
      }
      exerciseEntries = [ExerciseEntry()];
      selectedWorkoutSplits.clear();
      customWorkoutSplitController.clear();
    });
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Workout Tracker"),
        backgroundColor: Colors.blueAccent,
        centerTitle: true,
      ),
      // Removed the bottomNavigationBar here so that HomePage’s nav bar is the only one.
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            const Center(
              child: Text(
                "Plan Your Workout",
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.blueAccent,
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Body Parts Buttons
            MultiSelectDialogField<String>(
              key: WorkoutTrackerScreen.workoutSplitKey,
              items: workoutSplitOptions
                  .map((option) => MultiSelectItem<String>(option, option))
                  .toList(),
              title: Center(
                child: const Text(
                  "Workout Split",
                  textAlign: TextAlign.center,
                ),
              ),
              itemsTextStyle: const TextStyle(color: Colors.white, fontSize: 16),
              selectedColor: Colors.blueAccent,
              decoration: BoxDecoration(
                color: Colors.grey[850],
                borderRadius: const BorderRadius.all(Radius.circular(12)),
                border: Border.all(
                  color: Colors.white70,
                  width: 1,
                ),
              ),
              buttonIcon: const Icon(
                Icons.arrow_drop_down,
                color: Colors.white,
              ),
              buttonText: Text.rich(
                TextSpan(
                  children: [
                    WidgetSpan(
                      child: SizedBox(width: MediaQuery.of(context).size.width * 0.27) 
                    ),
                    const TextSpan(
                      text: "Select Workout Split",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                textAlign: TextAlign.center,
              ),
              onConfirm: (results) {
                setState(() {
                  selectedWorkoutSplits = List<String>.from(results);
                });
              },
            ),
            if (selectedWorkoutSplits.contains("Custom"))
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: TextField(
                  controller: customWorkoutSplitController,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: "Custom Split",
                    labelStyle: TextStyle(color: Colors.white70),
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
            const SizedBox(height: 20),
            // Detailed Workout Input
            Column(
              children: [
                // Display each exercise entry form:
                Column(
                  children: exerciseEntries.map((entry) {
                    return Card(
                      color: Colors.grey[850],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      margin: const EdgeInsets.only(bottom: 12),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            TextField(
                              key: const Key('exercise-name'),
                              controller: entry.exerciseNameController,
                              style: const TextStyle(color: Colors.white),
                              decoration: const InputDecoration(
                                label: Center(
                                  child: Text(
                                    "Exercise Name",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(color: Colors.white70),
                                  ),
                                ),
                                border: OutlineInputBorder(),
                              ),
                            ),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                Expanded(
                                  flex: 2,
                                  child: TextField(
                                    key: const Key('exercise-sets'),
                                    controller: entry.setsController,
                                    keyboardType: TextInputType.number,
                                    style: const TextStyle(color: Colors.white),
                                    decoration: const InputDecoration(
                                      labelText: "Sets",
                                      labelStyle: TextStyle(color: Colors.white70),
                                      border: OutlineInputBorder(),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  flex: 2,
                                  child: TextField(
                                    key: const Key('exercise-reps'),
                                    controller: entry.repsController,
                                    keyboardType: TextInputType.number,
                                    style: const TextStyle(color: Colors.white),
                                    decoration: const InputDecoration(
                                      labelText: "Reps",
                                      labelStyle: TextStyle(color: Colors.white70),
                                      border: OutlineInputBorder(),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Row(
                                  children: [
                                    // Weight TextField with fixed width
                                    SizedBox(
                                      width: 90,
                                      child: TextField(
                                        key: const Key('exercise-weight'),
                                        controller: entry.weightController,
                                        keyboardType: TextInputType.number,
                                        style: const TextStyle(color: Colors.white),
                                        decoration: const InputDecoration(
                                          labelText: "Weight",
                                          labelStyle: TextStyle(color: Colors.white70),
                                          border: OutlineInputBorder(),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    // Weight unit dropdown with fixed width
                                    SizedBox(
                                      width: 50,
                                      child: DropdownButton<String>(
                                        key: const Key('weight-unit'),
                                        isExpanded: true,
                                        value: entry.weightUnit,
                                        dropdownColor: Colors.grey[800],
                                        style: const TextStyle(color: Colors.white, fontSize: 16),
                                        items: <String>["lbs", "kg"].map((String unit) {
                                          return DropdownMenuItem<String>(
                                            value: unit,
                                            child: Center(
                                              child: Text(
                                                unit,
                                                textAlign: TextAlign.center,
                                                style: const TextStyle(color: Colors.white),
                                              ),
                                            ),
                                          );
                                        }).toList(),
                                        onChanged: (String? newValue) {
                                          if (newValue != null) {
                                            setState(() {
                                              entry.weightUnit = newValue;
                                            });
                                          }
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  width: 30,
                                  child: IconButton(
                                    key: const Key('notes-toggle'),
                                    icon: Icon(
                                      entry.showNotes ? Icons.note : Icons.note_add,
                                      color: Colors.yellowAccent,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        entry.showNotes = !entry.showNotes;
                                      });
                                    },
                                  ),
                                ), 
                              ],
                            ),
                            if (entry.showNotes) 
                              Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: TextField(
                                  key: const Key('exercise-notes'),
                                  controller: entry.notesController,
                                  style: const TextStyle(color: Colors.white),
                                  decoration: const InputDecoration(
                                    label: Center(
                                      child: Text(
                                        "Notes",
                                        style: TextStyle(color: Colors.white70),
                                      ),
                                    ),
                                    border: OutlineInputBorder(),
                                  ),
                                  maxLines: 2,
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                // Plus button: add a new exercise entry
                IconButton(
                  icon: const Icon(Icons.add_circle, color: Colors.blueAccent, size: 32),
                  onPressed: () {
                    setState(() {
                      exerciseEntries.add(ExerciseEntry());
                    });
                  },
                ),
                // Minus button: remove the last entry if there is more than one
                IconButton(
                  icon: const Icon(Icons.remove_circle, color: Colors.red, size: 32),
                  onPressed: () {
                    setState(() {
                      if (exerciseEntries.length > 1) {
                        exerciseEntries.removeLast();
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("At least one exercise is required.")),
                        );
                      }
                    });
                  },
                ),
              ],
            ),
            // const SizedBox(height: 20),
            // // Dropdown for Training Style
            // DropdownButtonFormField<String>(
            //   value: selectedTrainingStyle,
            //   decoration: InputDecoration(
            //     labelText: 'Training Style',
            //     labelStyle: const TextStyle(color: Colors.white70),
            //     filled: true,
            //     fillColor: Colors.grey[850],
            //     border: OutlineInputBorder(
            //       borderRadius: BorderRadius.circular(12),
            //     ),
            //   ),
            //   dropdownColor: Colors.grey[850],
            //   style: const TextStyle(color: Colors.white),
            //   items: trainingStyles.map((style) {
            //     return DropdownMenuItem(
            //       value: style,
            //       child: Text(style),
            //     );
            //   }).toList(),
            //   onChanged: (value) {
            //     setState(() {
            //       selectedTrainingStyle = value;
            //     });
            //   },
            // ),
            // const SizedBox(height: 20),
            // // Date and Time Picker
            // const Text(
            //   "Schedule Workout",
            //   style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
            // ),
            const SizedBox(height: 10),
            Row(
              children: [
                // Date Picker Button
                Expanded(
                  child: ElevatedButton(
                    key: const Key('pick-date'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[800],
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () async {
                      DateTime? pickedDate = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2100),
                      );
                      if (pickedDate != null) {
                        setState(() {
                          selectedDate = pickedDate;
                        });
                      }
                    },
                    child: Text(
                      selectedDate == null
                          ? "Pick Date"
                          : "${selectedDate!.month}/${selectedDate!.day}/${selectedDate!.year}",
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                // Time Picker Button
                Expanded(
                  child: ElevatedButton(
                    key: const Key('pick-time'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[800],
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () async {
                      TimeOfDay? pickedTime = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.now(),
                      );
                      if (pickedTime != null) {
                        setState(() {
                          selectedTime = pickedTime;
                        });
                      }
                    },
                    child: Text(
                      selectedTime == null ? "Pick Time" : selectedTime!.format(context),
                    ),
                  ),
                ),
              ],
            ),
            // const SizedBox(height: 20),
            // // Reminder and Roasts Switches
            // Card(
            //   color: Colors.grey[850],
            //   shape: RoundedRectangleBorder(
            //     borderRadius: BorderRadius.circular(12),
            //   ),
            //   child: Column(
            //     children: [
            //       SwitchListTile(
            //         activeColor: Colors.blueAccent,
            //         title: const Text("Send Reminder?", style: TextStyle(color: Colors.white)),
            //         value: sendReminder,
            //         onChanged: (value) {
            //           setState(() {
            //             sendReminder = value;
            //           });
            //         },
            //       ),
            //       SwitchListTile(
            //         activeColor: Colors.blueAccent,
            //         title: const Text("Send Roasts?", style: TextStyle(color: Colors.white)),
            //         value: sendRoasts,
            //         onChanged: (value) {
            //           setState(() {
            //             sendRoasts = value;
            //           });
            //         },
            //       ),
            //     ],
            //   ),
            // ),
            const SizedBox(height: 20),
            // Submit Workout Button
            ElevatedButton(
              key: const Key('submit-workout'),
              onPressed: _submitWorkout,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 40),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text(
                "Submit Workout",
                style: TextStyle(color: Colors.black, fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
