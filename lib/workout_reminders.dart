import 'package:flutter/material.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

class WorkoutReminderSettingsPage extends StatefulWidget {
  const WorkoutReminderSettingsPage({Key? key}) : super(key: key);

  @override
  _WorkoutReminderSettingsPageState createState() => _WorkoutReminderSettingsPageState();
}

class _WorkoutReminderSettingsPageState extends State<WorkoutReminderSettingsPage> {
  DateTime? selectedDate;
  TimeOfDay? selectedTime;
  final TextEditingController reminderTextController = TextEditingController();

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
        id: 100,
        channelKey: 'workout_reminder',
        title: 'Workout Reminder',
        body: 'Your workout for $muscleGroup starts soon!',
        notificationLayout: NotificationLayout.Default,
      ),
      schedule: NotificationCalendar.fromDate(date: scheduledDate),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Workout Reminders"),
        backgroundColor: const Color.fromARGB(255, 253, 180, 225),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.only(bottom: 16.0),
              child: Text(
                "Set Your Workout Reminder",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 26, 
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            TextField(
              controller: reminderTextController,
              textAlign: TextAlign.center,
              decoration: const InputDecoration(
                hintText: 'Enter workout description',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
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
                    child: Text(selectedDate == null 
                        ? "Pick Date" 
                        : "${selectedDate!.month}/${selectedDate!.day}/${selectedDate!.year}"),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
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
                    child: Text(selectedTime == null 
                        ? "Pick Time" 
                        : selectedTime!.format(context)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                if (selectedDate == null || selectedTime == null) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please select both date and time")));
                  return;
                }
                final DateTime workoutDateTime = DateTime(
                  selectedDate!.year,
                  selectedDate!.month,
                  selectedDate!.day,
                  selectedTime!.hour,
                  selectedTime!.minute,
                );
                scheduleWorkoutReminder(workoutDateTime, reminderTextController.text.trim());
              },
              child: const Text("Schedule"),
            ),
          ],
        ),
      ),
    );
  }
}
