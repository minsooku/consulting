import 'dart:math' show max;

import 'package:flutter/material.dart';

/// Animated text that transitions each character individually with a
/// vertical slide + fade effect and per-character stagger.
///
/// ```dart
/// RollingText(
///   text: 'April',
///   style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
/// )
/// ```
class RollingText extends StatefulWidget {
  const RollingText({
    super.key,
    required this.text,
    this.style,
    this.duration = const Duration(milliseconds: 500),
    this.curve = Curves.fastEaseInToSlowEaseOut,
    this.staggerFraction = 0.04,
  });

  final String text;
  final TextStyle? style;
  final Duration duration;
  final Curve curve;

  /// Fraction of total animation duration to delay each successive character.
  /// `0.04` means each character starts 4 % of the total duration after the
  /// previous one, creating a subtle wave effect.
  final double staggerFraction;

  @override
  State<RollingText> createState() => _RollingTextState();
}

class _RollingTextState extends State<RollingText>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  String _oldText = '';
  String _newText = '';
  double _charHeight = 0;
  final Map<String, double> _widthCache = {};

  @override
  void initState() {
    super.initState();
    _oldText = widget.text;
    _newText = widget.text;
    _ctrl = AnimationController(
      duration: widget.duration,
      vsync: this,
      value: 1.0,
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(RollingText old) {
    super.didUpdateWidget(old);
    if (old.style != widget.style) {
      _widthCache.clear();
      _charHeight = 0;
    }
    if (old.text != widget.text) {
      _oldText = _ctrl.isAnimating ? _snapshot() : _newText;
      _newText = widget.text;
      _ctrl
        ..duration = widget.duration
        ..forward(from: 0);
    }
  }

  /// Captures the visually dominant characters at the current animation state
  /// so an interrupted transition doesn't "jump" to the previous target.
  String _snapshot() {
    final totalChars = max(_oldText.length, _newText.length);
    final buf = StringBuffer();
    for (var i = 0; i < totalChars; i++) {
      final oldChar = i < _oldText.length ? _oldText[i] : null;
      final newChar = i < _newText.length ? _newText[i] : null;
      final t = _charT(i, totalChars);
      if (t >= 0.5 && newChar != null) {
        buf.write(newChar);
      } else if (oldChar != null) {
        buf.write(oldChar);
      }
    }
    return buf.toString();
  }

  // -- Measurement -----------------------------------------------------------

  double _measureWidth(String char, TextStyle style) {
    return _widthCache[char] ??= () {
      final tp = TextPainter(
        text: TextSpan(text: char, style: style),
        textDirection: TextDirection.ltr,
        maxLines: 1,
      )..layout();
      if (_charHeight == 0) _charHeight = tp.height;
      return tp.width;
    }();
  }

  // -- Stagger ---------------------------------------------------------------

  double _charT(int index, int totalChars) {
    if (_ctrl.value == 1.0) return 1.0;
    if (_ctrl.value == 0.0) return 0.0;

    final totalStagger = ((totalChars - 1) * widget.staggerFraction).clamp(
      0.0,
      0.5,
    );
    final charDuration = 1.0 - totalStagger;
    final start = totalChars <= 1
        ? 0.0
        : (index * widget.staggerFraction).clamp(0.0, totalStagger);
    final end = (start + charDuration).clamp(start + 0.01, 1.0);

    final raw = ((_ctrl.value - start) / (end - start)).clamp(0.0, 1.0);
    return widget.curve.transform(raw);
  }

  // -- Build -----------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final style = widget.style ?? DefaultTextStyle.of(context).style;
    final totalChars = max(_oldText.length, _newText.length);

    if (totalChars == 0) return const SizedBox.shrink();
    _measureWidth('A', style);

    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, _) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(totalChars, (i) {
            final oldChar = i < _oldText.length ? _oldText[i] : null;
            final newChar = i < _newText.length ? _newText[i] : null;
            final t = _charT(i, totalChars);
            return _buildChar(oldChar, newChar, t, style);
          }),
        );
      },
    );
  }

  Widget _buildChar(
    String? oldChar,
    String? newChar,
    double t,
    TextStyle style,
  ) {
    if (oldChar == newChar && newChar != null) {
      return SizedBox(
        height: _charHeight,
        child: Text(newChar, style: style),
      );
    }

    final oldW = oldChar != null ? _measureWidth(oldChar, style) : 0.0;
    final newW = newChar != null ? _measureWidth(newChar, style) : 0.0;

    // Entering character (not in old text)
    if (oldChar == null) {
      return ClipRect(
        child: Align(
          alignment: Alignment.centerLeft,
          widthFactor: t.clamp(0.0, 1.0),
          child: Opacity(
            opacity: t.clamp(0.0, 1.0),
            child: SizedBox(
              height: _charHeight,
              child: Text(newChar!, style: style),
            ),
          ),
        ),
      );
    }

    // Exiting character (not in new text)
    if (newChar == null) {
      final inv = (1.0 - t).clamp(0.0, 1.0);
      return ClipRect(
        child: Align(
          alignment: Alignment.centerLeft,
          widthFactor: inv,
          child: Opacity(
            opacity: inv,
            child: SizedBox(
              height: _charHeight,
              child: Text(oldChar, style: style),
            ),
          ),
        ),
      );
    }

    // Transitioning character (different in old and new)
    final w = oldW + (newW - oldW) * t;
    return SizedBox(
      width: w,
      height: _charHeight,
      child: Stack(
        clipBehavior: Clip.hardEdge,
        children: [
          Positioned(
            top: -t * _charHeight,
            left: 0,
            child: Opacity(
              opacity: (1.0 - t).clamp(0.0, 1.0),
              child: SizedBox(
                height: _charHeight,
                child: Text(oldChar, style: style),
              ),
            ),
          ),
          Positioned(
            top: (1.0 - t) * _charHeight,
            left: 0,
            child: Opacity(
              opacity: t.clamp(0.0, 1.0),
              child: SizedBox(
                height: _charHeight,
                child: Text(newChar, style: style),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
