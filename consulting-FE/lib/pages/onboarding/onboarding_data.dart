class OnboardingData {
  final String name;
  final int weight; // kg
  final int age;
  final String gender; // 'Male' | 'Female'
  final String goalType;
  final String experience;
  final int workoutDaysPerWeek; // 1–7
  final bool hasDiet;

  const OnboardingData({
    this.name = '',
    this.weight = 70,
    this.age = 25,
    this.gender = 'Male',
    this.goalType = '',
    this.experience = '',
    this.workoutDaysPerWeek = 3,
    this.hasDiet = false,
  });

  OnboardingData copyWith({
    String? name,
    int? weight,
    int? age,
    String? gender,
    String? goalType,
    String? experience,
    int? workoutDaysPerWeek,
    bool? hasDiet,
  }) =>
      OnboardingData(
        name: name ?? this.name,
        weight: weight ?? this.weight,
        age: age ?? this.age,
        gender: gender ?? this.gender,
        goalType: goalType ?? this.goalType,
        experience: experience ?? this.experience,
        workoutDaysPerWeek: workoutDaysPerWeek ?? this.workoutDaysPerWeek,
        hasDiet: hasDiet ?? this.hasDiet,
      );
}
