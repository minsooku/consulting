import 'package:flutter/material.dart';

/// Wraps multiple [NumberFlow] widgets to share animation configuration.
///
/// ```dart
/// NumberFlowGroup(
///   duration: Duration(milliseconds: 800),
///   curve: Curves.easeOutExpo,
///   trend: 1,
///   child: Row(
///     children: [
///       NumberFlow(value: hours, suffix: 'h '),
///       NumberFlow(value: minutes, suffix: 'm'),
///     ],
///   ),
/// )
/// ```
class NumberFlowGroup extends InheritedWidget {
  const NumberFlowGroup({
    super.key,
    required super.child,
    this.duration = const Duration(milliseconds: 600),
    this.curve = Curves.easeInOutCubic,
    this.trend = 0,
  });

  final Duration duration;
  final Curve curve;

  /// `1` = always roll upward, `-1` = always downward, `0` = shortest path.
  final int trend;

  static NumberFlowGroup? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<NumberFlowGroup>();

  @override
  bool updateShouldNotify(NumberFlowGroup old) =>
      duration != old.duration || curve != old.curve || trend != old.trend;
}
