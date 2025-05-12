import 'package:flutter/material.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:another_flushbar/flushbar.dart';
import 'button_effects/ui_helpers.dart';
import 'package:intl/intl.dart';


class WorkoutReminderSettingsPage extends StatefulWidget {
  const WorkoutReminderSettingsPage({super.key});

  @override
  _WorkoutReminderSettingsPageState createState() => _WorkoutReminderSettingsPageState();
}

class _WorkoutReminderSettingsPageState extends State<WorkoutReminderSettingsPage> with WidgetsBindingObserver {
  DateTime? selectedDate;
  TimeOfDay? selectedTime;
  final TextEditingController reminderTextController = TextEditingController();
  final babyBlue   = const Color.fromARGB(255, 212, 242, 255);  // #D6E2E8
  final aquamarine = const Color.fromARGB(255, 167, 223, 248);  // #91C1D8
  final blueGrotto = const Color.fromARGB(255, 45, 178, 250);  // #0070AC
  final navyBlue   = const Color(0xFF003371);  // #003371

  late Future<List<NotificationModel>> _upcoming;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadUpcoming();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    reminderTextController.dispose();
    selectedDate = null;
    selectedTime = null;
    super.dispose();
  }

  void _loadUpcoming() {
    _upcoming = AwesomeNotifications().listScheduledNotifications();
  }

  Future<void> _cancelReminder(int id) async {
    await AwesomeNotifications().cancelSchedule(id);
    await AwesomeNotifications().cancel(id);
    _loadUpcoming();
    setState(() {});
  }

  Future<void> _rescheduleReminder(NotificationModel old) async {
    final schedule = old.schedule;
    if (schedule is NotificationCalendar) {
      final now = DateTime.now();
      final initial = DateTime(
        schedule.year   ?? now.year,
        schedule.month  ?? now.month,
        schedule.day    ?? now.day,
        schedule.hour   ?? now.hour,
        schedule.minute ?? now.minute,
        schedule.second ?? now.second,
      );

      final DateTime? newDt = await showDatePicker(
        context: context,
        initialDate: initial,
        firstDate: DateTime.now(),
        lastDate: DateTime(2100),
      ).then((d) async {
        if (d == null) return null;
        final t = await showTimePicker(
          context: context,
          initialTime: TimeOfDay.fromDateTime(initial),
        );
        if (t == null) return null;
        return DateTime(d.year, d.month, d.day, t.hour, t.minute);
      });

      if (newDt == null) return;

      await AwesomeNotifications().cancel(old.content!.id!);
      await AwesomeNotifications().createNotification(
        content: old.content!,
        schedule: NotificationCalendar.fromDate(date: newDt),
      );

      _loadUpcoming();
      setState(() {});
    }
  }

  void _pickDate() async {
    final d = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
      builder: (ctx, child) => Theme(
        data: ThemeData.dark().copyWith(
          colorScheme: ColorScheme.dark(
            primary: aquamarine,
            onPrimary: Colors.black,
            surface: Colors.black!,
            onSurface: Colors.white70,
          ),
        ),
        child: child!,
      ),
    );
    if (d != null) setState(() => selectedDate = d);
  }

  void _pickTime() async {
    final t = await showTimePicker(
      context: context,
      initialTime: selectedTime ?? TimeOfDay.now(),
      builder: (ctx, child) => Theme(
        data: ThemeData.dark().copyWith(
          colorScheme: ColorScheme.dark(
            primary:   Colors.grey[900]!,  
            onPrimary: Colors.white,       
            surface:   Colors.black,      
            onSurface: Colors.white70,     
          ),
          timePickerTheme: TimePickerThemeData(
            dialBackgroundColor: Colors.black,  
            dialTextColor:       aquamarine,
            hourMinuteTextColor: aquamarine,
            dayPeriodColor:     Colors.grey[900]!,
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
    if (t != null) setState(() => selectedTime = t);
  }

  Future<DateTime?> _pickDateTime({required DateTime initial}) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
      builder: (ctx, child) => Theme(
        data: ThemeData.dark().copyWith(
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
    if (pickedDate == null) return null;

    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(initial),
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
            entryModeIconColor: aquamarine,
          ),
          textButtonTheme: TextButtonThemeData(
            style: TextButton.styleFrom(foregroundColor: aquamarine),
          ),
        ),
        child: child!,
      ),
    );
    if (pickedTime == null) return null;

    return DateTime(
      pickedDate.year,
      pickedDate.month,
      pickedDate.day,
      pickedTime.hour,
      pickedTime.minute,
    );
  }

  void _submitReminder() {
    if (reminderTextController.text.trim().isEmpty ||
        selectedDate == null ||
        selectedTime == null) {
      showShortFadeSnack(context, "Please fill description, date & time");
      return;
    }

    final dt = DateTime(
      selectedDate!.year,
      selectedDate!.month,
      selectedDate!.day,
      selectedTime!.hour,
      selectedTime!.minute,
    );

    scheduleWorkoutReminder(dt, reminderTextController.text.trim());

    setState(() {
      _upcoming = AwesomeNotifications().listScheduledNotifications();
    });
    showShortFadeSnack(context, "Reminder set successfully!");
    _resetForm();
    _loadUpcoming();
  }

  void _resetForm() {
    setState(() {
      selectedDate = null;
      selectedTime = null;
      reminderTextController.clear();
    });
    FocusScope.of(context).unfocus();
  }

  

  int _nextNotifId() {
    return DateTime.now().millisecondsSinceEpoch.remainder(100000);
  }

  Future<void> scheduleWorkoutReminder(DateTime workoutDateTime, String muscleGroup) async {
    final tz.TZDateTime scheduledDate = tz.TZDateTime.from(workoutDateTime, tz.local);
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    print('Current local time: $now');
    print('Scheduled notification time: $scheduledDate');

    if (!scheduledDate.isAfter(now)) {
      print('Scheduled date is not in the future. Aborting scheduling.');
      return;
    }

    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: _nextNotifId(),
        channelKey: 'workout_reminder',
        title: '💪 Time to Move!',
        body: 'Your “$muscleGroup” session is starting soon.',
        notificationLayout: NotificationLayout.BigText,
        color: Color(0xFF00BFFF),
        payload: {
          'muscle':    muscleGroup,
          'scheduled': scheduledDate.millisecondsSinceEpoch.toString(),
        },
      ),
      schedule: NotificationCalendar.fromDate(date: scheduledDate),
    );
  }

  TextStyle glowingTextStyle(Color color, double size, FontWeight font) => TextStyle(
    fontSize: size,
    fontWeight: FontWeight.bold,
    color: color,
    shadows: [
      ...glowShadows(color, radii: [8,16,24]),
      BoxShadow(color: color.withOpacity(0.3), blurRadius: 36),
    ],
  );

  String _format(NotificationSchedule? schedule) {
    if (schedule is NotificationCalendar) {
      final dt = DateTime(
        schedule.year   ?? 0,
        schedule.month  ?? 1,
        schedule.day    ?? 1,
        schedule.hour   ?? 0,
        schedule.minute ?? 0,
      );
      return DateFormat.yMMMd().add_jm().format(dt);
    }
    return '';
  }

  DateTime calendarToDateTimeLocal(NotificationCalendar cal) {
    return DateTime(
      cal.year   ?? DateTime.now().year,
      cal.month  ?? DateTime.now().month,
      cal.day    ?? DateTime.now().day,
      cal.hour   ?? 0,
      cal.minute ?? 0,
      cal.second ?? 0,
      cal.millisecond ?? 0,
    );
  }

  String _relativeTimePhrase(DateTime scheduled) {
    final diff = scheduled.difference(DateTime.now());
    if (diff.isNegative) return 'started already';
    if (diff.inDays > 0) {
      return 'in ${diff.inDays} day${diff.inDays>1?'s':''}';
    }
    if (diff.inHours > 0) {
      return 'in ${diff.inHours}h ${diff.inMinutes % 60}m';
    }
    return 'in ${diff.inMinutes} min';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: glowingIcon(Icons.arrow_back, babyBlue, 24),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            glowingIcon(Icons.alarm, aquamarine, 28),
            const SizedBox(width: 8),
            Text(
              "Reminders",
              style: glowingTextStyle(aquamarine, 24, FontWeight.bold),
            ),
          ],
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: glowingIcon(Icons.check, babyBlue, 28),
            onPressed: _submitReminder,
          ),
        ],
      ),

      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [

              Text(
                "Set a Reminder!",
                style: Theme.of(context)
                    .textTheme
                    .titleMedium!
                    .copyWith(color: babyBlue),
              ),

              ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.9,
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: TextField(
                    controller: reminderTextController,
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
                              child: glowingIcon(Icons.calendar_today, babyBlue, 24),
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
                      hintText: 'Workout details',
                      hintStyle: const TextStyle(color: Colors.white70),
                      contentPadding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),
              Text(
                "Upcoming Reminders",
                style: Theme.of(context)
                    .textTheme
                    .titleMedium!
                    .copyWith(color: babyBlue),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: FutureBuilder<List<NotificationModel>>(
                  future: _upcoming,
                  builder: (ctx, snap) {
                    if (snap.connectionState != ConnectionState.done) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    final list = snap.data!;
                    if (list.isEmpty) {
                      return const Text(
                        "No reminders scheduled",
                        style: TextStyle(color: Colors.white54),
                      );
                    }
                    return ListView.separated(
                      itemCount: list.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 25),
                      itemBuilder: (ctx, i) {
                        final n       = list[i];
                        final pl      = n.content?.payload ?? {};
                        final msStr   = pl['scheduled'] ?? '';
                        final msEpoch = int.tryParse(msStr);
                        final scheduled = msEpoch != null
                            ? DateTime.fromMillisecondsSinceEpoch(msEpoch)
                            : DateTime.now();

                        final muscle = pl['muscle'] ?? '';
                        final diff = scheduled.difference(DateTime.now());
                        final rel = diff.isNegative
                            ? 'is soon'
                            : diff.inHours > 0
                                ? 'begins'
                                : 'begins';

                        return Container(
                          padding: const EdgeInsets.all(12),
                          margin: const EdgeInsets.symmetric(horizontal: 16),
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.black,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: glowShadows(babyBlue, radii: [4,8,12]).map((s) =>
                            BoxShadow(color: s.color.withOpacity(1), blurRadius: s.blurRadius, spreadRadius: s.spreadRadius)
                          ).toList(),
                          ),
                          child: Row(
                            children: [
                              glowingIcon(Icons.alarm, babyBlue, 24),
                              const SizedBox(width: 15),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '$muscle\'s reminder $rel',
                                      style: glowingTextStyle(babyBlue, 16, FontWeight.normal),
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      DateFormat.yMMMd().add_jm().format(scheduled),
                                      style: const TextStyle(color: Colors.white54, fontSize: 12),
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.edit, color: Colors.lightBlueAccent),
                                onPressed: () => _rescheduleReminder(n),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () => _cancelReminder(n.content!.id!),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}  