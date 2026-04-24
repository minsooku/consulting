import 'package:flutter/material.dart';
import 'package:consulting_fe/components/customs/number_flow/number_flow.dart';
import 'package:consulting_fe/components/platform/platform_button.dart';
import 'package:consulting_fe/const/app_colors.dart';
import 'package:consulting_fe/const/app_fonts.dart';
import 'package:consulting_fe/pages/onboarding/onboarding_data.dart';

class Step2AgeContent extends StatefulWidget {
  const Step2AgeContent({
    super.key,
    required this.data,
    required this.onDataChanged,
  });

  final OnboardingData data;
  final ValueChanged<OnboardingData> onDataChanged;

  @override
  State<Step2AgeContent> createState() => _Step2AgeContentState();
}

class _Step2AgeContentState extends State<Step2AgeContent> {
  late int _value;

  static const _min = 10;
  static const _max = 100;
  static const _presets = [18, 25, 30, 40, 50];

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
    _value = widget.data.age;
  }

  void _change(int delta) {
    final next = (_value + delta).clamp(_min, _max);
    if (next != _value) {
      setState(() => _value = next);
      widget.onDataChanged(widget.data.copyWith(age: next));
    }
  }

  void _setPreset(int p) {
    setState(() => _value = p);
    widget.onDataChanged(widget.data.copyWith(age: p));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              PlatformIconButton(
                iosIcon: 'minus',
                androidIcon: Icons.remove_rounded,
                onPressed: _value > _min ? () => _change(-1) : null,
                size: 44,
              ),
              const SizedBox(width: 20),
              SizedBox(
                width: 145,
                height: 80,
                child: OverflowBox(
                  alignment: Alignment.centerRight,
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
              const SizedBox(width: 6),
              const Padding(
                padding: EdgeInsets.only(bottom: 8),
                child: Text('yrs', style: _unitStyle),
              ),
              const SizedBox(width: 20),
              PlatformIconButton(
                iosIcon: 'plus',
                androidIcon: Icons.add_rounded,
                onPressed: () => _change(1),
                size: 44,
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            for (int i = 0; i < _presets.length; i++) ...[
              if (i > 0) const SizedBox(width: 8),
              Expanded(
                child: PlatformButton(
                  text: '${_presets[i]}',
                  onPressed: () => _setPreset(_presets[i]),
                  isProminentGlass: _value == _presets[i],
                  isGlass: _value != _presets[i],
                  height: 36,
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }
}
