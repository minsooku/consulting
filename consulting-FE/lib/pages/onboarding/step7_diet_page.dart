import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:consulting_fe/const/app_colors.dart';
import 'package:consulting_fe/const/app_fonts.dart';
import 'package:consulting_fe/pages/onboarding/onboarding_data.dart';

class Step7DietContent extends StatefulWidget {
  const Step7DietContent({
    super.key,
    required this.data,
    required this.onDataChanged,
  });

  final OnboardingData data;
  final ValueChanged<OnboardingData> onDataChanged;

  @override
  State<Step7DietContent> createState() => _Step7DietContentState();
}

class _Step7DietContentState extends State<Step7DietContent> {
  late bool _hasDiet;

  static const _options = [
    (
      value: true,
      label: 'Yes, include diet',
      sub: 'Get meal plans and nutrition checklists alongside workouts',
      icon: Icons.restaurant_rounded,
    ),
    (
      value: false,
      label: 'Workout only',
      sub: 'Focus on training — no nutrition guidance',
      icon: Icons.fitness_center_rounded,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _hasDiet = widget.data.hasDiet;
  }

  void _select(bool value) {
    setState(() => _hasDiet = value);
    widget.onDataChanged(widget.data.copyWith(hasDiet: value));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (int i = 0; i < _options.length; i++)
          FadeInUp(
            duration: const Duration(milliseconds: 350),
            delay: Duration(milliseconds: i * 80),
            curve: Curves.fastEaseInToSlowEaseOut,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: GestureDetector(
                onTap: () => _select(_options[i].value),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.fastEaseInToSlowEaseOut,
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 18,
                  ),
                  decoration: BoxDecoration(
                    color: _hasDiet == _options[i].value
                        ? AppColors.accent.withValues(alpha: 0.12)
                        : AppColors.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: _hasDiet == _options[i].value
                          ? AppColors.accent
                          : AppColors.sub,
                      width: _hasDiet == _options[i].value ? 1.5 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: _hasDiet == _options[i].value
                              ? AppColors.accent.withValues(alpha: 0.15)
                              : AppColors.sub.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          _options[i].icon,
                          size: 22,
                          color: _hasDiet == _options[i].value
                              ? AppColors.accent
                              : AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _options[i].label,
                              style: TextStyle(
                                fontFamily: AppFonts.normal,
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: _hasDiet == _options[i].value
                                    ? AppColors.accent
                                    : AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              _options[i].sub,
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
                      if (_hasDiet == _options[i].value) ...[
                        const SizedBox(width: 8),
                        Icon(
                          Icons.check_circle_rounded,
                          color: AppColors.accent,
                          size: 20,
                        ),
                      ],
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
