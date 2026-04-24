import 'package:flutter/material.dart';

import 'package:consulting_fe/const/app_fonts.dart';

// ── Clock style ───────────────────────────────────────────────────────────────

enum ClockStyle {
  thin,
  bold,
  minimal,
  thinLeft,
  boldLeft,
  minimalLeft,
  thinRight,
  boldRight,
  minimalRight,
}

extension ClockStyleLabel on ClockStyle {
  String get label => switch (this) {
    ClockStyle.thin => 'Light',
    ClockStyle.bold => 'Bold',
    ClockStyle.minimal => 'Clean',
    ClockStyle.thinLeft => 'Light',
    ClockStyle.boldLeft => 'Bold',
    ClockStyle.minimalLeft => 'Clean',
    ClockStyle.thinRight => 'Light',
    ClockStyle.boldRight => 'Bold',
    ClockStyle.minimalRight => 'Clean',
  };

  bool get isLeft => const {
    ClockStyle.thinLeft,
    ClockStyle.boldLeft,
    ClockStyle.minimalLeft,
  }.contains(this);

  bool get isRight => const {
    ClockStyle.thinRight,
    ClockStyle.boldRight,
    ClockStyle.minimalRight,
  }.contains(this);

  /// Center-aligned base style — shared for all three alignment variants.
  ClockStyle get baseStyle => switch (this) {
    ClockStyle.thinLeft => ClockStyle.thin,
    ClockStyle.boldLeft => ClockStyle.bold,
    ClockStyle.minimalLeft => ClockStyle.minimal,
    ClockStyle.thinRight => ClockStyle.thin,
    ClockStyle.boldRight => ClockStyle.bold,
    ClockStyle.minimalRight => ClockStyle.minimal,
    _ => this,
  };
}

// ── Legacy enum (kept for backward compat with API mapping) ──────────────────

enum ClockPosition {
  topLeft,
  topCenter,
  topRight,
  centerLeft,
  center,
  centerRight,
  bottomLeft,
  bottomCenter,
  bottomRight,
}

extension ClockPositionLabel on ClockPosition {
  String get label => switch (this) {
    ClockPosition.topLeft => 'Top Left',
    ClockPosition.topCenter => 'Top',
    ClockPosition.topRight => 'Top Right',
    ClockPosition.centerLeft => 'Left',
    ClockPosition.center => 'Center',
    ClockPosition.centerRight => 'Right',
    ClockPosition.bottomLeft => 'Bottom Left',
    ClockPosition.bottomCenter => 'Bottom',
    ClockPosition.bottomRight => 'Bottom Right',
  };

  (int, int) get gridIndex => switch (this) {
    ClockPosition.topLeft => (0, 0),
    ClockPosition.topCenter => (0, 1),
    ClockPosition.topRight => (0, 2),
    ClockPosition.centerLeft => (1, 0),
    ClockPosition.center => (1, 1),
    ClockPosition.centerRight => (1, 2),
    ClockPosition.bottomLeft => (2, 0),
    ClockPosition.bottomCenter => (2, 1),
    ClockPosition.bottomRight => (2, 2),
  };
}

// ── Helpers (used by pages, not by LockScreenPreview itself) ─────────────────

/// Converts a normalised alignment fraction to the nearest named zone for the
/// legacy `alarm_clock_position` backend field.
String alignmentToClockPositionName(double alignX, double alignY) {
  final col = alignX < -0.33
      ? 'Left'
      : alignX > 0.33
      ? 'Right'
      : 'Center';
  final row = alignY < -0.33
      ? 'top'
      : alignY > 0.33
      ? 'bottom'
      : 'center';
  if (row == 'center' && col == 'Center') return 'center';
  if (row == 'center') return 'center$col';
  if (col == 'Center') return '${row}Center';
  return '$row$col';
}

// ── Preview ───────────────────────────────────────────────────────────────────

/// Pure visual layer: background (gradient or user wallpaper) + clock.
///
/// The clock is positioned via [clockOffset] — a pixel offset from the widget's
/// centre. This gives perfectly 1-to-1 finger tracking when the parent passes
/// raw [ScaleUpdateDetails.focalPointDelta] directly.
///
/// Fills whatever space its parent gives it — no intrinsic size.
class LockScreenPreview extends StatelessWidget {
  const LockScreenPreview({
    super.key,
    this.clockOffset = Offset.zero,
    this.clockStyle = ClockStyle.thin,
    this.wallpaper,
    this.brightness = Brightness.dark,
    this.imageScale = 1.0,
    this.imageOffset = Offset.zero,
    this.showDragHint = false,
  });

  /// Pixel offset of the clock's centre from the widget's centre.
  final Offset clockOffset;
  final ClockStyle clockStyle;
  final ImageProvider? wallpaper;
  final Brightness brightness;
  final double imageScale;
  final Offset imageOffset;
  final bool showDragHint;

  // ── Colors ────────────────────────────────────────────────────────────────

  Color get _primaryText => brightness == Brightness.dark
      ? Colors.white
      : Colors.black.withValues(alpha: 0.88);

  Color get _secondaryText => brightness == Brightness.dark
      ? Colors.white.withValues(alpha: 0.72)
      : Colors.black.withValues(alpha: 0.55);

  // ── Alignment — depends on style, never on drag position ─────────────────

  TextAlign get _textAlign {
    if (clockStyle.isLeft) return TextAlign.left;
    if (clockStyle.isRight) return TextAlign.right;
    return TextAlign.center;
  }

  CrossAxisAlignment get _crossAxis {
    if (clockStyle.isLeft) return CrossAxisAlignment.start;
    if (clockStyle.isRight) return CrossAxisAlignment.end;
    return CrossAxisAlignment.center;
  }

  // ── Clock texts (switches on baseStyle so left variants share the same text)

  List<Widget> _buildClockTexts(String timeStr, String dateStr) {
    switch (clockStyle.baseStyle) {
      case ClockStyle.thin:
        return [
          Text(
            dateStr,
            textAlign: _textAlign,
            style: TextStyle(
              fontFamily: AppFonts.normal,
              fontSize: 15,
              fontWeight: FontWeight.w400,
              color: _secondaryText,
              letterSpacing: 0.1,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            timeStr,
            textAlign: _textAlign,
            style: TextStyle(
              fontFamily: AppFonts.normal,
              fontSize: 82,
              fontWeight: FontWeight.w200,
              color: _primaryText,
              height: 1.0,
              letterSpacing: -4,
            ),
          ),
        ];

      case ClockStyle.bold:
        return [
          Text(
            dateStr.toUpperCase(),
            textAlign: _textAlign,
            style: TextStyle(
              fontFamily: AppFonts.normal,
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: _secondaryText,
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            timeStr,
            textAlign: _textAlign,
            style: TextStyle(
              fontFamily: AppFonts.normal,
              fontSize: 72,
              fontWeight: FontWeight.w700,
              color: _primaryText,
              height: 1.0,
              letterSpacing: -2,
            ),
          ),
        ];

      case ClockStyle.minimal:
        return [
          Text(
            timeStr,
            textAlign: _textAlign,
            style: TextStyle(
              fontFamily: AppFonts.normal,
              fontSize: 58,
              fontWeight: FontWeight.w300,
              color: _primaryText,
              height: 1.0,
              letterSpacing: -1.5,
            ),
          ),
        ];

      // Left variants handled by isLeft flag above; baseStyle never returns them.
      default:
        return [];
    }
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final hour = now.hour % 12 == 0 ? 12 : now.hour % 12;
    final minute = now.minute.toString().padLeft(2, '0');
    final timeStr = '$hour:$minute';

    const weekdays = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    final dateStr =
        '${weekdays[now.weekday - 1]}, ${months[now.month - 1]} ${now.day}';

    // Use Centre + Transform.translate so 1 px of drag = 1 px of movement.
    // No division-based Alignment maths that would slow down tracking.
    final clockWidget = Transform.translate(
      offset: clockOffset,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: _crossAxis,
        children: [
          ..._buildClockTexts(timeStr, dateStr),
          // if (showDragHint) ...[
          //   const SizedBox(height: 6),
          //   Icon(
          //     Icons.open_with_rounded,
          //     size: 18,
          //     color: _primaryText.withValues(alpha: 0.45),
          //   ),
          // ],
        ],
      ),
    );

    return Stack(
      fit: StackFit.expand,
      children: [
        // ── Wallpaper / gradient background ───────────────────────────
        if (wallpaper != null)
          ClipRect(
            child: Transform.translate(
              offset: imageOffset,
              child: Transform.scale(
                scale: imageScale,
                child: Image(
                  image: wallpaper!,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                ),
              ),
            ),
          )
        else
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF1A1A2E),
                  Color(0xFF16213E),
                  Color(0xFF0F3460),
                ],
              ),
            ),
          ),

        // ── Decorative accents (gradient-only mode) ───────────────────
        if (wallpaper == null) ...[
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFF7B61FF).withValues(alpha: 0.22),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: -80,
            left: -80,
            child: Container(
              width: 240,
              height: 240,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFF007AFF).withValues(alpha: 0.18),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
        ],

        // ── Clock — centred then translated by clockOffset ─────────────
        Center(child: clockWidget),
      ],
    );
  }
}
