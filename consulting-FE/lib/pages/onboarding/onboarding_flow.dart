import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:consulting_fe/api/models/fitness_models.dart';
import 'package:consulting_fe/components/customs/number_flow/number_flow.dart';
import 'package:consulting_fe/components/platform/platform_button.dart';
import 'package:consulting_fe/const/app_colors.dart';
import 'package:consulting_fe/pages/homepage.dart';
import 'package:consulting_fe/pages/onboarding/onboarding_data.dart';
import 'package:consulting_fe/pages/onboarding/onboarding_shared.dart';
import 'package:consulting_fe/pages/onboarding/step0_name_page.dart';
import 'package:consulting_fe/pages/onboarding/step1_weight_page.dart';
import 'package:consulting_fe/pages/onboarding/step2_age_page.dart';
import 'package:consulting_fe/pages/onboarding/step3_gender_page.dart';
import 'package:consulting_fe/pages/onboarding/step4_goal_page.dart';
import 'package:consulting_fe/pages/onboarding/step5_experience_page.dart';
import 'package:consulting_fe/pages/onboarding/step6_workout_days_page.dart';
import 'package:consulting_fe/pages/onboarding/step7_diet_page.dart';
import 'package:consulting_fe/provider/fitness_provider.dart';

class OnboardingFlow extends StatefulWidget {
  const OnboardingFlow({super.key, OnboardingData? data})
    : data = data ?? const OnboardingData();
  final OnboardingData data;

  @override
  State<OnboardingFlow> createState() => _OnboardingFlowState();
}

class _OnboardingFlowState extends State<OnboardingFlow> {
  int _step = 0;
  late OnboardingData _data;
  bool _submitting = false;
  bool _exiting = false;
  String? _submitError;

  static const _totalSteps = 8;

  static const _titleLine1 = [
    "What's your",
    "What's your",
    'How old',
    "What's your",
    "What's your",
    "What's your",
    'How many days',
    'Do you want a',
  ];
  static const _titleLine2 = [
    'name?',
    'weight?',
    'are you?',
    'gender?',
    'fitness goal?',
    'experience?',
    'per week?',
    'diet plan?',
  ];
  static const _gaps = [20.0, 12.0, 12.0, 20.0, 12.0, 12.0, 12.0, 16.0];

  @override
  void initState() {
    super.initState();
    _data = widget.data;
  }

  void _updateData(OnboardingData data) => setState(() => _data = data);

  void _next() {
    if (_step < _totalSteps - 1) {
      setState(() => _step++);
    } else {
      _submit();
    }
  }

  void _back() {
    if (_step == 0) {
      Navigator.of(context).pop();
    } else {
      setState(() => _step--);
    }
  }

  /// Convert onboarding answers → API request body.
  FitnessPrompt _buildPrompt() => FitnessPrompt(
    name: _data.name.trim().isEmpty ? 'User' : _data.name.trim(),
    physique: Physique(
      height: 170, // height step not collected; use sensible default
      weight: _data.weight,
      gender: _data.gender,
      age: _data.age,
    ),
    goalType: _data.goalType,
    experience: _data.experience,
    daysPerWeek: _data.workoutDaysPerWeek,
    diet: _data.hasDiet,
  );

  Future<void> _submit() async {
    setState(() {
      _submitting = true;
      _submitError = null;
    });

    final fp = context.read<FitnessProvider>();

    // Load mock immediately so the user doesn't wait.
    fp.loadMock();

    // Fire-and-forget: attempt real API in background to update if it responds.
    fp.generatePlan(_buildPrompt()).ignore();

    setState(() => _exiting = true);
    await Future.delayed(const Duration(milliseconds: 350));
    if (!mounted) return;

    Navigator.of(context).pushAndRemoveUntil(
      PageRouteBuilder(
        pageBuilder: (_, _, _) => const HomePage(fromOnboarding: true),
        transitionsBuilder: (_, animation, _, child) =>
            FadeTransition(opacity: animation, child: child),
        transitionDuration: const Duration(milliseconds: 500),
      ),
      (_) => false,
    );
  }

  bool get _stepComplete {
    switch (_step) {
      case 0:
        return _data.name.trim().isNotEmpty;
      case 4:
        return _data.goalType.isNotEmpty;
      case 5:
        return _data.experience.isNotEmpty;
      default:
        return true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final viewInsets = MediaQuery.viewInsetsOf(context);
    final keyboardInset = viewInsets.bottom;
    final bottomPad = MediaQuery.paddingOf(context).bottom;

    final String continueLabel =
        _step == _totalSteps - 1 ? 'Get My Plan' : 'Continue';

    final VoidCallback? onContinue =
        (_submitting || !_stepComplete)
        ? null
        : () {
            FocusScope.of(context).unfocus();
            _next();
          };

    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _back();
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        resizeToAvoidBottomInset: false,
        body: AnimatedSlide(
          offset: _exiting ? const Offset(0, -0.5) : Offset.zero,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInCubic,
          child: AnimatedOpacity(
            opacity: _exiting ? 0.0 : 1.0,
            duration: const Duration(milliseconds: 300),
            child: SafeArea(
              bottom: false,
              child: Column(
                children: [
                  SizedBox(
                    height: 52,
                    child: Padding(
                      padding: const EdgeInsets.only(
                        left: 24,
                        top: 12,
                        right: 16,
                      ),
                      child: Row(
                        children: [
                          PlatformIconButton(
                            iosIcon: 'chevron.backward',
                            androidIcon: Icons.arrow_back_ios_new_rounded,
                            onPressed: _back,
                            isGlass: true,
                          ),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: SingleChildScrollView(
                        reverse: true,
                        padding: const EdgeInsets.only(
                          left: 24,
                          right: 24,
                          bottom: 12,
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            RollingText(
                              text: 'Step ${_step + 1}',
                              style: kStepLabelStyle,
                              duration: const Duration(milliseconds: 350),
                            ),
                            const SizedBox(height: 6),
                            RollingText(
                              text: _titleLine1[_step],
                              style: kTitleStyle,
                              duration: const Duration(milliseconds: 400),
                            ),
                            RollingText(
                              text: _titleLine2[_step],
                              style: kTitleStyle,
                              duration: const Duration(milliseconds: 400),
                            ),
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.fastEaseInToSlowEaseOut,
                              height: _gaps[_step],
                            ),
                            AnimatedSwitcher(
                              duration: const Duration(milliseconds: 250),
                              switchInCurve: Curves.fastEaseInToSlowEaseOut,
                              switchOutCurve: Curves.fastEaseInToSlowEaseOut,
                              layoutBuilder: (currentChild, previousChildren) {
                                return Stack(
                                  clipBehavior: Clip.none,
                                  children: [
                                    for (final child in previousChildren)
                                      Positioned(
                                        left: 0,
                                        right: 0,
                                        child: child,
                                      ),
                                    ?currentChild,
                                  ],
                                );
                              },
                              transitionBuilder: (child, animation) =>
                                  FadeTransition(
                                    opacity: animation,
                                    child: child,
                                  ),
                              child: KeyedSubtree(
                                key: ValueKey(_step),
                                child: _buildContent(),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  if (_submitError != null)
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 4,
                      ),
                      child: Text(
                        _submitError!,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.redAccent,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  Padding(
                    padding: EdgeInsets.only(
                      left: 24,
                      top: 8,
                      right: 24,
                      bottom: bottomPad + 20 + keyboardInset,
                    ),
                    child: PlatformButton(
                      text: _submitting ? 'Saving\u2026' : continueLabel,
                      onPressed: onContinue,
                      isProminentGlass: true,
                      height: 56,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    switch (_step) {
      case 0:
        return Step0NameContent(data: _data, onDataChanged: _updateData);
      case 1:
        return Step1WeightContent(data: _data, onDataChanged: _updateData);
      case 2:
        return Step2AgeContent(data: _data, onDataChanged: _updateData);
      case 3:
        return Step3GenderContent(data: _data, onDataChanged: _updateData);
      case 4:
        return Step4GoalContent(data: _data, onDataChanged: _updateData);
      case 5:
        return Step5ExperienceContent(data: _data, onDataChanged: _updateData);
      case 6:
        return Step6WorkoutDaysContent(data: _data, onDataChanged: _updateData);
      case 7:
        return Step7DietContent(data: _data, onDataChanged: _updateData);
      default:
        return const SizedBox.shrink();
    }
  }
}
