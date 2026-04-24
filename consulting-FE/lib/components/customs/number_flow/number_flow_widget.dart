import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'number_flow_group.dart';
import 'rolling_digit.dart';

/// Animated number display that rolls individual digits like an odometer
/// when the value changes — a Flutter port of number-flow (React).
///
/// ```dart
/// NumberFlow(
///   value: 1234.56,
///   style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
///   format: NumberFormat.currency(symbol: '\$'),
///   duration: Duration(milliseconds: 800),
/// )
/// ```
class NumberFlow extends StatefulWidget {
  const NumberFlow({
    super.key,
    required this.value,
    this.style,
    this.format,
    this.prefix = '',
    this.suffix = '',
    this.duration,
    this.curve,
    this.trend,
    this.animated = true,
  });

  /// The numeric value to display.
  final num value;

  /// Text style for the rendered characters.
  final TextStyle? style;

  /// Optional [NumberFormat] for locale-aware formatting.
  /// Defaults to `#,##0.##########` (up to 10 decimal places, grouped).
  final NumberFormat? format;

  /// Text shown before the formatted number.
  final String prefix;

  /// Text shown after the formatted number.
  final String suffix;

  /// Animation duration. Falls back to [NumberFlowGroup] then 600 ms.
  final Duration? duration;

  /// Animation curve. Falls back to [NumberFlowGroup] then [Curves.easeInOutCubic].
  final Curve? curve;

  /// Roll direction: `1` up, `-1` down, `0` shortest path.
  final int? trend;

  /// Set `false` to disable animation (instant value change).
  final bool animated;

  @override
  State<NumberFlow> createState() => _NumberFlowState();
}

// ---------------------------------------------------------------------------

enum _Kind { digit, other }

class _Char {
  const _Char({
    required this.char,
    required this.kind,
    required this.key,
    this.digitValue,
  });

  final String char;
  final _Kind kind;
  final String key;
  final int? digitValue;
}

// ---------------------------------------------------------------------------

class _NumberFlowState extends State<NumberFlow>
    with SingleTickerProviderStateMixin {
  static const _defaultDuration = Duration(milliseconds: 600);
  static const _defaultCurve = Curves.easeInOutCubic;

  List<_Char> _chars = [];
  List<_Char> _exitingChars = [];
  Set<String> _enteringKeys = {};
  late final AnimationController _fadeCtrl;

  @override
  void initState() {
    super.initState();
    _chars = _parse(widget.value);
    _fadeCtrl = AnimationController(
      duration: widget.duration ?? _defaultDuration,
      vsync: this,
      value: 1.0,
    )..addStatusListener((s) {
        if (s == AnimationStatus.completed) {
          setState(() {
            _enteringKeys = {};
            _exitingChars = [];
          });
        }
      });
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(NumberFlow old) {
    super.didUpdateWidget(old);
    final changed = old.value != widget.value ||
        old.prefix != widget.prefix ||
        old.suffix != widget.suffix ||
        old.format != widget.format;

    if (!changed) return;

    final prevKeys = {for (final c in _chars) c.key};
    final newChars = _parse(widget.value);
    final newKeys = {for (final c in newChars) c.key};

    _exitingChars = _chars.where((c) => !newKeys.contains(c.key)).toList();
    _enteringKeys = newKeys.difference(prevKeys);
    _chars = newChars;

    if (widget.animated &&
        (_enteringKeys.isNotEmpty || _exitingChars.isNotEmpty)) {
      _fadeCtrl
        ..duration = widget.duration ?? _defaultDuration
        ..forward(from: 0);
    }
  }

  // -- Parsing ---------------------------------------------------------------

  List<_Char> _parse(num value) {
    final formatter =
        widget.format ?? NumberFormat('#,##0.##########');
    final numStr = formatter.format(value);
    final result = <_Char>[];

    for (var i = 0; i < widget.prefix.length; i++) {
      result.add(
        _Char(char: widget.prefix[i], kind: _Kind.other, key: 'pre_$i'),
      );
    }

    final groupSep = formatter.symbols.GROUP_SEP;
    final decSep = formatter.symbols.DECIMAL_SEP;
    final decIdx = numStr.indexOf(decSep);
    final intStr = decIdx >= 0 ? numStr.substring(0, decIdx) : numStr;

    int intDigitCount = 0;
    for (var i = 0; i < intStr.length; i++) {
      if (_isDigit(intStr[i])) intDigitCount++;
    }

    int intPos = intDigitCount - 1;
    int otherIdx = 0;
    for (var i = 0; i < intStr.length; i++) {
      final c = intStr[i];
      if (_isDigit(c)) {
        result.add(_Char(
          char: c,
          kind: _Kind.digit,
          key: 'int_$intPos',
          digitValue: c.codeUnitAt(0) - 48,
        ));
        intPos--;
      } else if (c == groupSep) {
        result.add(
          _Char(char: c, kind: _Kind.other, key: 'gsep_${intPos + 1}'),
        );
      } else {
        result.add(
          _Char(char: c, kind: _Kind.other, key: 'other_$otherIdx'),
        );
        otherIdx++;
      }
    }

    if (decIdx >= 0) {
      result.add(_Char(char: decSep, kind: _Kind.other, key: 'dsep'));
      final decStr = numStr.substring(decIdx + 1);
      int decPos = 0;
      for (var i = 0; i < decStr.length; i++) {
        final c = decStr[i];
        if (_isDigit(c)) {
          result.add(_Char(
            char: c,
            kind: _Kind.digit,
            key: 'dec_$decPos',
            digitValue: c.codeUnitAt(0) - 48,
          ));
          decPos++;
        }
      }
    }

    for (var i = 0; i < widget.suffix.length; i++) {
      result.add(
        _Char(char: widget.suffix[i], kind: _Kind.other, key: 'suf_$i'),
      );
    }

    return result;
  }

  static bool _isDigit(String c) {
    final code = c.codeUnitAt(0);
    return code >= 48 && code <= 57;
  }

  // -- Sort position for merging entering/exiting chars ----------------------

  static double _sortPos(String key) {
    if (key.startsWith('pre_')) return -10000.0 + int.parse(key.substring(4));
    if (key.startsWith('other_')) return -5000.0 + int.parse(key.substring(6));
    if (key.startsWith('int_')) return -2.0 * int.parse(key.substring(4));
    if (key.startsWith('gsep_')) return -2.0 * int.parse(key.substring(5)) + 1;
    if (key == 'dsep') return 1.0;
    if (key.startsWith('dec_')) return 2.0 + 2.0 * int.parse(key.substring(4));
    if (key.startsWith('suf_')) return 10000.0 + int.parse(key.substring(4));
    return 0.0;
  }

  // -- Build -----------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final group = NumberFlowGroup.maybeOf(context);
    final style = widget.style ?? DefaultTextStyle.of(context).style;
    final duration = widget.duration ?? group?.duration ?? _defaultDuration;
    final curve = widget.curve ?? group?.curve ?? _defaultCurve;
    final trend = widget.trend ?? group?.trend ?? 0;

    // Merge current + exiting chars in canonical order
    final exitKeys = {for (final c in _exitingChars) c.key};
    final merged = [..._chars, ..._exitingChars]
      ..sort((a, b) => _sortPos(a.key).compareTo(_sortPos(b.key)));

    return AnimatedBuilder(
      animation: _fadeCtrl,
      builder: (_, _) {
        final t = _fadeCtrl.isAnimating
            ? curve.transform(_fadeCtrl.value)
            : (_fadeCtrl.value == 0.0 ? 0.0 : 1.0);

        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final c in merged)
              _buildChar(c, style, duration, curve, trend, t,
                  entering: _enteringKeys.contains(c.key),
                  exiting: exitKeys.contains(c.key)),
          ],
        );
      },
    );
  }

  Widget _buildChar(
    _Char c,
    TextStyle style,
    Duration duration,
    Curve curve,
    int trend,
    double t, {
    required bool entering,
    required bool exiting,
  }) {
    Widget child;
    if (c.kind == _Kind.digit) {
      child = RollingDigit(
        digit: c.digitValue!,
        style: style,
        duration: duration,
        curve: curve,
        trend: trend,
      );
    } else {
      child = Text(c.char, style: style);
    }

    if (widget.animated && (entering || exiting)) {
      final opacity = entering ? t : 1.0 - t;
      final widthFactor = entering ? t : 1.0 - t;
      child = ClipRect(
        child: Align(
          alignment: Alignment.centerLeft,
          widthFactor: widthFactor.clamp(0.0, 1.0),
          child: Opacity(
            opacity: opacity.clamp(0.0, 1.0),
            child: child,
          ),
        ),
      );
    }

    return KeyedSubtree(key: ValueKey(c.key), child: child);
  }
}
