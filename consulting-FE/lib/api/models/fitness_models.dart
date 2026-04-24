// Dart models mirroring the backend fitness_scheme.py

class ChecklistItem {
  ChecklistItem({
    required this.label,
    this.targetValue,
    this.unit,
    this.done = false,
  });

  final String label;
  final dynamic targetValue; // num | String | null
  final String? unit;
  bool done;

  factory ChecklistItem.fromJson(Map<String, dynamic> json) => ChecklistItem(
    label: json['label'] as String,
    targetValue: json['target_value'],
    unit: json['unit'] as String?,
    done: json['done'] as bool? ?? false,
  );

  Map<String, dynamic> toJson() => {
    'label': label,
    if (targetValue != null) 'target_value': targetValue,
    if (unit != null) 'unit': unit,
    'done': done,
  };

  /// Human-readable summary of target, e.g. "150 g" or "8 h"
  String get targetDisplay {
    if (targetValue == null) return '';
    final v = targetValue.toString();
    return unit != null ? '$v $unit' : v;
  }
}

class DailyBlock {
  const DailyBlock({
    required this.title,
    required this.category,
    required this.durationMin,
    required this.details,
  });

  final String title;

  /// One of: "workout" | "nutrition" | "habit" | "recovery"
  final String category;
  final int durationMin;
  final List<ChecklistItem> details;

  factory DailyBlock.fromJson(Map<String, dynamic> json) => DailyBlock(
    title: json['title'] as String,
    category: json['category'] as String,
    durationMin: json['duration_min'] as int,
    details: (json['details'] as List<dynamic>? ?? [])
        .map((e) => ChecklistItem.fromJson(e as Map<String, dynamic>))
        .toList(),
  );

  Map<String, dynamic> toJson() => {
    'title': title,
    'category': category,
    'duration_min': durationMin,
    'details': details.map((e) => e.toJson()).toList(),
  };
}

class DailyPlan {
  const DailyPlan({required this.date, required this.blocks});

  final DateTime date;
  final List<DailyBlock> blocks;

  factory DailyPlan.fromJson(Map<String, dynamic> json) => DailyPlan(
    date: DateTime.parse(json['date'] as String),
    blocks: (json['blocks'] as List<dynamic>)
        .map((e) => DailyBlock.fromJson(e as Map<String, dynamic>))
        .toList(),
  );

  Map<String, dynamic> toJson() => {
    'date': date.toIso8601String().substring(0, 10),
    'blocks': blocks.map((e) => e.toJson()).toList(),
  };

  List<DailyBlock> get workoutBlocks =>
      blocks.where((b) => b.category == 'workout').toList();

  bool get isRestDay => workoutBlocks.isEmpty;
}

class WeeklyPlan {
  const WeeklyPlan({
    required this.weekNumber,
    required this.theme,
    required this.notes,
    required this.details,
  });

  final int weekNumber;
  final String theme;
  final String notes;
  final List<ChecklistItem> details;

  factory WeeklyPlan.fromJson(Map<String, dynamic> json) => WeeklyPlan(
    weekNumber: json['week_number'] as int,
    theme: json['theme'] as String,
    notes: json['notes'] as String,
    details: (json['details'] as List<dynamic>? ?? [])
        .map((e) => ChecklistItem.fromJson(e as Map<String, dynamic>))
        .toList(),
  );

  Map<String, dynamic> toJson() => {
    'week_number': weekNumber,
    'theme': theme,
    'notes': notes,
    'details': details.map((e) => e.toJson()).toList(),
  };
}

class FitnessResponse {
  const FitnessResponse({required this.daily, required this.weekly});

  final List<DailyPlan> daily;
  final List<WeeklyPlan> weekly;

  factory FitnessResponse.fromJson(Map<String, dynamic> json) => FitnessResponse(
    daily: (json['daily'] as List<dynamic>)
        .map((e) => DailyPlan.fromJson(e as Map<String, dynamic>))
        .toList(),
    weekly: (json['weekly'] as List<dynamic>)
        .map((e) => WeeklyPlan.fromJson(e as Map<String, dynamic>))
        .toList(),
  );

  Map<String, dynamic> toJson() => {
    'daily': daily.map((e) => e.toJson()).toList(),
    'weekly': weekly.map((e) => e.toJson()).toList(),
  };
}

// ── Request models ─────────────────────────────────────────────────────────

class Physique {
  const Physique({
    required this.height,
    required this.weight,
    required this.gender,
    required this.age,
  });

  final int height; // cm
  final int weight; // kg
  final String gender; // "Male" | "Female"
  final int age;

  Map<String, dynamic> toJson() => {
    'height': height,
    'weight': weight,
    'gender': gender,
    'age': age,
  };

  factory Physique.fromJson(Map<String, dynamic> json) => Physique(
    height: json['height'] as int,
    weight: json['weight'] as int,
    gender: json['gender'] as String,
    age: json['age'] as int,
  );
}

class FitnessPrompt {
  const FitnessPrompt({
    required this.name,
    required this.physique,
    required this.goalType,
    required this.experience,
    required this.daysPerWeek,
    required this.diet,
  });

  final String name;
  final Physique physique;

  /// e.g. "hypertrophy", "weight_loss", "endurance", "general_fitness"
  final String goalType;

  /// "Beginner" | "Intermediate" | "Advanced"
  final String experience;

  /// 1–7
  final int daysPerWeek;

  final bool diet;

  Map<String, dynamic> toJson() => {
    'name': name,
    'physique': physique.toJson(),
    'goalType': goalType,
    'experience': experience,
    'daysPerWeek': daysPerWeek,
    'diet': diet,
  };

  factory FitnessPrompt.fromJson(Map<String, dynamic> json) => FitnessPrompt(
    name: json['name'] as String,
    physique: Physique.fromJson(json['physique'] as Map<String, dynamic>),
    goalType: json['goalType'] as String,
    experience: json['experience'] as String,
    daysPerWeek: json['daysPerWeek'] as int,
    diet: json['diet'] as bool,
  );
}
