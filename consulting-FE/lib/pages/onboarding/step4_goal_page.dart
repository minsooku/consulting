import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:consulting_fe/const/app_colors.dart';
import 'package:consulting_fe/const/app_fonts.dart';
import 'package:consulting_fe/pages/onboarding/onboarding_data.dart';

class Step4GoalContent extends StatefulWidget {
  const Step4GoalContent({
    super.key,
    required this.data,
    required this.onDataChanged,
  });

  final OnboardingData data;
  final ValueChanged<OnboardingData> onDataChanged;

  @override
  State<Step4GoalContent> createState() => _Step4GoalContentState();
}

class _Step4GoalContentState extends State<Step4GoalContent> {
  late String _value;

  static const _goals = [
    (id: 'weight_loss', label: 'Weight Loss', sub: 'Burn fat & get leaner'),
    (id: 'muscle_gain', label: 'Muscle Gain', sub: 'Build strength & size'),
    (
      id: 'hypertrophy',
      label: 'Hypertrophy',
      sub: 'Maximise muscle volume',
    ),
    (
      id: 'endurance',
      label: 'Endurance',
      sub: 'Improve stamina & cardio',
    ),
    (id: 'general_fitness', label: 'General Fitness', sub: 'Stay active & healthy'),
  ];

  @override
  void initState() {
    super.initState();
    _value = widget.data.goalType;
  }

  void _select(String id) {
    setState(() => _value = id);
    widget.onDataChanged(widget.data.copyWith(goalType: id));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (int i = 0; i < _goals.length; i++)
          FadeInUp(
            duration: const Duration(milliseconds: 350),
            delay: Duration(milliseconds: i * 60),
            curve: Curves.fastEaseInToSlowEaseOut,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: GestureDetector(
                onTap: () => _select(_goals[i].id),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.fastEaseInToSlowEaseOut,
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    color: _value == _goals[i].id
                        ? AppColors.accent.withValues(alpha: 0.12)
                        : AppColors.surface,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: _value == _goals[i].id
                          ? AppColors.accent
                          : AppColors.sub,
                      width: _value == _goals[i].id ? 1.5 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _goals[i].label,
                              style: TextStyle(
                                fontFamily: AppFonts.normal,
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: _value == _goals[i].id
                                    ? AppColors.accent
                                    : AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              _goals[i].sub,
                              style: TextStyle(
                                fontFamily: AppFonts.normal,
                                fontSize: 13,
                                color: AppColors.textSecondary.withValues(
                                  alpha: 0.8,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (_value == _goals[i].id)
                        Icon(
                          Icons.check_circle_rounded,
                          color: AppColors.accent,
                          size: 20,
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
