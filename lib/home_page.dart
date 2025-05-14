// home_page.dart
import 'package:flutter/material.dart';
import 'workout_planner_lp.dart';
import 'past_workouts.dart';
import 'gymbuddy.dart';
import 'reels_page.dart';
import 'profile_page.dart';
import 'button_effects/ui_helpers.dart';

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
    final List<Widget> pages = [
      ReelsPage(userId: widget.userId),
      const WorkoutTrackerLandingPage(),
      const PastWorkoutsCalendar(),
      GymBuddyScreen(currentUserId: widget.userId),
      ProfilePage(userId: widget.userId)
    ];

    return Scaffold(
      backgroundColor: Colors.black,
      body: pages[_currentIndex],
      bottomNavigationBar: PhysicalModel(
        color: Colors.black,
        elevation: 12,
        shadowColor: blueGrotto.withOpacity(0.4),
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,        
          backgroundColor: const Color.fromARGB(3, 255, 255, 255),       
          selectedItemColor: blueGrotto,
          unselectedItemColor: Colors.white70,
          selectedIconTheme: IconThemeData(size: 32), 
          unselectedIconTheme: IconThemeData(size: 28),
          showSelectedLabels: true,
          showUnselectedLabels: false,
          elevation: 0,                               
          currentIndex: _currentIndex,
          onTap: (i) => setState(() => _currentIndex = i),
          items: [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              activeIcon: glowingIcon(Icons.home, blueGrotto, 32),
              label: "Home",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.fitness_center),
              activeIcon: glowingIcon(Icons.fitness_center, blueGrotto, 32),
              label: "Workout",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.calendar_today),
              activeIcon: glowingIcon(Icons.calendar_today, blueGrotto, 32),
              label: "History",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.people),
              activeIcon: glowingIcon(Icons.people, blueGrotto, 32),
              label: "Gym Buddies",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              activeIcon: glowingIcon(Icons.person, blueGrotto, 32),
              label: "Profile",
            ),
          ],
        ),
      ),
    );
  }
}
