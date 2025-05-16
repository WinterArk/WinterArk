// workout_planner.dart
// ignore_for_file: prefer_const_constructors
import 'package:flutter/material.dart';
import 'api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'button_effects/ui_helpers.dart';

class ExerciseEntry {
  final TextEditingController exerciseNameController = TextEditingController();
  final TextEditingController setsController = TextEditingController();
  final TextEditingController repsController = TextEditingController();
  final TextEditingController weightController = TextEditingController();
  final TextEditingController notesController = TextEditingController();

  bool showNotes = false;
  String weightUnit;

  ExerciseEntry({
    this.weightUnit = "Lbs",
  });
  void dispose() {
    exerciseNameController.dispose();
    setsController.dispose();
    repsController.dispose();
    weightController.dispose();
    notesController.dispose();
  }
}

class WorkoutTrackerScreen extends StatefulWidget {
  final List<Map<String, dynamic>>? prefillWorkouts;
  static final GlobalKey<FormFieldState> workoutSplitKey = GlobalKey<FormFieldState>();

  const WorkoutTrackerScreen({super.key, this.prefillWorkouts});

  
  
  @override
  _WorkoutTrackerScreenState createState() => _WorkoutTrackerScreenState();
}

class _WorkoutTrackerScreenState extends State<WorkoutTrackerScreen> {
  List<bool> daysSelected = [false, false, false, false, false, false, false];
  bool sendReminder = false;
  bool sendRoasts = false;
  DateTime? selectedDate;
  TimeOfDay? selectedTime;
  
  final List<String> trainingStyles = ['strength', 'size', 'endurance', 'flexibility'];
  List<ExerciseEntry> exerciseEntries = [];
  String? selectedExerciseType;
  String? selectedTrainingStyle;
  final blueGrotto = const Color.fromARGB(255, 45, 178, 250); 
  final aquamarine = const Color.fromARGB(255, 167, 223, 248); 
  final babyBlue   = const Color.fromARGB(255, 212, 242, 255);
  
  bool _addFlashing = false;

  static const _flashDuration = Duration(milliseconds: 300);
  final Set<String> _flashingSplits = {};

  void _flashAddButton() {
    setState(() => _addFlashing = true);
    Future.delayed(_flashDuration, () {
      if (mounted) setState(() => _addFlashing = false);
    });
  }
  
  void _flashChip(String split) {
    setState(() => _flashingSplits.add(split));
    Future.delayed(_flashDuration, () {
      if (!mounted) return;
      setState(() => _flashingSplits.remove(split));
    });
  }
  List<String> workoutSplitOptions = [
  'Legs',
  'Back',
  'Core',
  'Delts',
  'Arms',
  'Chest',
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
    if (widget.prefillWorkouts != null && widget.prefillWorkouts!.isNotEmpty) {
      String rawSplit = widget.prefillWorkouts!.first['exercise_type'] ?? "";
      List<String> splits = rawSplit
          .split(',')
          .map((s) => s.trim())
          .where((s) => s.isNotEmpty)
          .toList();
      final List<String> predefined = workoutSplitOptions
          .map((s) => s.toLowerCase())
          .toList();
      bool hasCustom = splits.any((s) => !predefined.contains(s.toLowerCase()));
      if (hasCustom) {
        selectedWorkoutSplits = ["Custom"];
        customWorkoutSplitController.text = splits.join(', ');
      } else {
        selectedWorkoutSplits =
            splits.map((s) => s[0].toUpperCase() + s.substring(1).toLowerCase()).toList();
      }
      
      for (var workout in widget.prefillWorkouts!) {
        ExerciseEntry entry = ExerciseEntry();
        entry.exerciseNameController.text = workout['exercise_name'] ?? "";
        entry.setsController.text = workout['sets']?.toString() ?? "";
        entry.repsController.text = workout['reps']?.toString() ?? "";
        entry.weightController.text = workout['weight']?.toString() ?? "";
        entry.notesController.text = workout['notes'] ?? "";
        entry.weightUnit = workout['weightUnit'] ?? "Lbs";
        exerciseEntries.add(entry);
      }
    } else {
      exerciseEntries.add(ExerciseEntry());
    }
  }

  @override
  void dispose() {
    customWorkoutSplitController.dispose();
    for (var entry in exerciseEntries) {
      entry.dispose();
    }
    super.dispose();
  }


Future<void> _submitWorkout() async {
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
    showShortFadeSnack(context, "Please fill in at least one exercise completely.");
    return;
  }
  if (selectedWorkoutSplits.isEmpty) {
    showShortFadeSnack(context, "Please select a workout split.");
    return;
  }

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

  final DateTime workoutDate = DateTime.now();

  final String? userId = await getUserId();
  if (userId == null) {
    showShortFadeSnack(context, "User not logged in.");
    return;
  }
  
  bool allSuccess = true;
  for (var entry in exerciseEntries) {
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
        weightUnit: entry.weightUnit.trim().toLowerCase(),
        date: workoutDate,
        notes: entry.notesController.text.trim(),
      );
    } catch (e) {
      allSuccess = false;
      showShortFadeSnack(context, "Error adding an exercise: $e");
    }
  }

  if (allSuccess) {
    try {
      await ApiService.updateStreak(userId, workoutDate.toIso8601String());
      print("Streak updated successfully.");
    } 
    catch (e) {
      print("Error updating streak: $e");
    }
    showShortFadeSnack(context, "Workout added successfully!");
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

  Widget _splitChip(String split) {
    final isSelected = selectedWorkoutSplits.contains(split);
    final isFlashing = _flashingSplits.contains(split);

    List<BoxShadow>? shadows;
    if (isSelected || isFlashing) {
      shadows = [
        ...glowShadows(blueGrotto, radii: [4, 8, 16]),
        if (isFlashing) ...[
          BoxShadow(
            color: Colors.white.withOpacity(0.8),
            blurRadius: 8,
            spreadRadius: 2,
          ),
          BoxShadow(
            color: Colors.white.withOpacity(0.4),
            blurRadius: 16,
            spreadRadius: 4,
          ),
        ]
      ];
    }

    return AnimatedContainer(
      duration: _flashDuration,
      curve: Curves.easeOut,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: shadows,
      ),
      child: ChoiceChip(
        label: Text(
          split,
          style: TextStyle(
            fontSize: 16,
            color: isSelected ? Colors.black : Colors.white70,
          ),
        ),
        selected: isSelected,
        onSelected: (on) {
          _flashChip(split); 
          setState(() {
            if (on) {
              selectedWorkoutSplits.add(split);
            } else {
              selectedWorkoutSplits.remove(split);
            }
          });
        },
        selectedColor: blueGrotto,
        backgroundColor: Colors.grey[900],
        labelPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: Colors.transparent, width: 1),
        ),
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
          glowingIcon(Icons.fitness_center, blueGrotto, 28),
          const SizedBox(width: 8),
          Text(
            "Track Your Workout!",
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
        actions: [
          IconButton(
            icon: glowingIcon(Icons.check, babyBlue, 25),
            onPressed: _submitWorkout,
            tooltip: "Submit Workout",
          ),
        ],
      ),
      body: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 20),
      child: ListView(
        children: [
          Center(
            child: Text(
              "Select Your Split!",
              style: Theme.of(context)
                .textTheme
                .titleMedium!
                .copyWith(color: babyBlue),
            ),
          ),
          const SizedBox(height: 8),
          Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _splitChip(workoutSplitOptions[0]),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _splitChip(workoutSplitOptions[1]),
                  const SizedBox(width: 8),
                  _splitChip(workoutSplitOptions[2]),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _splitChip(workoutSplitOptions[3]),
                  const SizedBox(width: 8),
                  _splitChip(workoutSplitOptions[4]),
                  const SizedBox(width: 8),
                  _splitChip(workoutSplitOptions[5]),
                ],
              ),
            ],
          ),

            const SizedBox(height: 30),
            ...exerciseEntries.asMap().entries.map((entryData) {
            final idx = entryData.key;
            final entry = entryData.value;
            return Card(
              color: Colors.black,
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              margin: const EdgeInsets.symmetric(vertical: 8),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 0, 16, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 0, bottom: 0),
                      child: SizedBox(
                        height: 19,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Text(
                                'Exercise Details',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium!
                                    .copyWith(color: babyBlue),
                              ),
                            Positioned(
                              right: 0,
                              child: PopupMenuButton<String>(
                                icon: Icon(Icons.more_vert, color: babyBlue),
                                color: Colors.grey[900],
                                onSelected: (choice) {
                                  switch (choice) {
                                    case 'unit_lbs':
                                      setState(() => entry.weightUnit = 'Lbs');
                                      break;
                                    case 'unit_kg':
                                      setState(() => entry.weightUnit = 'Kg');
                                      break;
                                    case 'duplicate':
                                      final copy = ExerciseEntry()
                                        ..exerciseNameController.text = entry.exerciseNameController.text
                                        ..setsController.text = entry.setsController.text
                                        ..repsController.text = entry.repsController.text
                                        ..weightController.text = entry.weightController.text
                                        ..weightUnit = entry.weightUnit
                                        ..showNotes = entry.showNotes
                                        ..notesController.text = entry.notesController.text;
                                      setState(() {
                                        exerciseEntries.insert(idx + 1, copy);
                                      });
                                      break;
                                    case 'remove':
                                      if (exerciseEntries.length > 1) {
                                        showDialog(
                                          context: context,
                                          barrierDismissible: false,
                                          builder: (ctx) => AlertDialog(
                                            backgroundColor: Colors.grey[900],                          
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(16),                  
                                            ),
                                            title: Text(
                                              "Delete Exercise?",
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 18,
                                                color: Colors.white,
                                                shadows: glowShadows(aquamarine, radii: [8,16,24]),      
                                              ),
                                            ),
                                            actionsAlignment: MainAxisAlignment.center,                  
                                            actionsPadding: const EdgeInsets.only(bottom: 12),
                                            actions: [
                                              TextButton(
                                                onPressed: () => Navigator.of(ctx).pop(false),
                                                style: TextButton.styleFrom(foregroundColor: Colors.white),
                                                child: const Text("Cancel"),
                                              ),
                                              const SizedBox(width: 16),
                                              TextButton(
                                                onPressed: () {
                                                  setState(() => exerciseEntries.removeAt(idx));
                                                  Navigator.of(ctx).pop(true);
                                                },
                                                style: TextButton.styleFrom(foregroundColor: Colors.redAccent),
                                                child: const Text("Delete"),
                                              ),
                                            ],
                                          ),
                                        );
                                      } else {
                                        showShortFadeSnack(context, "At least one exercise is required.");
                                      }
                                      break;
                                    case 'notes':
                                      setState(() => entry.showNotes = !entry.showNotes);
                                      break;
                                  }
                                },
                                itemBuilder: (_) => [
                                  PopupMenuItem(
                                    value: 'duplicate',
                                    child: ConstrainedBox(
                                    constraints: const BoxConstraints(minWidth: 70, maxWidth: 70),
                                    child: Text('Duplicate Exercise', 
                                    style: TextStyle(color: Colors.white70)))),
                                  PopupMenuItem(
                                    value: 'remove',
                                    child: ConstrainedBox(
                                    constraints: const BoxConstraints(minWidth: 70, maxWidth: 70),
                                    child: Text('Remove Exercise',
                                    style: TextStyle(color: Colors.white70)))),
                                  PopupMenuItem(
                                    value: 'notes',
                                    child: ConstrainedBox(
                                      constraints: const BoxConstraints(minWidth: 70, maxWidth: 70),
                                      child: Text(
                                        entry.showNotes ? 'Hide Notes' : 'Add Notes',
                                        style: const TextStyle(color: Colors.white70),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          iconTextField(entry.exerciseNameController, 'Exercise Name', Icons.edit),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(child: iconTextField(entry.setsController, 'Sets', Icons.format_list_numbered)),
                              const SizedBox(width: 8),
                              Expanded(child: iconTextField(entry.repsController, 'Reps', Icons.repeat)),
                              const SizedBox(width: 8),
                              Expanded(
                                flex: 1,
                                child: TextField(
                                  controller: entry.weightController,
                                  keyboardType: TextInputType.number,
                                  style: const TextStyle(color: Colors.white70),
                                  decoration: InputDecoration(
                                    hintText: entry.weightUnit,         
                                    hintStyle: const TextStyle(color: Colors.white70),
                                    filled: true,
                                    isDense: true,
                                    fillColor: Colors.grey[900],
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(16),
                                      borderSide: BorderSide.none,
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(
                                      vertical: 16,
                                      horizontal: 14,
                                    ),
                                    prefixIcon: SizedBox(
                                      width: 40,
                                      height: 40,
                                      child: Center(
                                        child: PopupMenuButton<String>(
                                          padding: EdgeInsets.zero,          
                                          iconSize: 24,                      
                                          icon: glowingIcon(Icons.fitness_center, babyBlue, 24),
                                          color: Colors.grey[900],
                                          onSelected: (unit) => setState(() => entry.weightUnit = unit),
                                          itemBuilder: (_) => [
                                            PopupMenuItem(value: 'Lbs', child: Text('Lbs', style: TextStyle(color: Colors.white70))),
                                            PopupMenuItem(value: 'Kg',  child: Text('Kg',  style: TextStyle(color: Colors.white70))),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          if (entry.showNotes) ...[
                            const SizedBox(height: 12),
                            iconTextField(entry.notesController, 'Notes', Icons.note, maxLines: 3),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
           const SizedBox(height: 25),
            Center(
              child: AnimatedContainer(
                duration: _flashDuration,
                curve: Curves.easeOut,
                width: MediaQuery.of(context).size.width * 0.4,
                height: 50.0,
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    ...glowShadows(blueGrotto, radii: [8, 12, 16]),
                    if (_addFlashing) ...[
                      BoxShadow(
                        color: Colors.white.withOpacity(0.6),
                        blurRadius: 12,
                        spreadRadius: 2,
                      ),
                      BoxShadow(
                        color: Colors.white.withOpacity(0.3),
                        blurRadius: 24,
                        spreadRadius: 4,
                      ),
                    ],
                  ],
                ),
                child: TextButton.icon(
                  onPressed: () {
                    _flashAddButton();               
                    setState(() => exerciseEntries.add(ExerciseEntry()));
                  },
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  icon: glowingIcon(Icons.add, blueGrotto, 24),
                  label: Text('Add Exercise', style: glowingTextStyle(blueGrotto, size: 16)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}