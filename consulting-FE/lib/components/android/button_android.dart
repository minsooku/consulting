import 'package:consulting_fe/const/app_colors.dart';
import 'package:consulting_fe/const/app_fonts.dart';
import 'package:flutter/material.dart';

class AndroidTextButton extends StatelessWidget {
  const AndroidTextButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.backgroundColor,
    this.foregroundColor,
    this.isGlass = false,
    this.isProminentGlass = false,
    this.height = 32.0,
  });

  final String text;
  final VoidCallback? onPressed;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final bool isGlass;
  final bool isProminentGlass;
  final double height;

  @override
  Widget build(BuildContext context) {
    if (isProminentGlass) {
      final enabled = onPressed != null;
      return GestureDetector(
        onTap: onPressed,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          height: height,
          decoration: BoxDecoration(
            color: enabled ? AppColors.surface : AppColors.sub,
            borderRadius: BorderRadius.circular(16),
            boxShadow: enabled
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: Center(
            child: Text(
              text,
              style: TextStyle(
                fontFamily: AppFonts.normal,
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: enabled
                    ? AppColors.textPrimary
                    : AppColors.textSecondary,
              ),
            ),
          ),
        ),
      );
    }

    if (isGlass) {
      return ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          minimumSize: Size.zero,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          backgroundColor: Colors.white.withValues(alpha: 0.15),
          foregroundColor: foregroundColor ?? Colors.black,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(color: Colors.grey.shade300, width: 0.5),
          ),
        ),
        child: Text(text),
      );
    }

    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        backgroundColor: backgroundColor,
        foregroundColor: foregroundColor,
      ),
      child: Text(text),
    );
  }
}

class AndroidLoginButton extends StatelessWidget {
  const AndroidLoginButton({
    super.key,
    required this.text,
    required this.icon,
    required this.onPressed,
    this.backgroundColor,
    this.foregroundColor,
    this.height = 50.0,
    this.enabled = true,
    this.outlined = false,
    this.isProminentGlass = false,
  });

  final String text;
  final Widget icon;
  final VoidCallback? onPressed;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double height;
  final bool enabled;
  final bool outlined;
  final bool isProminentGlass;

  @override
  Widget build(BuildContext context) {
    final effectiveOnPressed = enabled ? onPressed : null;

    // ── prominentGlass: white card with shadow, no ink splash ─────────────
    if (isProminentGlass) {
      return SizedBox(
        height: height,
        child: Material(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          child: InkWell(
            onTap: effectiveOnPressed,
            borderRadius: BorderRadius.circular(14),
            splashColor: Colors.black.withValues(alpha: 0.04),
            highlightColor: Colors.black.withValues(alpha: 0.03),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.grey.shade200, width: 0.5),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    icon,
                    const SizedBox(width: 10),
                    Text(
                      text,
                      style: TextStyle(
                        fontFamily: AppFonts.normal,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        letterSpacing: -0.2,
                        color: enabled
                            ? AppColors.textPrimary
                            : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    }

    if (outlined) {
      return SizedBox(
        height: height,
        child: OutlinedButton.icon(
          onPressed: effectiveOnPressed,
          icon: icon,
          label: Text(text),
          style: OutlinedButton.styleFrom(
            foregroundColor: foregroundColor ?? AppColors.textPrimary,
            side: BorderSide(color: Colors.grey.shade300),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            textStyle: const TextStyle(
              fontFamily: AppFonts.normal,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      );
    }

    return SizedBox(
      height: height,
      child: ElevatedButton.icon(
        onPressed: effectiveOnPressed,
        icon: icon,
        label: Text(text),
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor ?? AppColors.mainPoint,
          foregroundColor: foregroundColor ?? AppColors.mainPointText,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontFamily: AppFonts.normal,
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class AndroidIconButton extends StatelessWidget {
  const AndroidIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.size = 32.0,
    this.isGlass = false,
  });

  final IconData icon;
  final VoidCallback? onPressed;
  final double size;
  final bool isGlass;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isGlass
              ? Colors.white.withValues(alpha: 0.15)
              : Colors.grey.shade200,
          border: isGlass
              ? Border.all(color: Colors.grey.shade300, width: 0.5)
              : null,
        ),
        child: Center(
          child: Icon(icon, size: size * 0.45, color: Colors.black),
        ),
      ),
    );
  }
}
