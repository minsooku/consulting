import 'package:flutter/material.dart';

import 'package:consulting_fe/components/others/lock_screen_preview.dart';
import 'package:consulting_fe/components/platform/platform_button.dart';
import 'package:consulting_fe/components/platform/platform_sheet.dart';
import 'package:consulting_fe/const/app_colors.dart';
import 'package:consulting_fe/const/app_fonts.dart';

class ClockStyleContent extends StatelessWidget {
  const ClockStyleContent({super.key, required this.current});

  final ClockStyle current;

  static const _normalStyles = [
    ClockStyle.thin,
    ClockStyle.bold,
    ClockStyle.minimal,
  ];
  static const _leftStyles = [
    ClockStyle.thinLeft,
    ClockStyle.boldLeft,
    ClockStyle.minimalLeft,
  ];
  static const _rightStyles = [
    ClockStyle.thinRight,
    ClockStyle.boldRight,
    ClockStyle.minimalRight,
  ];

  @override
  Widget build(BuildContext context) {
    final bottomPad = MediaQuery.of(context).padding.bottom;

    return Container(
      color: AppColors.background,
      // SingleChildScrollView so the 3 sections never overflow regardless
      // of sheet height. The large detent opens enough that no scrolling
      // is normally required, but this acts as a safety net.
      child: SingleChildScrollView(
        physics: const ClampingScrollPhysics(),
        child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Header ───────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.only(
              left: 24,
              right: 16,
              top: 16,
              bottom: 4,
            ),
            child: Row(
              children: [
                const Expanded(
                  child: Text(
                    'Clock Style',
                    style: TextStyle(
                      fontFamily: AppFonts.normal,
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                PlatformIconButton(
                  iosIcon: 'xmark',
                  androidIcon: Icons.close,
                  isGlass: true,
                  onPressed: () => PlatformSheet.close(context),
                ),
              ],
            ),
          ),

          Padding(
            padding: EdgeInsets.fromLTRB(16, 8, 16, bottomPad + 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // ── Normal section ────────────────────────────────────
                _SectionLabel(text: 'Normal'),
                const SizedBox(height: 10),
                _StyleRow(styles: _normalStyles, current: current),

                const SizedBox(height: 20),

                // ── Left Align section ────────────────────────────────
                _SectionLabel(text: 'Left Align'),
                const SizedBox(height: 10),
                _StyleRow(styles: _leftStyles, current: current),

                const SizedBox(height: 20),

                // ── Right Align section ───────────────────────────────
                _SectionLabel(text: 'Right Align'),
                const SizedBox(height: 10),
                _StyleRow(styles: _rightStyles, current: current),
              ],
            ),
          ),
        ],
        ),  // Column
      ),    // SingleChildScrollView
    );
  }
}

// ── Section label ──────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) => Text(
    text,
    style: const TextStyle(
      fontFamily: AppFonts.normal,
      fontSize: 12,
      fontWeight: FontWeight.w600,
      color: AppColors.textSecondary,
      letterSpacing: 0.3,
    ),
  );
}

// ── Row of 3 cards ─────────────────────────────────────────────────────────────

class _StyleRow extends StatelessWidget {
  const _StyleRow({required this.styles, required this.current});

  final List<ClockStyle> styles;
  final ClockStyle current;

  @override
  Widget build(BuildContext context) => Row(
    children: styles
        .map(
          (style) => Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: _ClockFaceCard(style: style, isSelected: style == current),
            ),
          ),
        )
        .toList(),
  );
}

// ── Single style card showing ONLY the clock text ─────────────────────────────

class _ClockFaceCard extends StatelessWidget {
  const _ClockFaceCard({required this.style, required this.isSelected});

  final ClockStyle style;
  final bool isSelected;

  static const _bg1 = Color(0xFF1A1A2E);
  static const _bg2 = Color(0xFF0F3460);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => PlatformSheet.close(context, style.name),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [_bg1, _bg2],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? AppColors.accent
                : Colors.white.withValues(alpha: 0.08),
            width: isSelected ? 2.0 : 1.0,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.accent.withValues(alpha: 0.28),
                    blurRadius: 14,
                    spreadRadius: 1,
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Clock face — fixed height so all cards are identical ──
            SizedBox(
              height: 82,
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: (style.isLeft || style.isRight) ? 10 : 6,
                ),
                child: Align(
                  alignment: style.isLeft
                      ? Alignment.centerLeft
                      : style.isRight
                      ? Alignment.centerRight
                      : Alignment.center,
                  child: _ClockFace(style: style),
                ),
              ),
            ),

            // ── Divider ───────────────────────────────────────────────
            Container(height: 0.5, color: Colors.white.withValues(alpha: 0.1)),

            // ── Label row ─────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 9),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (isSelected)
                    Padding(
                      padding: const EdgeInsets.only(right: 4),
                      child: Icon(
                        Icons.check_circle_rounded,
                        size: 12,
                        color: AppColors.accent,
                      ),
                    ),
                  Text(
                    style.label,
                    style: TextStyle(
                      fontFamily: AppFonts.normal,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: isSelected
                          ? AppColors.accent
                          : Colors.white.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Clock face renderer ───────────────────────────────────────────────────────

class _ClockFace extends StatelessWidget {
  const _ClockFace({required this.style});

  final ClockStyle style;

  static const _primary = Colors.white;
  static final _secondary = Colors.white.withValues(alpha: 0.65);

  // Short date so it never wraps inside the narrow card.
  static const _time = '8:24';
  static const _date = 'Mon, Jan 1';

  TextAlign get _align {
    if (style.isLeft) return TextAlign.left;
    if (style.isRight) return TextAlign.right;
    return TextAlign.center;
  }

  CrossAxisAlignment get _cross {
    if (style.isLeft) return CrossAxisAlignment.start;
    if (style.isRight) return CrossAxisAlignment.end;
    return CrossAxisAlignment.center;
  }

  Alignment get _fittedAlign {
    if (style.isLeft) return Alignment.centerLeft;
    if (style.isRight) return Alignment.centerRight;
    return Alignment.center;
  }

  @override
  Widget build(BuildContext context) {
    switch (style.baseStyle) {
      case ClockStyle.thin:
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: _cross,
          children: [
            Text(
              _date,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: _align,
              style: TextStyle(
                fontFamily: AppFonts.normal,
                fontSize: 9,
                fontWeight: FontWeight.w400,
                color: _secondary,
              ),
            ),
            const SizedBox(height: 1),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: _fittedAlign,
              child: Text(
                _time,
                textAlign: _align,
                style: const TextStyle(
                  fontFamily: AppFonts.normal,
                  fontSize: 46,
                  fontWeight: FontWeight.w200,
                  color: _primary,
                  height: 1.0,
                  letterSpacing: -2,
                ),
              ),
            ),
          ],
        );

      case ClockStyle.bold:
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: _cross,
          children: [
            Text(
              'MON, JAN 1',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: _align,
              style: TextStyle(
                fontFamily: AppFonts.normal,
                fontSize: 8,
                fontWeight: FontWeight.w600,
                color: _secondary,
                letterSpacing: 0.3,
              ),
            ),
            const SizedBox(height: 2),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: _fittedAlign,
              child: Text(
                _time,
                textAlign: _align,
                style: const TextStyle(
                  fontFamily: AppFonts.normal,
                  fontSize: 42,
                  fontWeight: FontWeight.w700,
                  color: _primary,
                  height: 1.0,
                  letterSpacing: -1,
                ),
              ),
            ),
          ],
        );

      case ClockStyle.minimal:
        return FittedBox(
          fit: BoxFit.scaleDown,
          alignment: _fittedAlign,
          child: Text(
            _time,
            textAlign: _align,
            style: const TextStyle(
              fontFamily: AppFonts.normal,
              fontSize: 42,
              fontWeight: FontWeight.w300,
              color: _primary,
              height: 1.0,
              letterSpacing: -1,
            ),
          ),
        );

      default:
        return const SizedBox.shrink();
    }
  }
}
