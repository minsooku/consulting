import 'package:consulting_fe/api/models/fitness_models.dart';

/// Static mock data matching the backend FitnessResponse schema.
/// Dates are computed relative to the current week so today always shows data.
class MockFitness {
  static FitnessResponse response() {
    final today = DateTime.now();
    // Start from the Monday of the current week
    final monday = today.subtract(Duration(days: today.weekday - 1));
    final start = DateTime(monday.year, monday.month, monday.day);

    return FitnessResponse(
      daily: _buildDaily(start),
      weekly: _buildWeekly(),
    );
  }

  static final FitnessPrompt prompt = FitnessPrompt(
    name: 'Alex',
    physique: const Physique(height: 178, weight: 78, gender: 'Male', age: 28),
    goalType: 'hypertrophy',
    experience: 'Intermediate',
    daysPerWeek: 4,
    diet: true,
  );

  // ── Daily ──────────────────────────────────────────────────────────────────

  static List<DailyPlan> _buildDaily(DateTime start) {
    final plans = <DailyPlan>[];
    for (var i = 0; i < 28; i++) {
      final date = start.add(Duration(days: i));
      plans.add(DailyPlan(date: date, blocks: _blocksFor(date.weekday)));
    }
    return plans;
  }

  static List<DailyBlock> _blocksFor(int weekday) {
    return switch (weekday) {
      1 => [_upperBody(), _habit('Monday Mindset'), _nutrition()],         // Mon
      2 => [_lowerBody(), _habit('Progress Photo'), _nutrition()],         // Tue
      3 => [_activeRecovery()],                                            // Wed
      4 => [_cardioCore(), _habit('Hydration Check'), _nutrition()],       // Thu
      5 => [_pushDay(), _habit('Weekly Weigh-in'), _nutrition()],          // Fri
      6 => [_restRecovery()],                                              // Sat
      _ => [],                                                             // Sun – full rest
    };
  }

  // ── Workout blocks ────────────────────────────────────────────────────────

  static const String location = 'Eppley Recreation Center, UMD';

  static DailyBlock _upperBody() => DailyBlock(
    title: 'Upper Body Strength',
    category: 'workout',
    durationMin: 60,
    details: [
      ChecklistItem(label: 'Bench Press', targetValue: '4 × 8 reps'),
      ChecklistItem(label: 'Incline Dumbbell Press', targetValue: '3 × 10 reps'),
      ChecklistItem(label: 'Pull-ups', targetValue: '3 × 8 reps'),
      ChecklistItem(label: 'Seated Cable Row', targetValue: '3 × 12 reps'),
      ChecklistItem(label: 'Overhead Press', targetValue: '3 × 10 reps'),
      ChecklistItem(label: 'Tricep Pushdown', targetValue: '3 × 15 reps'),
      ChecklistItem(label: 'Bicep Curl', targetValue: '3 × 12 reps'),
    ],
  );

  static DailyBlock _lowerBody() => DailyBlock(
    title: 'Lower Body Strength',
    category: 'workout',
    durationMin: 65,
    details: [
      ChecklistItem(label: 'Back Squat', targetValue: '4 × 8 reps'),
      ChecklistItem(label: 'Romanian Deadlift', targetValue: '3 × 10 reps'),
      ChecklistItem(label: 'Leg Press', targetValue: '3 × 12 reps'),
      ChecklistItem(label: 'Walking Lunges', targetValue: '3 × 10 each'),
      ChecklistItem(label: 'Leg Curl (Machine)', targetValue: '3 × 12 reps'),
      ChecklistItem(label: 'Calf Raises', targetValue: '4 × 20 reps'),
    ],
  );

  static DailyBlock _cardioCore() => DailyBlock(
    title: 'Cardio & Core',
    category: 'workout',
    durationMin: 45,
    details: [
      ChecklistItem(label: 'Treadmill Moderate Run', targetValue: '20 min'),
      ChecklistItem(label: 'Plank Hold', targetValue: '3 × 60 sec'),
      ChecklistItem(label: 'Hanging Knee Raise', targetValue: '3 × 15 reps'),
      ChecklistItem(label: 'Russian Twist', targetValue: '3 × 20 reps'),
      ChecklistItem(label: 'Mountain Climbers', targetValue: '3 × 30 sec'),
      ChecklistItem(label: 'Bicycle Crunches', targetValue: '3 × 20 reps'),
    ],
  );

  static DailyBlock _pushDay() => DailyBlock(
    title: 'Push Day',
    category: 'workout',
    durationMin: 55,
    details: [
      ChecklistItem(label: 'Flat Barbell Press', targetValue: '4 × 6 reps'),
      ChecklistItem(label: 'Incline Smith Machine', targetValue: '3 × 10 reps'),
      ChecklistItem(label: 'Cable Chest Fly', targetValue: '3 × 14 reps'),
      ChecklistItem(label: 'Lateral Raise', targetValue: '4 × 15 reps'),
      ChecklistItem(label: 'Overhead Tricep Extension', targetValue: '3 × 12 reps'),
      ChecklistItem(label: 'Push-ups (Burnout)', targetValue: '2 × max'),
    ],
  );

  static DailyBlock _activeRecovery() => DailyBlock(
    title: 'Active Recovery',
    category: 'recovery',
    durationMin: 30,
    details: [
      ChecklistItem(label: 'Light Walk or Bike', targetValue: '20 min'),
      ChecklistItem(label: 'Full-body Foam Roll', targetValue: '10 min'),
      ChecklistItem(label: 'Hip Flexor Stretch', targetValue: '2 × 60 sec each'),
      ChecklistItem(label: 'Thoracic Mobility', targetValue: '10 reps'),
    ],
  );

  static DailyBlock _restRecovery() => DailyBlock(
    title: 'Rest & Recovery',
    category: 'recovery',
    durationMin: 20,
    details: [
      ChecklistItem(label: 'Gentle Full-body Stretch', targetValue: '15 min'),
      ChecklistItem(label: 'Contrast Shower', targetValue: '5 min'),
      ChecklistItem(label: 'Sleep 8h+ tonight'),
    ],
  );

  // ── Nutrition block ───────────────────────────────────────────────────────

  static DailyBlock _nutrition() => DailyBlock(
    title: 'Daily Nutrition',
    category: 'nutrition',
    durationMin: 15,
    details: [
      ChecklistItem(label: 'Protein', targetValue: 160, unit: 'g'),
      ChecklistItem(label: 'Carbohydrates', targetValue: 250, unit: 'g'),
      ChecklistItem(label: 'Healthy Fats', targetValue: 65, unit: 'g'),
      ChecklistItem(label: 'Water', targetValue: 3.5, unit: 'L'),
      ChecklistItem(label: 'Pre-workout meal (1h before)'),
      ChecklistItem(label: 'Post-workout protein shake'),
    ],
  );

  // ── Habit blocks ──────────────────────────────────────────────────────────

  static DailyBlock _habit(String title) => DailyBlock(
    title: title,
    category: 'habit',
    durationMin: 5,
    details: _habitDetails(title),
  );

  static List<ChecklistItem> _habitDetails(String title) {
    return switch (title) {
      'Monday Mindset' => [
        ChecklistItem(label: 'Set 3 goals for the week'),
        ChecklistItem(label: '10 min journaling'),
        ChecklistItem(label: 'Review last week\'s wins'),
      ],
      'Progress Photo' => [
        ChecklistItem(label: 'Take front photo'),
        ChecklistItem(label: 'Take side photo'),
        ChecklistItem(label: 'Log in progress folder'),
      ],
      'Hydration Check' => [
        ChecklistItem(label: 'Drank 3L+ water today'),
        ChecklistItem(label: 'No sugary drinks'),
      ],
      'Weekly Weigh-in' => [
        ChecklistItem(label: 'Morning weight (fasted)'),
        ChecklistItem(label: 'Log to tracking app'),
        ChecklistItem(label: 'Adjust plan if needed'),
      ],
      _ => [ChecklistItem(label: title)],
    };
  }

  // ── Weekly summaries ──────────────────────────────────────────────────────

  static List<WeeklyPlan> _buildWeekly() => [
    WeeklyPlan(
      weekNumber: 1,
      theme: 'Foundation Building',
      notes:
          'Master the movement patterns before adding load. Focus on full range of motion, '
          'controlled tempo, and establishing a sustainable routine. Soreness is expected — '
          'prioritize sleep and nutrition.',
      details: [
        ChecklistItem(label: 'Complete all 4 workouts'),
        ChecklistItem(label: 'Protein intake', targetValue: 160, unit: 'g/day'),
        ChecklistItem(label: 'Sleep', targetValue: 8, unit: 'h/night'),
        ChecklistItem(label: 'Water', targetValue: 3.5, unit: 'L/day'),
        ChecklistItem(label: 'Track every meal'),
        ChecklistItem(label: 'No alcohol this week'),
      ],
    ),
    WeeklyPlan(
      weekNumber: 2,
      theme: 'Progressive Overload',
      notes:
          'Add 2.5–5 kg to major lifts where you hit the top of the rep range last week. '
          'Body is adapting — push harder while maintaining perfect form. Recovery is equally important.',
      details: [
        ChecklistItem(label: 'Increase main lifts by 2.5–5 kg'),
        ChecklistItem(label: 'Protein intake', targetValue: 165, unit: 'g/day'),
        ChecklistItem(label: 'Sleep', targetValue: 8, unit: 'h/night'),
        ChecklistItem(label: 'Water', targetValue: 3.5, unit: 'L/day'),
        ChecklistItem(label: 'Take weekly progress photo'),
        ChecklistItem(label: 'Foam roll daily'),
      ],
    ),
    WeeklyPlan(
      weekNumber: 3,
      theme: 'Intensity Boost',
      notes:
          'Drop sets and supersets introduced to maximize hypertrophy stimulus. '
          'You may feel fatigue accumulate — this is normal. '
          'Nutrition and sleep quality are critical this week.',
      details: [
        ChecklistItem(label: 'Complete all 4 workouts'),
        ChecklistItem(label: 'Protein intake', targetValue: 170, unit: 'g/day'),
        ChecklistItem(label: 'Carbs on training days', targetValue: 280, unit: 'g'),
        ChecklistItem(label: 'Sleep', targetValue: 8, unit: 'h/night'),
        ChecklistItem(label: 'Creatine daily', targetValue: 5, unit: 'g'),
        ChecklistItem(label: 'Weekly weigh-in'),
      ],
    ),
    WeeklyPlan(
      weekNumber: 4,
      theme: 'Peak & Reassess',
      notes:
          'Final week of the block. Push for personal records on key lifts. '
          'Reassess measurements and photos at end of week. '
          'Plan your deload or next training block.',
      details: [
        ChecklistItem(label: 'Attempt 1–2 rep PRs on main lifts'),
        ChecklistItem(label: 'Protein intake', targetValue: 170, unit: 'g/day'),
        ChecklistItem(label: 'Sleep', targetValue: 8, unit: 'h/night'),
        ChecklistItem(label: 'Final progress photos & measurements'),
        ChecklistItem(label: 'Plan next 4-week block'),
        ChecklistItem(label: 'Schedule deload week after'),
      ],
    ),
  ];
}
