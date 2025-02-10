// workout_planner.dart
import 'package:flutter/material.dart';
import 'api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WorkoutTrackerScreen extends StatefulWidget {
  const WorkoutTrackerScreen({Key? key}) : super(key: key);

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
  String? selectedExerciseType;
  String? selectedTrainingStyle;
  final TextEditingController _exerciseNameController = TextEditingController();
  final TextEditingController _setsController = TextEditingController();
  final TextEditingController _repsController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  Future<String?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('userId');
  }

  @override
  void dispose() {
    _exerciseNameController.dispose();
    _setsController.dispose();
    _repsController.dispose();
    _weightController.dispose();
    _notesController.dispose();
    super.dispose();
  }


  Future<void> _submitWorkout() async {
    // Validate that all required fields are filled
    if (selectedExerciseType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select an exercise type.")),
      );
      return;
    }
    if (_exerciseNameController.text.trim().isEmpty ||
        _setsController.text.trim().isEmpty ||
        _repsController.text.trim().isEmpty ||
        _weightController.text.trim().isEmpty ||
        selectedDate == null ||
        selectedTime == null
        // || selectedTrainingStyle == null
        ){
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill in all fields.")),
      );
      return;
    }

    // Combine the selected date and time into a DateTime object
    final DateTime workoutDate = DateTime(
      selectedDate!.year,
      selectedDate!.month,
      selectedDate!.day,
      selectedTime!.hour,
      selectedTime!.minute,
    );

    // Retrieve the currently logged in user ID from SharedPreferences
    final String? userId = await getUserId();
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("User not logged in.")),
      );
      return;
    }

    try {
      final result = await ApiService.addWorkout(
        userId: userId,
        exerciseName: _exerciseNameController.text.trim(),
        exerciseType: selectedExerciseType!,
        sets: int.parse(_setsController.text.trim()),
        reps: int.parse(_repsController.text.trim()),
        weight: double.parse(_weightController.text.trim()),
        date: workoutDate,
        notes: _notesController.text.trim(), 
        //trainingStyle: selectedTrainingStyle!, 
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Workout added successfully!")),
      );
      // Clear the fields after submission:
      setState(() {
        selectedExerciseType = null;
        //selectedTrainingStyle = null;
        _exerciseNameController.clear();
        _setsController.clear();
        _repsController.clear();
        _weightController.clear();
        _notesController.clear();
        //selectedDate = null;
        //selectedTime = null;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error adding workout: $e")),
      );
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
            Center(
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
            Wrap(
              spacing: 10,
              runSpacing: 10,
              alignment: WrapAlignment.center,
              children: [
                for (var bodyPart in ["Legs", "Back", "Chest", "Shoulders", "Arms", "Core"])
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: selectedExerciseType == bodyPart.toLowerCase()
                          ? Colors.blueAccent
                          : Colors.grey[800],
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    onPressed: () {
                      // Action for each button can be implemented here.
                      setState(() {
                        selectedExerciseType = bodyPart.toLowerCase();
                      });
                    },
                    child: Text(bodyPart),
                  ),
              ],
            ),
            const SizedBox(height: 20),
            // Detailed Workout Input
            Card(
              color: Colors.grey[850],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextField(
                  controller: _exerciseNameController,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: "Exercise Name",
                    labelStyle: TextStyle(color: Colors.white70),
                    border: OutlineInputBorder(),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.blueAccent),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Fields for Sets, Reps, and Weight
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _setsController,
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
                  child: TextField(
                    controller: _repsController,
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
                Expanded(
                  child: TextField(
                    controller: _weightController,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      labelText: "Weight",
                      labelStyle: TextStyle(color: Colors.white70),
                      border: OutlineInputBorder(),
                    ),
                  ),
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
            // Text field for Notes
            Card(
              color: Colors.grey[850],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextField(
                  controller: _notesController,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: "Notes",
                    labelStyle: TextStyle(color: Colors.white70),
                    border: OutlineInputBorder(),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.blueAccent),
                    ),
                  ),
                  maxLines: 3,
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Submit Workout Button
            ElevatedButton(
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
