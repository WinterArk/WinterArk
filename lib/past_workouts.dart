import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: PastWorkoutsCalendar(),
    );
  }
}

class PastWorkoutsCalendar extends StatelessWidget {
  const PastWorkoutsCalendar({Key? key}) : super(key: key);

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

  void _showInsights(BuildContext context, String date) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.black,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      builder: (BuildContext context) {
        return Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Title
              Text(
                'Workout Insights for $date',
                style: const TextStyle(
                  fontSize: 24,
                  color: Colors.lightBlue,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              // Description
              const Text(
                'Here’s what you accomplished on this day. You can add more details here, like calories burned, exercises completed, or milestones achieved!',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white70,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),
              // Close Button
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.lightBlue, // Corrected parameter
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 40),
                  shadowColor: Colors.lightBlueAccent,
                  elevation: 10,
                ),
                child: const Text(
                  'Close',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
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
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.lightBlue),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(
          'Past Workouts',
          style: TextStyle(color: Colors.lightBlue),
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
                      onTap: () => _showInsights(
                        context,
                        '${month['name']} ${dayIndex + 1}',
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