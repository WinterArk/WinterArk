// home_page.dart
import 'package:flutter/material.dart';
import 'workout_planner_lp.dart';
import 'past_workouts.dart';
import 'gymbuddy.dart';
import 'reels_page.dart';
import 'profile_page.dart';

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
    // List of pages corresponding to each tab in the bottom navigation bar.
    final List<Widget> pages = [
      ReelsPage(userId: widget.userId),
      const WorkoutTrackerLandingPage(),
      const PastWorkoutsCalendar(),
      GymBuddyScreen(currentUserId: widget.userId),
      ProfilePage(userId: widget.userId),
    ];

    return Scaffold(
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
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.fitness_center),
            label: "Workouts",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: "Past Workouts",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: "Gym Buddies",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: "Profile",
          ),
        ],
      ),
    );
  }
}
