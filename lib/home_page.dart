// home_page.dart
import 'package:flutter/material.dart';
import 'workout_planner.dart';
import 'past_workouts.dart';
import 'gymbuddy.dart'; // GymBuddyScreen import
import 'sign_out_prompt.dart'; 

class HomePage extends StatefulWidget {
  final String userId;

  const HomePage({super.key, required this.userId});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    // Provide the real userId to GymBuddyScreen
    final List<Widget> pages = [
      const DashboardPage(),
      const WorkoutTrackerScreen(),
      const PastWorkoutsCalendar(),
      GymBuddyScreen(currentUserId: widget.userId),
    ];

    return SignOutPrompt(
      child: Scaffold(
        backgroundColor: Colors.black,
        body: pages[_currentIndex],
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _currentIndex,
          backgroundColor: Colors.black,
          selectedItemColor: Colors.blueAccent,
          unselectedItemColor: Colors.grey,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          items: [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: "Home",
            ),
            BottomNavigationBarItem(
              icon: Container(
                key: Key('nav-workout-tracker'),
                child: Icon(Icons.fitness_center),
              ),
              label: "Workouts",
            ),
            BottomNavigationBarItem(
              icon: Container(
                key: Key('nav-past-workouts'),
                child: Icon(Icons.calendar_today),
              ),
              label: "Past Workouts",
            ),
            BottomNavigationBarItem(
              icon: Container(
                key: Key('nav-gym-buddies'),
                child: Icon(Icons.people),
              ),
              label: "Gym Buddies",
            ),
          ],
        ),
      )
    );
  }
}

/// A simple Dashboard page.
class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        backgroundColor: Colors.blueAccent,
        centerTitle: true,
      ),
      backgroundColor: Colors.black,
      body: const Center(
        child: Text(
          'Welcome to WinterArk Home!',
          style: TextStyle(color: Colors.white, fontSize: 20),
        ),
      ),
    );
  }
}
