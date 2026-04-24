import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:consulting_fe/components/platform/platform_button.dart';
import 'package:consulting_fe/const/app_colors.dart';
import 'package:consulting_fe/pages/onboarding/onboarding_data.dart';

class Step3GenderContent extends StatefulWidget {
  const Step3GenderContent({
    super.key,
    required this.data,
    required this.onDataChanged,
  });

  final OnboardingData data;
  final ValueChanged<OnboardingData> onDataChanged;

  @override
  State<Step3GenderContent> createState() => _Step3GenderContentState();
}

class _Step3GenderContentState extends State<Step3GenderContent> {
  late String _value;

  static const _options = [
    (id: 'Male', label: 'Male', icon: Icons.male_rounded),
    (id: 'Female', label: 'Female', icon: Icons.female_rounded),
  ];

  @override
  void initState() {
    super.initState();
    _value = widget.data.gender;
  }

  void _select(String id) {
    setState(() => _value = id);
    widget.onDataChanged(widget.data.copyWith(gender: id));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (int i = 0; i < _options.length; i++)
          FadeInUp(
            duration: const Duration(milliseconds: 350),
            delay: Duration(milliseconds: i * 60),
            curve: Curves.fastEaseInToSlowEaseOut,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: PlatformButton(
                  text: _options[i].label,
                  onPressed: () => _select(_options[i].id),
                  isProminentGlass: _value == _options[i].id,
                  isGlass: _value != _options[i].id,
                  tint: _value == _options[i].id ? AppColors.accent : null,
                  height: 56,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
