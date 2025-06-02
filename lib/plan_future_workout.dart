import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'api_service.dart';
import 'workout_reminders.dart';
import 'roast_notifications.dart';
import 'package:workmanager/workmanager.dart';
import 'button_effects/flash_press.dart';
import 'button_effects/ui_helpers.dart';

class PlanWorkoutPage extends StatefulWidget {
  const PlanWorkoutPage({super.key});

  @override
  _PlanWorkoutPageState createState() => _PlanWorkoutPageState();
}

class _PlanWorkoutPageState extends State<PlanWorkoutPage> {
  final TextEditingController workoutNameController = TextEditingController();
  List<String> selectedMuscleGroups = [];
  DateTime? scheduledDate;
  TimeOfDay? scheduledTime;
  bool roastEnabled = false;
  final blueGrotto = const Color.fromARGB(255, 45, 178, 250);
  final aquamarine = const Color.fromARGB(255, 167, 223, 248);
  final babyBlue = const Color.fromARGB(255, 212, 242, 255);

  List<String> workoutSplitOptions = [
    'Legs',
    'Back',
    'Core',
    'Delts',
    'Arms',
    'Chest',
  ];
  List<String> selectedWorkoutSplits = [];

  bool _addPressed = false;
  bool _addFlashing = false;

  static const _flashDuration = Duration(milliseconds: 300);
  static const _flashHold = Duration(milliseconds: 400);
  static const _flashFade = Duration(milliseconds: 400);
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

  void _startFlash() {
    setState(() => _addPressed = true);
    Future.delayed(_flashDuration, () {
      if (!mounted) return;
      setState(() => _addPressed = false);
    });
  }

  @override
  void initState() {
    super.initState();
    _loadRoastSetting();
  }

  void _resetForm() {
    setState(() {
      workoutNameController.clear();
      selectedMuscleGroups.clear();
      selectedWorkoutSplits.clear();
      _flashingSplits.clear();
      scheduledDate = null;
      scheduledTime = null;
      roastEnabled = false;
    });
    FocusScope.of(context).unfocus();
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
      showShortFadeSnack(context, "User not logged in.");
      return;
    }
    if (workoutNameController.text.isEmpty ||
        selectedWorkoutSplits.isEmpty ||
        getScheduledDateTime() == null) {
      showShortFadeSnack(context, "Please complete all fields.");
      return;
    }

    try {
      _storePlannedWorkoutSettings(
          workoutNameController.text.trim(),
          getScheduledDateTime().toString(),
          selectedWorkoutSplits,
          roastEnabled);
      await ApiService.addPlannedWorkout(
        userId: userId,
        workoutName: workoutNameController.text.trim(),
        muscleGroups: selectedWorkoutSplits,
        scheduledDatetime: getScheduledDateTime()!,
        roastEnabled: roastEnabled,
      );
      showShortFadeSnack(context, "Planned workout created successfully!");
      _resetForm();
      // Schedule the background task for roast notifications.
      await Workmanager().registerOneOffTask(
        "roast_notification_task",
        "roastNotificationTask",
        // set to 1 minutes for immediate testing; change to 24 hours for production
        initialDelay: const Duration(hours: 24),
        inputData: {},
      );
    } catch (e) {
      showShortFadeSnack(context, "Error: $e");
    }
  }

  Future<void> _storePlannedWorkoutSettings(
      String workoutName,
      String workoutDateIso,
      List<String> muscleGroups,
      bool roastEnabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('plannedWorkoutName', workoutName);
    await prefs.setString('plannedWorkoutDate', workoutDateIso);
    await prefs.setStringList('plannedMuscleGroups', muscleGroups);
    await prefs.setBool('plannedRoastEnabled', roastEnabled);
  }

  @override
  void dispose() {
    workoutNameController.dispose();
    scheduledDate = null;
    scheduledTime = null;
    selectedWorkoutSplits.clear();
    _flashingSplits.clear();
    super.dispose();
  }

  Future<void> _saveSelectedSplits() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      'plannedMuscleGroups',
      selectedWorkoutSplits,
    );
  }

  Widget _splitChip(String split) {
    final isSelected = selectedWorkoutSplits.contains(split);
    final isFlashing = _flashingSplits.contains(split);

    List<BoxShadow>? shadows;
    if (isSelected || isFlashing) {
      shadows = [
        ...glowShadows(aquamarine, radii: [4, 8, 16]),
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
          _saveSelectedSplits();
          setState(() {
            if (on) {
              selectedWorkoutSplits.add(split);
            } else {
              selectedWorkoutSplits.remove(split);
            }
          });
        },
        selectedColor: aquamarine,
        backgroundColor: Colors.grey[900],
        labelPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: Colors.transparent, width: 1),
        ),
      ),
    );
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: scheduledDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: ColorScheme.dark(
            primary: aquamarine,
            onPrimary: Colors.black,
            surface: Colors.black,
            onSurface: Colors.white70,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => scheduledDate = picked);
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: scheduledTime ?? TimeOfDay.now(),
      builder: (ctx, child) => Theme(
        data: ThemeData.dark().copyWith(
          colorScheme: ColorScheme.dark(
            primary: Colors.grey[900]!,
            onPrimary: Colors.white,
            surface: Colors.black,
            onSurface: Colors.white70,
          ),
          timePickerTheme: TimePickerThemeData(
            dialBackgroundColor: Colors.black,
            dialTextColor: aquamarine,
            hourMinuteTextColor: aquamarine,
            dayPeriodColor: Colors.grey[900]!,
            dayPeriodTextColor: aquamarine,
            dayPeriodBorderSide: BorderSide(color: Colors.black, width: 0),
            entryModeIconColor: aquamarine,
          ),
          textButtonTheme: TextButtonThemeData(
            style: TextButton.styleFrom(
              foregroundColor: aquamarine,
            ),
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => scheduledTime = picked);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            glowingIcon(Icons.event_note, aquamarine, 24),
            const SizedBox(width: 8),
            Text(
              "Plan Your Workout!",
              style: glowingTextStyle(
                aquamarine,
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
            onPressed: _submitPlannedWorkout,
            tooltip: "Submit Planned Workout",
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
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
            Center(
              child: Text(
                "Name Your Workout!",
                style: Theme.of(context)
                    .textTheme
                    .titleMedium!
                    .copyWith(color: babyBlue),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: TextField(
                controller: workoutNameController,
                style: const TextStyle(color: Colors.white70),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.grey[900],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  prefixIcon: Padding(
                    padding: const EdgeInsets.fromLTRB(12, 6, 0, 8),
                    child: glowingIcon(Icons.edit, babyBlue, 26),
                  ),
                  suffixIcon: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      InkWell(
                        onTap: _pickDate,
                        customBorder: const CircleBorder(),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child:
                              glowingIcon(Icons.calendar_today, babyBlue, 24),
                        ),
                      ),
                      const SizedBox(width: 5),
                      InkWell(
                        onTap: _pickTime,
                        customBorder: const CircleBorder(),
                        child: Padding(
                          padding: const EdgeInsets.only(right: 16, left: 8),
                          child: glowingIcon(Icons.access_time, babyBlue, 24),
                        ),
                      ),
                    ],
                  ),
                  suffixIconConstraints: const BoxConstraints(
                    minHeight: 0,
                    minWidth: 0,
                  ),
                  hintText: 'Workout Name',
                  hintStyle: const TextStyle(color: Colors.white70),
                  contentPadding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Roast
                  SizedBox(
                    width: 150,
                    height: 48,
                    child: FlashOnPress(
                      glowColor: blueGrotto,
                      flashColor: Colors.white,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) =>
                                const RoastNotificationsSettingsPage()),
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: glowShadows(blueGrotto),
                        ),
                        alignment: Alignment.center,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            glowingIcon(Icons.whatshot, blueGrotto, 20),
                            const SizedBox(width: 6),
                            Text("Roast Me",
                                style: glowingTextStyle(blueGrotto, size: 14)),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 30),
                  // Reminder
                  SizedBox(
                    width: 150,
                    height: 48,
                    child: FlashOnPress(
                      glowColor: aquamarine,
                      flashColor: Colors.white,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) =>
                                const WorkoutReminderSettingsPage()),
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: glowShadows(aquamarine),
                        ),
                        alignment: Alignment.center,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            glowingIcon(Icons.alarm, aquamarine, 20),
                            const SizedBox(width: 6),
                            Text("Set Reminder",
                                style: glowingTextStyle(aquamarine, size: 14)),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
