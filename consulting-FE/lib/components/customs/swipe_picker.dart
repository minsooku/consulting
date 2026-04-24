import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import 'package:consulting_fe/components/customs/number_flow/number_flow_widget.dart';
import 'package:consulting_fe/const/app_colors.dart';
import 'package:consulting_fe/const/app_fonts.dart';

/// Horizontal-swipe number picker.
///
/// Drag right to increase, left to decrease. Each integer step fires a
/// light haptic and animates the digit with NumberFlow (rolling odometer).
///
/// ```dart
/// SwipePicker(
///   value: _hour,
///   min: 1,
///   max: 12,
///   wrap: true,
///   onChanged: (v) => setState(() => _hour = v),
/// )
/// ```
class SwipePicker extends StatefulWidget {
  const SwipePicker({
    super.key,
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
    this.wrap = true,
    this.padded = false,
    this.label,
    this.width = 100,
    this.height = 90,
    this.fontSize = 50,
  });

  /// Current value — managed externally.
  final int value;
  final int min;
  final int max;
  final ValueChanged<int> onChanged;

  /// Wrap around at the boundaries (e.g. 59 → 0 for minutes).
  final bool wrap;

  /// Zero-pad single-digit numbers ("09" instead of "9").
  final bool padded;

  /// Optional small label underneath the number.
  final String? label;

  final double width;
  final double height;
  final double fontSize;

  @override
  State<SwipePicker> createState() => _SwipePickerState();
}

class _SwipePickerState extends State<SwipePicker>
    with SingleTickerProviderStateMixin {
  double _dragAccum = 0;
  int _trend = 0;
  bool _active = false;

  late final AnimationController _pressCtrl;
  late final Animation<double> _scaleAnim;

  // Pixels of horizontal drag required to advance one step.
  static const _stepPx = 18.0;

  @override
  void initState() {
    super.initState();
    _pressCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scaleAnim = Tween<double>(
      begin: 1.0,
      end: 0.96,
    ).animate(CurvedAnimation(parent: _pressCtrl, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _pressCtrl.dispose();
    super.dispose();
  }

  void _onDragStart(DragStartDetails _) {
    setState(() {
      _active = true;
      _dragAccum = 0;
    });
    _pressCtrl.forward();
  }

  void _onDragUpdate(DragUpdateDetails d) {
    _dragAccum += d.delta.dx;
    while (_dragAccum >= _stepPx) {
      _dragAccum -= _stepPx;
      _step(1);
    }
    while (_dragAccum <= -_stepPx) {
      _dragAccum += _stepPx;
      _step(-1);
    }
  }

  void _onDragEnd(DragEndDetails _) {
    setState(() {
      _active = false;
      _dragAccum = 0;
    });
    _pressCtrl.reverse();
  }

  void _step(int delta) {
    final range = widget.max - widget.min + 1;
    final int next;
    if (widget.wrap) {
      next =
          ((widget.value - widget.min + delta) % range + range) % range +
          widget.min;
    } else {
      next = (widget.value + delta).clamp(widget.min, widget.max);
    }
    if (next == widget.value) return;
    setState(() => _trend = delta > 0 ? 1 : -1);
    HapticFeedback.selectionClick();
    widget.onChanged(next);
  }

  @override
  Widget build(BuildContext context) {
    final fmt = widget.padded ? NumberFormat('00') : NumberFormat('#0');
    final canLeft = widget.wrap || widget.value > widget.min;
    final canRight = widget.wrap || widget.value < widget.max;

    return GestureDetector(
      onHorizontalDragStart: _onDragStart,
      onHorizontalDragUpdate: _onDragUpdate,
      onHorizontalDragEnd: _onDragEnd,
      child: ScaleTransition(
        scale: _scaleAnim,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            color: _active
                ? AppColors.sub.withValues(alpha: 0.6)
                : AppColors.background,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: _active
                  ? AppColors.textSecondary.withValues(alpha: 0.35)
                  : AppColors.sub,
              width: 1.2,
            ),
            boxShadow: _active
                ? []
                : [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Left chevron
              Positioned(
                left: 6,
                child: AnimatedOpacity(
                  opacity: canLeft ? (_active ? 0.55 : 0.22) : 0.07,
                  duration: const Duration(milliseconds: 150),
                  child: const Icon(
                    Icons.chevron_left_rounded,
                    size: 18,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              // Right chevron
              Positioned(
                right: 6,
                child: AnimatedOpacity(
                  opacity: canRight ? (_active ? 0.55 : 0.22) : 0.07,
                  duration: const Duration(milliseconds: 150),
                  child: const Icon(
                    Icons.chevron_right_rounded,
                    size: 18,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              // Number + optional label
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  NumberFlow(
                    value: widget.value.toDouble(),
                    format: fmt,
                    trend: _trend,
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeOut,
                    style: TextStyle(
                      fontFamily: AppFonts.round,
                      fontSize: widget.fontSize,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                      height: 1,
                    ),
                  ),
                  if (widget.label != null) ...[
                    const SizedBox(height: 5),
                    Text(
                      widget.label!,
                      style: const TextStyle(
                        fontFamily: AppFonts.normal,
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textSecondary,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
