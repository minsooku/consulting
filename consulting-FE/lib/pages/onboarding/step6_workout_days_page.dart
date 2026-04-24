import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:consulting_fe/components/customs/number_flow/number_flow.dart';
import 'package:consulting_fe/components/platform/platform_button.dart';
import 'package:consulting_fe/const/app_colors.dart';
import 'package:consulting_fe/const/app_fonts.dart';
import 'package:consulting_fe/pages/onboarding/onboarding_data.dart';

class Step6WorkoutDaysContent extends StatefulWidget {
  const Step6WorkoutDaysContent({
    super.key,
    required this.data,
    required this.onDataChanged,
  });

  final OnboardingData data;
  final ValueChanged<OnboardingData> onDataChanged;

  @override
  State<Step6WorkoutDaysContent> createState() =>
      _Step6WorkoutDaysContentState();
}

class _Step6WorkoutDaysContentState extends State<Step6WorkoutDaysContent> {
  late int _value;

  static const _numStyle = TextStyle(
    fontFamily: AppFonts.normal,
    fontSize: 72,
    fontWeight: FontWeight.w800,
    color: AppColors.textPrimary,
    height: 1,
  );
  static const _unitStyle = TextStyle(
    fontFamily: AppFonts.normal,
    fontSize: 20,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
  );

  @override
  void initState() {
    super.initState();
    _value = widget.data.workoutDaysPerWeek;
  }

  void _change(int delta) {
    final next = (_value + delta).clamp(1, 7);
    if (next != _value) {
      setState(() => _value = next);
      widget.onDataChanged(widget.data.copyWith(workoutDaysPerWeek: next));
    }
  }

  void _setDirect(int v) {
    setState(() => _value = v);
    widget.onDataChanged(widget.data.copyWith(workoutDaysPerWeek: v));
  }

  String get _restDaysLabel {
    final rest = 7 - _value;
    if (rest == 0) return 'No rest days';
    if (rest == 1) return '1 rest day per week';
    return '$rest rest days per week';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        FadeInUp(
          duration: const Duration(milliseconds: 350),
          curve: Curves.fastEaseInToSlowEaseOut,
          child: Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                PlatformIconButton(
                  iosIcon: 'minus',
                  androidIcon: Icons.remove_rounded,
                  onPressed: _value > 1 ? () => _change(-1) : null,
                  size: 44,
                ),
                const SizedBox(width: 20),
                SizedBox(
                  width: 80,
                  height: 80,
                  child: OverflowBox(
                    alignment: Alignment.center,
                    minWidth: 0,
                    maxWidth: double.infinity,
                    minHeight: 0,
                    maxHeight: double.infinity,
                    child: NumberFlow(
                      value: _value,
                      style: _numStyle,
                      duration: const Duration(milliseconds: 350),
                      curve: Curves.fastEaseInToSlowEaseOut,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                const Padding(
                  padding: EdgeInsets.only(bottom: 8),
                  child: Text('/ 7', style: _unitStyle),
                ),
                const SizedBox(width: 20),
                PlatformIconButton(
                  iosIcon: 'plus',
                  androidIcon: Icons.add_rounded,
                  onPressed: _value < 7 ? () => _change(1) : null,
                  size: 44,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        FadeInUp(
          duration: const Duration(milliseconds: 350),
          delay: const Duration(milliseconds: 60),
          curve: Curves.fastEaseInToSlowEaseOut,
          child: Row(
            children: [
              for (int d = 1; d <= 7; d++) ...[
                if (d > 1) const SizedBox(width: 6),
                Expanded(
                  child: GestureDetector(
                    onTap: () => _setDirect(d),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.fastEaseInToSlowEaseOut,
                      height: 44,
                      decoration: BoxDecoration(
                        color: d <= _value
                            ? AppColors.accent.withValues(alpha: 0.15)
                            : AppColors.surface,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: d <= _value ? AppColors.accent : AppColors.sub,
                          width: d <= _value ? 1.5 : 1,
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        '$d',
                        style: TextStyle(
                          fontFamily: AppFonts.normal,
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: d <= _value
                              ? AppColors.accent
                              : AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 12),
        FadeInUp(
          duration: const Duration(milliseconds: 350),
          delay: const Duration(milliseconds: 100),
          curve: Curves.fastEaseInToSlowEaseOut,
          child: Center(
            child: Text(
              _restDaysLabel,
              style: TextStyle(
                fontFamily: AppFonts.normal,
                fontSize: 14,
                color: AppColors.textSecondary.withValues(alpha: 0.8),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
