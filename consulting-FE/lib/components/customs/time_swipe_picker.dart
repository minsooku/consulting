import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import 'package:consulting_fe/components/customs/number_flow/number_flow_widget.dart';
import 'package:consulting_fe/components/customs/number_flow/rolling_text.dart';
import 'package:consulting_fe/const/app_colors.dart';
import 'package:consulting_fe/const/app_fonts.dart';

/// Single unified time picker — no boxes, just numbers.
///
/// • Left zone  (hour area): drag left/right to change hours (1–12).
/// • Right zone (minute area): drag left/right to change minutes (0–59).
/// • AM/PM is derived from [hour24] and updates automatically.
/// • Each step fires a light haptic + NumberFlow roll animation.
///
/// [hour24] is 0–23 so that AM/PM can be derived cleanly. Convert from a
/// "9:00 AM" string before constructing, and convert back in [onChanged].
class TimeSwipePicker extends StatefulWidget {
  const TimeSwipePicker({
    super.key,
    required this.hour24,
    required this.minute,
    required this.onChanged,
    this.fontSize = 68,
  });

  /// 0–23 (24-hour clock). Display converts to 1–12 + AM/PM.
  final int hour24;

  /// 0–59.
  final int minute;

  /// Fired when either value changes; provides the new hour24 and minute.
  final void Function(int hour24, int minute) onChanged;

  final double fontSize;

  @override
  State<TimeSwipePicker> createState() => _TimeSwipePickerState();
}

class _TimeSwipePickerState extends State<TimeSwipePicker> {
  double _hourAccum = 0;
  double _minAccum = 0;
  int _hourTrend = 0;
  int _minTrend = 0;
  bool _hourActive = false;
  bool _minActive = false;

  // Pixels of horizontal drag per one step.
  static const _stepPx = 18.0;

  // ── Derived display values ─────────────────────────────────────────────────

  int get _displayHour =>
      widget.hour24 % 12 == 0 ? 12 : widget.hour24 % 12;

  String get _amPm => widget.hour24 < 12 ? 'AM' : 'PM';

  // ── Gesture handlers ───────────────────────────────────────────────────────

  void _onHourStart(DragStartDetails _) =>
      setState(() { _hourActive = true; _hourAccum = 0; });

  void _onHourUpdate(DragUpdateDetails d) {
    _hourAccum += d.delta.dx;
    while (_hourAccum >= _stepPx) { _hourAccum -= _stepPx; _stepHour(1); }
    while (_hourAccum <= -_stepPx) { _hourAccum += _stepPx; _stepHour(-1); }
  }

  void _onHourEnd(DragEndDetails _) =>
      setState(() { _hourActive = false; _hourAccum = 0; });

  void _onMinStart(DragStartDetails _) =>
      setState(() { _minActive = true; _minAccum = 0; });

  void _onMinUpdate(DragUpdateDetails d) {
    _minAccum += d.delta.dx;
    while (_minAccum >= _stepPx) { _minAccum -= _stepPx; _stepMin(1); }
    while (_minAccum <= -_stepPx) { _minAccum += _stepPx; _stepMin(-1); }
  }

  void _onMinEnd(DragEndDetails _) =>
      setState(() { _minActive = false; _minAccum = 0; });

  // ── Value stepping ─────────────────────────────────────────────────────────

  void _stepHour(int delta) {
    final next = ((widget.hour24 + delta) % 24 + 24) % 24;
    setState(() => _hourTrend = delta > 0 ? 1 : -1);
    HapticFeedback.selectionClick();
    widget.onChanged(next, widget.minute);
  }

  void _stepMin(int delta) {
    final next = ((widget.minute + delta) % 60 + 60) % 60;
    setState(() => _minTrend = delta > 0 ? 1 : -1);
    HapticFeedback.selectionClick();
    widget.onChanged(widget.hour24, next);
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final hourFmt = NumberFormat('#0');
    final minFmt = NumberFormat('00');

    final numStyle = TextStyle(
      fontFamily: AppFonts.round,
      fontSize: widget.fontSize,
      fontWeight: FontWeight.w800,
      color: AppColors.textPrimary,
      height: 1,
    );

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // ── Hour zone ──────────────────────────────────────────────────────
        GestureDetector(
          onHorizontalDragStart: _onHourStart,
          onHorizontalDragUpdate: _onHourUpdate,
          onHorizontalDragEnd: _onHourEnd,
          child: Padding(
            // Generous horizontal padding = wide touch target.
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: AnimatedOpacity(
              opacity: _hourActive ? 1.0 : 0.82,
              duration: const Duration(milliseconds: 120),
              child: NumberFlow(
                value: _displayHour.toDouble(),
                format: hourFmt,
                trend: _hourTrend,
                duration: const Duration(milliseconds: 180),
                curve: Curves.easeOut,
                style: numStyle,
              ),
            ),
          ),
        ),

        // ── Colon ──────────────────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: Text(
            ':',
            style: TextStyle(
              fontFamily: AppFonts.round,
              fontSize: widget.fontSize * 0.82,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary.withValues(alpha: 0.35),
              height: 1,
            ),
          ),
        ),

        // ── Minute zone ────────────────────────────────────────────────────
        GestureDetector(
          onHorizontalDragStart: _onMinStart,
          onHorizontalDragUpdate: _onMinUpdate,
          onHorizontalDragEnd: _onMinEnd,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: AnimatedOpacity(
              opacity: _minActive ? 1.0 : 0.82,
              duration: const Duration(milliseconds: 120),
              child: NumberFlow(
                value: widget.minute.toDouble(),
                format: minFmt,
                trend: _minTrend,
                duration: const Duration(milliseconds: 180),
                curve: Curves.easeOut,
                style: numStyle,
              ),
            ),
          ),
        ),

        // ── AM / PM ────────────────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.only(left: 6, bottom: 10),
          child: RollingText(
            text: _amPm,
            style: TextStyle(
              fontFamily: AppFonts.round,
              fontSize: widget.fontSize * 0.28,
              fontWeight: FontWeight.w700,
              color: AppColors.textSecondary,
            ),
            duration: const Duration(milliseconds: 280),
          ),
        ),
      ],
    );
  }
}
