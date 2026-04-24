import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:consulting_fe/components/customs/number_flow/number_flow.dart';
import 'package:consulting_fe/components/platform/platform_button.dart';
import 'package:consulting_fe/const/app_colors.dart';
import 'package:consulting_fe/const/app_fonts.dart';

const double kCardRadius = 14.0;

final kCardShadow = [
  BoxShadow(
    color: Colors.black.withValues(alpha: 0.04),
    blurRadius: 8,
    offset: const Offset(0, 2),
  ),
];

BoxDecoration cardDecoration({bool selected = false, bool accent = false}) {
  final borderColor = accent
      ? (selected ? AppColors.accent : AppColors.sub)
      : (selected ? AppColors.textPrimary : AppColors.sub);
  return BoxDecoration(
    color: selected && !accent ? AppColors.textPrimary : AppColors.surface,
    borderRadius: BorderRadius.circular(kCardRadius),
    border: Border.all(
      color: borderColor,
      width: (accent && selected) ? 1.5 : 1,
    ),
    boxShadow: selected && !accent ? null : kCardShadow,
  );
}

const kStepLabelStyle = TextStyle(
  fontFamily: AppFonts.normal,
  fontSize: 14,
  fontWeight: FontWeight.w600,
  color: AppColors.textSecondary,
);

const kTitleStyle = TextStyle(
  fontFamily: AppFonts.normal,
  fontSize: 34,
  fontWeight: FontWeight.w800,
  color: AppColors.textPrimary,
  height: 1.15,
);

/// No page-level transition; animate_do handles content entrance.
PageRoute<T> slideRoute<T>(Widget page) => PageRouteBuilder<T>(
  opaque: true,
  pageBuilder: (_, __, ___) => page,
  transitionsBuilder: (_, __, ___, child) => child,
  transitionDuration: Duration.zero,
  reverseTransitionDuration: Duration.zero,
);

// ---------------------------------------------------------------------------
// Shared step scaffold
// ---------------------------------------------------------------------------

class StepScaffold extends StatelessWidget {
  const StepScaffold({
    super.key,
    required this.stepIndex,
    required this.title,
    required this.child,
  });

  final int stepIndex;
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Padding(
        padding: const EdgeInsets.only(left: 24, right: 24, bottom: 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FadeIn(
              duration: const Duration(milliseconds: 400),
              child: Text('Step ${stepIndex + 1}', style: kStepLabelStyle),
            ),
            const SizedBox(height: 6),
            FadeIn(
              duration: const Duration(milliseconds: 400),
              delay: const Duration(milliseconds: 70),
              child: Text(title, style: kTitleStyle),
            ),
            const SizedBox(height: 28),
            FadeIn(
              duration: const Duration(milliseconds: 400),
              delay: const Duration(milliseconds: 140),
              child: child,
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Shared adjust button (for time steps)
// ---------------------------------------------------------------------------

class AdjustButton extends StatelessWidget {
  const AdjustButton({super.key, required this.icon, this.onTap});
  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.sub),
        ),
        child: Icon(
          icon,
          size: 20,
          color: onTap != null
              ? AppColors.textPrimary
              : AppColors.textSecondary,
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Shared onboarding page shell (Back button + content + Continue button)
// ---------------------------------------------------------------------------

class OnboardingShell extends StatelessWidget {
  const OnboardingShell({
    super.key,
    required this.continueLabel,
    required this.onContinue,
    required this.child,
    this.isLoading = false,
    this.hideContinue = false,
    this.continueTint,
  });

  final String continueLabel;
  final VoidCallback? onContinue;
  final Widget child;
  final bool isLoading;
  final bool hideContinue;
  final Color? continueTint;

  @override
  Widget build(BuildContext context) {
    final bottomPad = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Back button
            if (!hideContinue)
              Padding(
                padding: const EdgeInsets.only(
                  left: 24,
                  top: 12,
                  right: 16,
                  bottom: 0,
                ),
                child: Row(
                  children: [
                    PlatformIconButton(
                      iosIcon: 'chevron.backward',
                      androidIcon: Icons.arrow_back_ios_new_rounded,
                      onPressed: () => Navigator.of(context).pop(),
                      isGlass: true,
                    ),
                  ],
                ),
              ),
            // Step content
            Expanded(child: child),
            // Continue button
            if (!hideContinue)
              Padding(
                padding: EdgeInsets.only(
                  left: 24,
                  top: 8,
                  right: 24,
                  bottom: bottomPad + 20,
                ),
                child: PlatformButton(
                  text: continueLabel,
                  onPressed: isLoading ? null : onContinue,
                  isProminentGlass: true,
                  tint: continueTint,
                  height: 56,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Shared address card (for address steps)
// ---------------------------------------------------------------------------

// ---------------------------------------------------------------------------
// Shared work location cycling chip
// ---------------------------------------------------------------------------

class WorkLocationChip extends StatelessWidget {
  const WorkLocationChip({super.key, required this.label, this.onTap});

  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 44,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.sub),
        ),
        alignment: Alignment.center,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: RollingText(
                text: label,
                duration: const Duration(milliseconds: 300),
                style: const TextStyle(
                  fontFamily: AppFonts.normal,
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
            if (onTap != null) ...[
              const SizedBox(width: 6),
              const Icon(
                Icons.swap_horiz_rounded,
                size: 16,
                color: AppColors.textSecondary,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Shared address card (for address steps)
// ---------------------------------------------------------------------------

class AddressCard extends StatelessWidget {
  const AddressCard({
    super.key,
    required this.icon,
    required this.hint,
    required this.value,
    required this.onTap,
    this.onDelete,
  });

  final IconData icon;
  final String hint;
  final String? value;
  final VoidCallback onTap;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        decoration: cardDecoration(),
        child: Row(
          children: [
            Icon(icon, size: 20, color: AppColors.textSecondary),
            const SizedBox(width: 14),
            Expanded(
              child: value != null
                  ? Text(
                      value!,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontFamily: AppFonts.normal,
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textPrimary,
                      ),
                    )
                  : Shimmer.fromColors(
                      baseColor: AppColors.textSecondary.withValues(alpha: 0.4),
                      highlightColor: AppColors.textSecondary.withValues(
                        alpha: 0.15,
                      ),
                      period: const Duration(milliseconds: 1800),
                      child: Text(
                        hint,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontFamily: AppFonts.normal,
                          fontSize: 15,
                          fontWeight: FontWeight.w400,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
            ),
            const SizedBox(width: 8),
            if (onDelete != null)
              GestureDetector(
                onTap: onDelete,
                behavior: HitTestBehavior.opaque,
                child: const Padding(
                  padding: EdgeInsets.all(2),
                  child: Icon(
                    Icons.close_rounded,
                    size: 18,
                    color: AppColors.textSecondary,
                  ),
                ),
              )
            else
              const Icon(
                Icons.chevron_right_rounded,
                size: 20,
                color: AppColors.textSecondary,
              ),
          ],
        ),
      ),
    );
  }
}
