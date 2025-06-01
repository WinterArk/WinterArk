import 'package:flutter/material.dart';

class ExerciseSelectionWidget extends StatefulWidget {
  final ValueChanged<String> onSelectionChanged;
  const ExerciseSelectionWidget({super.key, required this.onSelectionChanged});

  @override
  _ExerciseSelectionWidgetState createState() =>
      _ExerciseSelectionWidgetState();
}

class _ExerciseSelectionWidgetState extends State<ExerciseSelectionWidget> {
  String? selectedMuscleGroup;
  String? selectedExercise;
  String? selectedVariation;
  String? selectedEquipment;
  bool isCustom = false;
  bool isSingleArm = false;
  bool isSingleLeg = false;

  // Controllers for search and custom entry
  final TextEditingController searchController = TextEditingController();
  final TextEditingController customExerciseController = TextEditingController();

   @override
    void initState() {
      super.initState();
    }

    @override
    void dispose() {
      searchController.dispose();
      customExerciseController.dispose();  
      super.dispose();
    }
  final List<String> muscleGroups = [
    'Chest',
    'Shoulders',
    'Arms',
    'Back',
    'Legs',
    'Core',
    'Custom Exercise'
  ];

  final Map<String, List<String>> exercisesByMuscle = {
    'Chest': ['Press', 'Fly', 'Dips', 'Pushups'],
    'Shoulders': ['Shoulder Press', 'Lateral Raise', 'Rear Delt Fly', 'Front Raise'],
    'Arms': ['Curl', 'Triceps Overhead', 'Triceps Pushdowns', 'Triceps Kickback', 'Dips'],
    'Back': ['Deadlift', 'Lat Pulldown', 'Pull Ups', 'Row', 'Back Extension', 'Pullover'],
    'Legs': ['Squat', 'Leg Press', 'Leg Extension', 'Hamstring Curls', 'Deadlift', 'RDL', 'Good Mornings', 'Calves', 'Hip Thrust', 'Lunge'],
    'Core': ['Leg Raise', 'Cable Crunches', 'Plank', 'Crunches', 'Situps', 'Russian Twists'],
  };

  final List<String> chestVariations = ['Decline', 'Flat', 'Incline'];
  final List<String> armCurlVariations = ['Standard', 'Incline', 'Preacher'];
  final List<String> backRowVariations = [
    'T-Bar Row',
    'Low Row',
    'Other Row',
  ];
  final List<String> squatVariations = [
    'High Bar',
    'Low Bar',
    'Hack Squat Machine',
    'Pendulum Squat',
    'Bulgarian Split',
    'Front Squat',
    'Pistol',
    'Goblet',
    'Sumo'
  ];

  final List<String> equipmentOptions = ['Barbell', 'Dumbbell', 'Machine', 'Cable', 'Weighted Belt', 'Bodyweight'];

  String _buildFinalExerciseName() {
    if (isCustom) {
      return customExerciseController.text.trim();
    }
    final base = selectedExercise ?? '';
    final varPart = selectedVariation != null ? ' $selectedVariation' : '';
    final equipPart = selectedEquipment != null ? ' $selectedEquipment' : '';
    final saPart = isSingleArm ? ' SA' : '';
    final slPart = isSingleLeg ? ' SL' : '';
    return '$base$varPart$equipPart$saPart$slPart'.trim();
  }

  void _updateExerciseName() {
    widget.onSelectionChanged(_buildFinalExerciseName());
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Search field
        // TextField(
        //   controller: searchController,
        //   decoration: const InputDecoration(
        //     labelText: 'Search Exercise',
        //     border: OutlineInputBorder(),
        //   ),
        // ),
        // const SizedBox(height: 10),
        // Muscle Group selection.
        DropdownButtonFormField<String>(
          decoration: const InputDecoration(labelText: 'Select Muscle Group'),
          value: selectedMuscleGroup,
          items: muscleGroups
              .map((group) => DropdownMenuItem(value: group, child: Text(group)))
              .toList(),
          onChanged: (value) {
            setState(() {
              selectedMuscleGroup = value;
              isCustom = value == 'Custom Exercise';
              selectedExercise = null;
              selectedVariation = null;
              selectedEquipment = null;
              isSingleArm = false;
              isSingleLeg = false;
              customExerciseController.clear();
            });
            _updateExerciseName();
          },
        ),
        // const SizedBox(height: 10),
        if (isCustom)
          TextField(
            controller: customExerciseController,
            decoration: const InputDecoration(
              labelText: 'Enter Custom Exercise',
              border: OutlineInputBorder(),
            ),
            onChanged: (value) => _updateExerciseName(),
          )
        else if (selectedMuscleGroup != null &&
            exercisesByMuscle.containsKey(selectedMuscleGroup))
          DropdownButtonFormField<String>(
            decoration: const InputDecoration(labelText: 'Select Exercise'),
            value: selectedExercise,
            items: exercisesByMuscle[selectedMuscleGroup]!
                .map((exercise) =>
                    DropdownMenuItem(value: exercise, child: Text(exercise)))
                .toList(),
            onChanged: (value) {
              setState(() {
                selectedExercise = value;
                selectedVariation = null;
                selectedEquipment = null;
                isSingleArm = false;
                isSingleLeg = false;
              });
              _updateExerciseName();
            },
          ),
        // const SizedBox(height: 10),
        // Conditional additional dropdown for variations
        if (selectedMuscleGroup == 'Chest' &&
            (selectedExercise == 'Press' || selectedExercise == 'Fly'))
          DropdownButtonFormField<String>(
            decoration: const InputDecoration(labelText: 'Select Variation'),
            value: selectedVariation,
            items: chestVariations
                .map((variation) =>
                    DropdownMenuItem(value: variation, child: Text(variation)))
                .toList(),
            onChanged: (value) {
              setState(() {
                selectedVariation = value;
              });
              _updateExerciseName();
            },
          )
        else if (selectedMuscleGroup == 'Arms' && selectedExercise == 'Curl')
          DropdownButtonFormField<String>(
            decoration: const InputDecoration(labelText: 'Select Curl Variation'),
            value: selectedVariation,
            items: armCurlVariations
                .map((variation) =>
                    DropdownMenuItem(value: variation, child: Text(variation)))
                .toList(),
            onChanged: (value) {
              setState(() {
                selectedVariation = value;
              });
              _updateExerciseName();
            },
          )
        else if (selectedMuscleGroup == 'Back' && selectedExercise == 'Row')
          DropdownButtonFormField<String>(
            decoration: const InputDecoration(labelText: 'Select Row Variation'),
            value: selectedVariation,
            items: backRowVariations
                .map((variation) =>
                    DropdownMenuItem(value: variation, child: Text(variation)))
                .toList(),
            onChanged: (value) {
              setState(() {
                selectedVariation = value;
              });
              _updateExerciseName();
            },
          )
        else if (selectedMuscleGroup == 'Legs' && selectedExercise == 'Squat')
          DropdownButtonFormField<String>(
            decoration: const InputDecoration(labelText: 'Select Squat Variation'),
            value: selectedVariation,
            items: squatVariations
                .map((variation) =>
                    DropdownMenuItem(value: variation, child: Text(variation)))
                .toList(),
            onChanged: (value) {
              setState(() {
                selectedVariation = value;
              });
              _updateExerciseName();
            },
          ),
        // const SizedBox(height: 10),
        // Always show the equipment dropdown if an exercise is selected
        if (!isCustom && selectedExercise != null)
          DropdownButtonFormField<String>(
            decoration: const InputDecoration(labelText: 'Select Equipment'),
            value: selectedEquipment,
            items: equipmentOptions
                .map((option) =>
                    DropdownMenuItem(value: option, child: Text(option)))
                .toList(),
            onChanged: (value) {
              setState(() {
                selectedEquipment = value;
              });
              _updateExerciseName();
            },
          ),
        // const SizedBox(height: 10),
        // Always show checkboxes for Single Arm and Single Leg
        Row(
          children: [
            Checkbox(
              value: isSingleArm,
              onChanged: (value) {
                setState(() {
                  isSingleArm = value ?? false;
                });
                _updateExerciseName();
              },
            ),
            const Text('Single Arm (SA)'),
            const SizedBox(width: 20),
            Checkbox(
              value: isSingleLeg,
              onChanged: (value) {
                setState(() {
                  isSingleLeg = value ?? false;
                });
                _updateExerciseName();
              },
            ),
            const Text('Single Leg (SL)'),
          ],
        ),
        const SizedBox(height: 10),
        // Preview of the user's exercise name
        Text(
          'Your Exercise: ${_buildFinalExerciseName()}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}