import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:winterark/main.dart' as app; 
import 'package:winterark/workout_planner.dart'; 
import 'package:flutter/services.dart';

// A helper function to convert a month number to its name
String getMonthName(int month) {
  const monthNames = [
    "January", "February", "March", "April", "May", "June",
    "July", "August", "September", "October", "November", "December"
  ];
  return monthNames[month - 1];
}

// To run replace with device number: make integration_test DEVICE=emulator-5554
void main() {
  // Initialize the integration test framework
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Workout Tracker Integration Test', () {
    testWidgets('Log a workout and verify it appears in the Past Workouts Calendar', (WidgetTester tester) async {
      // Launch the app
      app.main();
      await tester.pumpAndSettle();

      // Find the email TextField
      final signInButton = find.byKey(const Key('sign-in-button'));
      if (signInButton.evaluate().isNotEmpty) {
        await tester.tap(signInButton);
        await tester.pumpAndSettle();
      }

      final usernameEmailField = find.byKey(const Key('login-username-email'));
      expect(usernameEmailField, findsOneWidget, reason: 'Username/Email field not found');
      await tester.enterText(usernameEmailField, '123459');

      // Find the password field
      final passwordField = find.byKey(const Key('login-password'));
      expect(passwordField, findsOneWidget, reason: 'Password field not found');
      await tester.enterText(passwordField, '123');

      // Find and tap the "Log In" button by its text
      final loginButton = find.byKey(const Key('login-button'));
      expect(loginButton, findsOneWidget, reason: 'Login button not found');
      await tester.tap(loginButton);
      await tester.pumpAndSettle();

      // Check that the home screen is loaded
      final workoutsNav = find.byKey(const Key('nav-workout-tracker')); 
      expect(workoutsNav, findsOneWidget, reason: 'Home screen not reached');

      // Tap the "Workouts" button on the bottom navigation
      await tester.tap(workoutsNav);
      await tester.pumpAndSettle();

      // Interact with the workout split dropdown
      final splitDropdown = find.byKey(WorkoutTrackerScreen.workoutSplitKey);
      expect(splitDropdown, findsOneWidget, reason: 'Workout split dropdown not found');
      await tester.tap(splitDropdown);
      await tester.pumpAndSettle();

      // Select a split
      final pushOption = find.text('Push');
      expect(pushOption, findsWidgets, reason: 'Push option not found');
      await tester.tap(pushOption.first);
      await tester.pumpAndSettle();

      // Tap the "OK" button 
      final splitDropdownOkButton = find.text('OK');
      expect(splitDropdownOkButton, findsOneWidget, reason: 'Workout split dropdown OK button not found');
      await tester.tap(splitDropdownOkButton);
      await tester.pumpAndSettle();

      // Enter exercise details:
      final exerciseNameField = find.byKey(const Key('exercise-name'));
      expect(exerciseNameField, findsOneWidget, reason: 'Exercise Name field not found');
      await tester.enterText(exerciseNameField, 'Bench Press');

      final setsField = find.byKey(const Key('exercise-sets'));
      expect(setsField, findsOneWidget, reason: 'Sets field not found');
      await tester.enterText(setsField, '3');

      final repsField = find.byKey(const Key('exercise-reps'));
      expect(repsField, findsOneWidget, reason: 'Reps field not found');
      await tester.enterText(repsField, '10');

      final weightField = find.byKey(const Key('exercise-weight'));
      expect(weightField, findsOneWidget, reason: 'Weight field not found');
      await tester.enterText(weightField, '150');

      // For weight unit dropdown
      final weightUnitDropdown = find.byKey(const Key('weight-unit'));
      expect(weightUnitDropdown, findsOneWidget, reason: 'Weight unit dropdown not found');
      await tester.tap(weightUnitDropdown);
      await tester.pumpAndSettle();
      final lbsOption = find.text('lbs').last;
      await tester.tap(lbsOption);
      await tester.pumpAndSettle();

      // Tap "notes" toggle, and enter text
      final notesToggle = find.byKey(const Key('notes-toggle'));
      if (notesToggle.evaluate().isNotEmpty) {
        await tester.tap(notesToggle);
        await tester.pumpAndSettle();
        final notesField = find.byKey(const Key('exercise-notes'));
        if (notesField.evaluate().isNotEmpty) {
          await tester.enterText(notesField, 'Felt strong today.');
          await tester.pumpAndSettle();
        }
      }

      // Tap "Pick Date"
      final pickDateButton = find.byKey(const Key('pick-date'));
      expect(pickDateButton, findsOneWidget, reason: 'Pick Date button not found');
      await tester.tap(pickDateButton);
      await tester.pumpAndSettle();

      // Tap the "OK" button to confirm the default date
      final dateOkButton = find.text('OK');
      expect(dateOkButton, findsOneWidget, reason: 'Date picker OK button not found');
      await tester.tap(dateOkButton);
      await tester.pumpAndSettle();

      // Tap the "Pick Time" button 
      final pickTimeButton = find.byKey(const Key('pick-time'));
      expect(pickTimeButton, findsOneWidget, reason: 'Pick Time button not found');
      await tester.tap(pickTimeButton);
      await tester.pumpAndSettle();  

      // Tap the "OK" button on the time picker dialog
      final timeOkButton = find.text('OK');
      expect(timeOkButton, findsOneWidget, reason: 'Time picker OK button not found');
      await tester.tap(timeOkButton);
      await tester.pumpAndSettle();

      // Submit the workout
      final submitButton = find.byKey(const Key('submit-workout'));
      expect(submitButton, findsOneWidget, reason: 'Submit Workout button not found');
      await tester.tap(submitButton);
      await tester.pumpAndSettle();

      final pastWorkoutsNav = find.byKey(const Key('nav-past-workouts'));
      expect(pastWorkoutsNav, findsOneWidget, reason: 'Past Workouts navigation button not found');
      await tester.tap(pastWorkoutsNav);
      await tester.pumpAndSettle();

      // Use the current date for the calendar key
      final now = DateTime.now();
      final monthName = getMonthName(now.month);
      final day = now.day;
      final calendarKey = Key('$monthName-date-$day');

      // Tap on the calendar date that should include the new workout
      final calendarDate = find.byKey(calendarKey);
      expect(calendarDate, findsOneWidget, reason: 'Calendar date not found');
      await tester.tap(calendarDate);
      await tester.pumpAndSettle(const Duration(seconds: 1));

      final workoutEntry = find.text('Bench Press').first;
      expect(workoutEntry, findsOneWidget, reason: 'Original workout entry not found');
      await tester.tap(workoutEntry);
      await tester.pumpAndSettle();
      
      final editNameField = find.byKey(const Key('edit-exercise-name'));
      expect(editNameField, findsOneWidget, reason: 'Edit Exercise Name field not found');
      await tester.enterText(editNameField, 'Dumbbell Bench Press');

      final editSetsField = find.byKey(const Key('edit-sets'));
      expect(editSetsField, findsOneWidget, reason: 'Edit Sets field not found');
      await tester.enterText(editSetsField, '2');

      final editRepsField = find.byKey(const Key('edit-reps'));
      expect(editRepsField, findsOneWidget, reason: 'Edit Reps field not found');
      await tester.enterText(editRepsField, '6');

      final editWeightField = find.byKey(const Key('edit-weight'));
      expect(editWeightField, findsOneWidget, reason: 'Edit Weight field not found');
      await tester.enterText(editWeightField, '300');

      final updateButton = find.byKey(const Key('update-workout'));
      expect(updateButton, findsOneWidget, reason: 'Update button not found');
      await tester.tap(updateButton);
      await tester.pumpAndSettle();

      // Close
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pumpAndSettle();

      await tester.tap(calendarDate);
      await tester.pumpAndSettle(const Duration(seconds: 1));

      final updatedWorkoutEntry = find.text('Dumbbell Bench Press').first;
      expect(updatedWorkoutEntry, findsOneWidget, reason: 'Updated workout entry not found');

      
      // Tap the updated workout entry to reopen the edit dialog
      await tester.tap(updatedWorkoutEntry);
      await tester.pumpAndSettle();

      // Find and tap the delete button 
      final deleteButton = find.byKey(const Key('delete-workout'));
      expect(deleteButton, findsOneWidget, reason: 'Delete button not found');
      await tester.tap(deleteButton);
      await tester.pumpAndSettle();

      await tester.tap(calendarDate);
      await tester.pumpAndSettle(const Duration(seconds: 1));

      // Close
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pumpAndSettle();

      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pumpAndSettle();

      // Navigate to the Gym Buddies tab 
      final gymBuddiesTab = find.byKey(const Key('nav-gym-buddies'));
      expect(gymBuddiesTab, findsOneWidget, reason: 'Gym Buddies tab not found');
      await tester.tap(gymBuddiesTab);
      await tester.pumpAndSettle(const Duration(seconds: 1));

      // Locate the gym buddy search field using its key
      final searchField = find.byKey(const Key('gymbuddy-search'));
      expect(searchField, findsOneWidget, reason: 'Gym buddy search field not found');
      await tester.enterText(searchField, 'Test');
      await tester.pumpAndSettle();

      // Tap the search button
      final searchButton = find.byKey(const Key('gymbuddy-search-btn'));
      expect(searchButton, findsOneWidget, reason: 'Gym buddy search button not found');
      await tester.tap(searchButton);
      await tester.pumpAndSettle();

      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pumpAndSettle(const Duration(seconds: 1));

      // Tap the add button for that buddy
      final addButton = find.byIcon(Icons.person_add).first;
      expect(addButton, findsOneWidget, reason: 'Add gym buddy button not found');
      await tester.tap(addButton);
      await tester.pumpAndSettle();

      // Verify that a success message appears
      expect(find.textContaining('Gym buddy request sent!'), findsOneWidget, reason: 'Success message not found');

      // Verify that the buddy now appears in the Outgoing Requests section
      final outgoingSection = find.text('Outgoing Requests');
      expect(outgoingSection, findsOneWidget, reason: 'Outgoing Requests section not found');

      final openChat = find.byIcon(Icons.chat).first;
      expect(openChat, findsOneWidget, reason: 'Chat button not found');
      await tester.tap(openChat);
      await tester.pumpAndSettle(const Duration(seconds: 3)); 
      
      final messageInput = find.byKey(const Key('chat-message-input'));
      expect(messageInput, findsOneWidget, reason: 'Chat message input not found');
      await tester.enterText(messageInput, 'Hi, Ian!');

      final sendButton = find.byKey(const Key('chat-send-button'));
      expect(sendButton, findsOneWidget, reason: 'Chat send button not found');
      await tester.pumpAndSettle();

      await tester.tap(sendButton);
      await tester.pumpAndSettle(const Duration(seconds: 2));
    });
  });
}