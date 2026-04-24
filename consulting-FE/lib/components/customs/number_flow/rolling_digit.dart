import 'dart:math' show max;

import 'package:flutter/material.dart';

/// A single digit (0-9) that animates with a slot-machine rolling effect
/// when its value changes.
class RollingDigit extends StatefulWidget {
  const RollingDigit({
    super.key,
    required this.digit,
    required this.style,
    this.duration = const Duration(milliseconds: 600),
    this.curve = Curves.easeInOutCubic,
    this.trend = 0,
  }) : assert(digit >= 0 && digit <= 9);

  final int digit;
  final TextStyle style;
  final Duration duration;
  final Curve curve;

  /// `1` = always roll upward, `-1` = always downward, `0` = shortest path.
  final int trend;

  @override
  State<RollingDigit> createState() => _RollingDigitState();
}

class _RollingDigitState extends State<RollingDigit>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late Animation<double> _anim;
  CurvedAnimation? _curved;
  double _offset = 0;

  TextStyle? _prevStyle;
  double _h = 0;
  double _maxWidth = 0;
  final List<double> _widths = List.filled(10, 0);

  @override
  void initState() {
    super.initState();
    _offset = widget.digit.toDouble();
    _anim = AlwaysStoppedAnimation(_offset);
    _ctrl = AnimationController(duration: widget.duration, vsync: this)
      ..addStatusListener((s) {
        if (s == AnimationStatus.completed) _offset = _anim.value;
      });
    _measure();
  }

  @override
  void dispose() {
    _curved?.dispose();
    _ctrl.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(RollingDigit old) {
    super.didUpdateWidget(old);
    if (old.style != widget.style) _measure();
    if (old.digit != widget.digit) _roll();
  }

  void _measure() {
    if (_prevStyle == widget.style) return;
    _prevStyle = widget.style;
    for (var d = 0; d <= 9; d++) {
      final tp = TextPainter(
        text: TextSpan(text: '$d', style: widget.style),
        textDirection: TextDirection.ltr,
        maxLines: 1,
      )..layout();
      _widths[d] = tp.width;
      if (d == 0) _h = tp.height;
    }
    _maxWidth = _widths.reduce(max);
  }

  void _roll() {
    if (_ctrl.isAnimating) {
      _offset = _anim.value;
      _ctrl.stop();
    }

    final cur = (((_offset % 10) + 10) % 10).round() % 10;
    final diff = widget.digit - cur;
    final delta = switch (widget.trend) {
      1 => diff <= 0 ? diff + 10 : diff,
      -1 => diff >= 0 ? diff - 10 : diff,
      _ =>
        diff > 5
            ? diff - 10
            : diff < -5
            ? diff + 10
            : diff,
    };

    // Target must land on an integer so the digit is fully visible at rest.
    // _offset.round() snaps to the nearest integer base, then delta steps
    // forward/backward to the desired digit.
    final target = (_offset.round() + delta).toDouble();

    if ((target - _offset).abs() < 0.001) {
      _offset = target;
      return;
    }

    _curved?.dispose();
    _curved = CurvedAnimation(parent: _ctrl, curve: widget.curve);
    _anim = Tween<double>(begin: _offset, end: target).animate(_curved!);

    _ctrl
      ..duration = widget.duration
      ..forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, _) {
        final v = _ctrl.isAnimating ? _anim.value : _offset;
        var n = v % 10;
        if (n < 0) n += 10;
        final top = n.floor() % 10;
        final bot = (top + 1) % 10;
        final frac = n - n.floor();

        // Use the widest digit across 0–9 so the column width never changes
        // during animation — prevents neighbouring digits from shaking.
        final w = _maxWidth;

        return SizedBox(
          width: w,
          height: _h,
          child: Stack(
            clipBehavior: Clip.hardEdge,
            children: [
              Positioned(
                top: -frac * _h,
                left: 0,
                right: 0,
                child: Center(child: _tile(top)),
              ),
              Positioned(
                top: (1 - frac) * _h,
                left: 0,
                right: 0,
                child: Center(child: _tile(bot)),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _tile(int d) => Text('$d', style: widget.style);
}
