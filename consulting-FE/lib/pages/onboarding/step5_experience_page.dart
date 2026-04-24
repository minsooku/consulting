import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:consulting_fe/const/app_colors.dart';
import 'package:consulting_fe/const/app_fonts.dart';
import 'package:consulting_fe/pages/onboarding/onboarding_data.dart';

class Step5ExperienceContent extends StatefulWidget {
  const Step5ExperienceContent({
    super.key,
    required this.data,
    required this.onDataChanged,
  });

  final OnboardingData data;
  final ValueChanged<OnboardingData> onDataChanged;

  @override
  State<Step5ExperienceContent> createState() => _Step5ExperienceContentState();
}

class _Step5ExperienceContentState extends State<Step5ExperienceContent> {
  late String _value;

  static const _levels = [
    (
      id: 'beginner',
      label: 'Beginner',
      sub: 'Less than 6 months',
    ),
    (
      id: 'intermediate',
      label: 'Intermediate',
      sub: '6 months – 2 years',
    ),
    (
      id: 'advanced',
      label: 'Advanced',
      sub: '2 – 5 years consistent training',
    ),
    (
      id: 'elite',
      label: 'Elite',
      sub: '5+ years, competitive level',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _value = widget.data.experience;
  }

  void _select(String id) {
    setState(() => _value = id);
    widget.onDataChanged(widget.data.copyWith(experience: id));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (int i = 0; i < _levels.length; i++)
          FadeInUp(
            duration: const Duration(milliseconds: 350),
            delay: Duration(milliseconds: i * 60),
            curve: Curves.fastEaseInToSlowEaseOut,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: GestureDetector(
                onTap: () => _select(_levels[i].id),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.fastEaseInToSlowEaseOut,
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    color: _value == _levels[i].id
                        ? AppColors.accent.withValues(alpha: 0.12)
                        : AppColors.surface,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: _value == _levels[i].id
                          ? AppColors.accent
                          : AppColors.sub,
                      width: _value == _levels[i].id ? 1.5 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _levels[i].label,
                              style: TextStyle(
                                fontFamily: AppFonts.normal,
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: _value == _levels[i].id
                                    ? AppColors.accent
                                    : AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              _levels[i].sub,
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
                      if (_value == _levels[i].id)
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
