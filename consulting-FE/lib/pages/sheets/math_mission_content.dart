import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:consulting_fe/api/games_api.dart';
import 'package:consulting_fe/api/models/game_models.dart';
import 'package:consulting_fe/components/common/sheet_header.dart';
import 'package:consulting_fe/components/platform/platform_button.dart';
import 'package:consulting_fe/const/app_colors.dart';
import 'package:consulting_fe/const/app_fonts.dart';

class MathMissionContent extends StatefulWidget {
  const MathMissionContent({super.key, this.onResult});

  final ValueChanged<dynamic>? onResult;

  @override
  State<MathMissionContent> createState() => _MathMissionContentState();
}

class _MathMissionContentState extends State<MathMissionContent> {
  static const _difficulties = ['easy', 'normal', 'hard'];
  static const _difficultyLabels = {
    'easy': 'Easy',
    'normal': 'Normal',
    'hard': 'Hard',
  };
  static const _counts = [3, 5, 10];

  String _difficulty = 'normal';
  int _count = 3;

  List<MathProblem>? _problems;
  int _currentIndex = 0;
  int _correctCount = 0;
  bool _loading = false;
  bool? _lastAnswerCorrect;
  bool _finished = false;
  final _answerController = TextEditingController();
  final _answerFocus = FocusNode();

  @override
  void dispose() {
    _answerController.dispose();
    _answerFocus.dispose();
    super.dispose();
  }

  Future<void> _startTest() async {
    setState(() => _loading = true);
    try {
      final problems = await Future.wait(
        List.generate(_count, (_) => GamesApi.instance.getMathProblem()),
      );
      if (!mounted) return;
      setState(() {
        _problems = problems;
        _currentIndex = 0;
        _correctCount = 0;
        _lastAnswerCorrect = null;
        _finished = false;
        _loading = false;
      });
      _answerFocus.requestFocus();
    } catch (_) {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  Future<void> _submitAnswer() async {
    final answer = int.tryParse(_answerController.text.trim());
    if (answer == null || _problems == null) return;
    final problem = _problems![_currentIndex];

    setState(() => _loading = true);
    try {
      final correct = await GamesApi.instance.verifyMathAnswer(
        problem.sessionId ?? 0,
        answer,
      );
      if (!mounted) return;
      if (correct) _correctCount++;
      setState(() {
        _lastAnswerCorrect = correct;
        _loading = false;
      });

      await Future.delayed(const Duration(milliseconds: 800));
      if (!mounted) return;

      if (_currentIndex + 1 < _problems!.length) {
        setState(() {
          _currentIndex++;
          _lastAnswerCorrect = null;
          _answerController.clear();
        });
        _answerFocus.requestFocus();
      } else {
        setState(() => _finished = true);
      }
    } catch (_) {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  void _reset() {
    setState(() {
      _problems = null;
      _currentIndex = 0;
      _correctCount = 0;
      _lastAnswerCorrect = null;
      _finished = false;
      _answerController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SheetHeader(
          title: 'Math Challenge',
          showGrabber: false,
          subtitle: _problems != null && !_finished
              ? 'Problem ${_currentIndex + 1} of ${_problems!.length}'
              : null,
          onClose: () => widget.onResult?.call(null),
        ),
        Expanded(
          child: _problems == null
              ? _buildPresetView()
              : _finished
              ? _buildResultView()
              : _buildProblemView(),
        ),
      ],
    );
  }

  Widget _buildPresetView() {
    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            physics: const BouncingScrollPhysics(),
            children: [
              _sectionLabel('Difficulty'),
              const SizedBox(height: 10),
              Container(
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.sub, width: 0.5),
                ),
                child: Row(
                  children: List.generate(_difficulties.length, (i) {
                    final d = _difficulties[i];
                    final selected = d == _difficulty;
                    return Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _difficulty = d),
                        behavior: HitTestBehavior.opaque,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          decoration: BoxDecoration(
                            color: selected
                                ? AppColors.mainPoint
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(13),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            _difficultyLabels[d]!,
                            style: TextStyle(
                              fontFamily: AppFonts.normal,
                              fontSize: 15,
                              fontWeight: selected
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                              color: selected
                                  ? AppColors.mainPointText
                                  : AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ),
              const SizedBox(height: 28),
              _sectionLabel('Number of Problems'),
              const SizedBox(height: 10),
              Container(
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.sub, width: 0.5),
                ),
                child: Row(
                  children: List.generate(_counts.length, (i) {
                    final c = _counts[i];
                    final selected = c == _count;
                    return Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _count = c),
                        behavior: HitTestBehavior.opaque,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          decoration: BoxDecoration(
                            color: selected
                                ? AppColors.mainPoint
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(13),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            '$c',
                            style: TextStyle(
                              fontFamily: AppFonts.normal,
                              fontSize: 15,
                              fontWeight: selected
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                              color: selected
                                  ? AppColors.mainPointText
                                  : AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
          child: PlatformButton(
            text: 'Start Test',
            height: 56,
            isProminentGlass: true,
            onPressed: _loading ? null : _startTest,
          ),
        ),
      ],
    );
  }

  Widget _buildProblemView() {
    final problem = _problems![_currentIndex];
    final borderColor = _lastAnswerCorrect == null
        ? AppColors.sub
        : _lastAnswerCorrect!
        ? AppColors.success
        : AppColors.danger;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          const Spacer(),
          Text(
            problem.question,
            style: const TextStyle(
              fontFamily: AppFonts.normal,
              fontSize: 40,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
              letterSpacing: 2,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 28),
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: borderColor, width: 1.5),
            ),
            child: TextField(
              controller: _answerController,
              focusNode: _answerFocus,
              keyboardType: const TextInputType.numberWithOptions(signed: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[-0-9]')),
              ],
              textAlign: TextAlign.center,
              onSubmitted: (_) => _submitAnswer(),
              style: const TextStyle(
                fontFamily: AppFonts.normal,
                fontSize: 32,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
              decoration: const InputDecoration(
                border: InputBorder.none,
                hintText: '?',
                hintStyle: TextStyle(
                  fontFamily: AppFonts.normal,
                  fontSize: 32,
                  fontWeight: FontWeight.w500,
                  color: AppColors.sub,
                ),
                contentPadding: EdgeInsets.symmetric(
                  vertical: 16,
                  horizontal: 16,
                ),
              ),
            ),
          ),
          const Spacer(flex: 2),
          PlatformButton(
            text: 'Submit',
            height: 56,
            isProminentGlass: true,
            onPressed: _loading || _lastAnswerCorrect != null
                ? null
                : _submitAnswer,
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildResultView() {
    final allCorrect = _correctCount == _problems!.length;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          const Spacer(),
          _ResultBadge(success: allCorrect),
          const SizedBox(height: 20),
          Text(
            allCorrect ? 'All Correct!' : 'Try Again',
            style: const TextStyle(
              fontFamily: AppFonts.normal,
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '$_correctCount / ${_problems!.length}',
            style: const TextStyle(
              fontFamily: AppFonts.normal,
              fontSize: 17,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
          const Spacer(),
          PlatformButton(
            text: 'Try Again',
            height: 56,
            isProminentGlass: true,
            tint: AppColors.danger,
            onPressed: _startTest,
          ),
          const SizedBox(height: 10),
          PlatformButton(
            text: 'Done',
            height: 56,
            isProminentGlass: true,
            onPressed: _reset,
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _sectionLabel(String text) {
    return Text(
      text.toUpperCase(),
      style: TextStyle(
        fontFamily: AppFonts.normal,
        fontSize: 12,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.4,
        color: AppColors.textSecondary.withValues(alpha: 0.55),
      ),
    );
  }
}

class _ResultBadge extends StatelessWidget {
  const _ResultBadge({required this.success});
  final bool success;

  @override
  Widget build(BuildContext context) {
    final color = success ? AppColors.success : AppColors.danger;
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withValues(alpha: 0.1),
      ),
      child: Icon(
        success ? Icons.check_rounded : Icons.close_rounded,
        size: 40,
        color: color,
      ),
    );
  }
}
