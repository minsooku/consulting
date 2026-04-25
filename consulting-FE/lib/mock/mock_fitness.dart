import 'package:consulting_fe/api/models/fitness_models.dart';

/// Static mock fitness plan — use this whenever the backend is unavailable.
/// Data matches the exact structure the backend returns.
class MockFitness {
  MockFitness._();

  static const String location = 'Eppley Recreation Center, UMD';

  // ── Prompt used to "generate" this plan ───────────────────────────────────
  static const FitnessPrompt prompt = FitnessPrompt(
    name: 'User',
    physique: Physique(height: 175, weight: 75, gender: 'Male', age: 21),
    goalType: 'hypertrophy',
    experience: 'Intermediate',
    daysPerWeek: 4,
    diet: true,
  );

  // ── Helpers ───────────────────────────────────────────────────────────────

  static ChecklistItem _ex(
    String label,
    String target,
    String? machine,
  ) => ChecklistItem(
    label: label,
    targetValue: target,
    unit: 'sets x reps',
    machine: machine,
  );

  static ChecklistItem _stat(
    String label,
    dynamic value,
    String unit,
  ) => ChecklistItem(label: label, targetValue: value, unit: unit);

  static ChecklistItem _task(String label) =>
      ChecklistItem(label: label);

  // ── Daily blocks ──────────────────────────────────────────────────────────

  static DailyBlock get _chestTriceps => DailyBlock(
    title: 'Chest & Triceps',
    category: 'workout',
    durationMin: 60,
    details: [
      _ex('Converging Chest Press',      '4x10', 'Converging Chest Press.png'),
      _ex('Iso-Lateral Wide Chest',      '3x12', 'Iso-Lateral Wide Chest.png'),
      _ex('Iso-Lateral Incline Press',   '3x10', 'Iso-Lateral Incline Press.png'),
      _ex('Rear Delt Pec Fly',           '3x12', 'Rear Delt Pec Fly.png'),
      _ex('Triceps Extension',           '3x12', 'Triceps Extension.png'),
    ],
  );

  static DailyBlock get _backBiceps => DailyBlock(
    title: 'Back & Biceps',
    category: 'workout',
    durationMin: 65,
    details: [
      _ex('Iso-Lateral High Row',        '4x10', 'Iso-Lateral High Row.png'),
      _ex('Iso-Lateral Low Row',         '3x12', 'Iso-Lateral Low Row.png'),
      _ex('Axiom Series Lat Pulldown',   '3x12', 'Axiom Series Lat Pulldown.png'),
      _ex('Iso-Lateral Row',             '3x10', 'Iso-Lateral Row.png'),
      _ex('Insignia Series Biceps Curl', '3x12', 'Insignia Series Biceps Curl.png'),
      _ex('Biceps Curl',                 '3x12', 'Biceps Curl.png'),
    ],
  );

  static DailyBlock get _legs => DailyBlock(
    title: 'Legs',
    category: 'workout',
    durationMin: 65,
    details: [
      _ex('Axiom Series Leg Extension',  '4x12', 'Axiom Series Leg Extension.png'),
      _ex('Axiom Series Leg Curl',       '4x12', 'Axiom Series Leg Curl.png'),
      _ex('Seated Leg Curl',             '3x12', 'Seated Leg Curl.png'),
      _ex('Inner Thigh',                 '3x15', 'Inner Thigh.png'),
      _ex('Outer Thigh',                 '3x15', 'Outer Thigh.png'),
    ],
  );

  static DailyBlock get _shouldersCore => DailyBlock(
    title: 'Shoulders & Core',
    category: 'workout',
    durationMin: 60,
    details: [
      _ex('Iso-Lateral Shoulder Press',          '4x10', 'Iso-Lateral Shoulder Press.png'),
      _ex('Converging Shoulder Press',           '3x12', 'Converging Shoulder Press.png'),
      _ex('Insignia Series Lateral Raise',       '3x15', 'Insignia Series Lateral Raise.png'),
      _ex('Rear Delt Pec Fly',                   '3x15', 'Rear Delt Pec Fly.png'),
      _ex('Axiom Series Hip Abductor Adductor',  '3x15', 'Axiom Series Hip Abductor Adductor.png'),
    ],
  );

  static DailyBlock _nutrition({
    required int protein,
    required int calories,
    required double water,
  }) => DailyBlock(
    title: 'Daily Nutrition',
    category: 'nutrition',
    durationMin: 15,
    details: [
      _stat('Protein intake',  protein,  'g'),
      _stat('Calorie target',  calories, 'kcal'),
      _stat('Water intake',    water,    'L'),
    ],
  );

  static DailyBlock get _eveningHabits => DailyBlock(
    title: 'Evening Habits',
    category: 'habit',
    durationMin: 10,
    details: [
      _task('Log workout in app'),
      _task('Sleep by 11pm'),
    ],
  );

  static DailyBlock get _activeRecoveryChest => DailyBlock(
    title: 'Active Recovery',
    category: 'recovery',
    durationMin: 30,
    details: [
      _stat('Light walk or stretching', 30, 'min'),
      _stat('Foam roll chest & triceps', 10, 'min'),
    ],
  );

  static DailyBlock get _restDay => DailyBlock(
    title: 'Rest Day',
    category: 'recovery',
    durationMin: 20,
    details: [
      _stat('Full body stretch',       20, 'min'),
      _stat('Get 8hrs sleep tonight',   8, 'hrs'),
    ],
  );

  static DailyBlock get _weeklyPrep => DailyBlock(
    title: 'Weekly Prep',
    category: 'habit',
    durationMin: 20,
    details: [
      _task('Meal prep for the week'),
      _task('Plan workout schedule'),
    ],
  );

  static DailyBlock get _activeRecoveryLegs => DailyBlock(
    title: 'Active Recovery',
    category: 'recovery',
    durationMin: 30,
    details: [
      _stat('Light walk',     30, 'min'),
      _stat('Foam roll legs', 10, 'min'),
    ],
  );

  static DailyBlock get _postWorkoutRecovery => DailyBlock(
    title: 'Post-Workout Recovery',
    category: 'recovery',
    durationMin: 15,
    details: [
      _stat('Quad & hamstring stretch', 10, 'min'),
      _task('Ice or compression if sore'),
    ],
  );

  // ── Full response ─────────────────────────────────────────────────────────

  static FitnessResponse response() => FitnessResponse(
    daily: [
      // Apr 24 — Chest & Triceps
      DailyPlan(
        date: DateTime(2026, 4, 24),
        blocks: [
          _chestTriceps,
          _nutrition(protein: 170, calories: 2800, water: 3),
          _eveningHabits,
        ],
      ),
      // Apr 25 — Active Recovery
      DailyPlan(
        date: DateTime(2026, 4, 25),
        blocks: [
          _activeRecoveryChest,
          _nutrition(protein: 150, calories: 2400, water: 3),
        ],
      ),
      // Apr 26 — Rest Day
      DailyPlan(
        date: DateTime(2026, 4, 26),
        blocks: [
          _restDay,
          _nutrition(protein: 150, calories: 2400, water: 3),
          _weeklyPrep,
        ],
      ),
      // Apr 27 — Back & Biceps
      DailyPlan(
        date: DateTime(2026, 4, 27),
        blocks: [
          _backBiceps,
          _nutrition(protein: 170, calories: 2800, water: 3),
          _eveningHabits,
        ],
      ),
      // Apr 28 — Legs
      DailyPlan(
        date: DateTime(2026, 4, 28),
        blocks: [
          _legs,
          _nutrition(protein: 170, calories: 2900, water: 3.5),
          _postWorkoutRecovery,
        ],
      ),
      // Apr 29 — Active Recovery
      DailyPlan(
        date: DateTime(2026, 4, 29),
        blocks: [
          _activeRecoveryLegs,
          _nutrition(protein: 150, calories: 2400, water: 3),
        ],
      ),
      // Apr 30 — Shoulders & Core
      DailyPlan(
        date: DateTime(2026, 4, 30),
        blocks: [
          _shouldersCore,
          _nutrition(protein: 170, calories: 2800, water: 3),
          _eveningHabits,
        ],
      ),
    ],
    weekly: [
      WeeklyPlan(
        weekNumber: 1,
        theme: 'Foundation — Build the Habit',
        notes:
            'First week focus is on form and consistency. Keep weights moderate '
            '(RPE 6-7). Rest 90-120s between sets. Do not skip the nutrition '
            'targets — caloric surplus is essential for hypertrophy.',
        details: [
          _stat('Hit all 4 workout days',     4,   'days'),
          _stat('Average daily protein',      160, 'g'),
          _stat('Average daily water',        3,   'L'),
          _stat('Sleep 7+ hrs per night',     7,   'hrs'),
          _stat('Log every session in app',   4,   'sessions'),
        ],
      ),
    ],
  );
}
