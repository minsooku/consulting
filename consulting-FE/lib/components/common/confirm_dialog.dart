import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:consulting_fe/components/platform/platform_button.dart';
import 'package:consulting_fe/const/app_colors.dart';
import 'package:consulting_fe/const/app_fonts.dart';

/// Reusable confirmation dialog.
///
/// ```dart
/// final confirmed = await ConfirmDialog.show(
///   context,
///   title: 'Sign out?',
///   message: 'You will need to sign in again.',
///   actionLabel: 'Sign Out',
///   actionColor: AppColors.danger,
/// );
/// if (confirmed == true) { ... }
/// ```
class ConfirmDialog extends StatelessWidget {
  const ConfirmDialog({
    super.key,
    required this.title,
    required this.message,
    this.icon = Icons.error_outline_rounded,
    this.iconColor = AppColors.danger,
    this.cancelLabel = 'Cancel',
    required this.actionLabel,
    this.actionColor = AppColors.danger,
    this.isOneButton = false,
  });

  final String title;
  final String message;
  final IconData icon;
  final Color iconColor;
  final String cancelLabel;
  final String actionLabel;
  final Color actionColor;
  final bool isOneButton;

  static Future<bool?> show(
    BuildContext context, {
    required String title,
    required String message,
    IconData icon = Icons.error_outline_rounded,
    Color iconColor = AppColors.danger,
    String cancelLabel = 'Cancel',
    required String actionLabel,
    Color actionColor = AppColors.danger,
    bool isOneButton = false,
  }) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withValues(alpha: 0.3),
      builder: (_) => ConfirmDialog(
        title: title,
        message: message,
        icon: icon,
        iconColor: iconColor,
        cancelLabel: cancelLabel,
        actionLabel: actionLabel,
        actionColor: actionColor,
        isOneButton: isOneButton,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28),
        child: Material(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          clipBehavior: Clip.antiAlias,
          elevation: 16,
          shadowColor: Colors.black.withValues(alpha: 0.15),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, color: iconColor, size: 50),
                const SizedBox(height: 16),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontFamily: AppFonts.normal,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontFamily: AppFonts.normal,
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: AppColors.textSecondary,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 24),
                if (isOneButton)
                  SizedBox(
                    width: double.infinity,
                    child: PlatformButton(
                      text: actionLabel,
                      tint: actionColor,
                      isProminentGlass: true,
                      height: 50,
                      onPressed: () {
                        HapticFeedback.lightImpact();
                        Navigator.of(context).pop(true);
                      },
                    ),
                  )
                else
                  Column(
                    children: [
                      SizedBox(
                        width: double.infinity,
                        child: PlatformButton(
                          text: actionLabel,
                          tint: actionColor,
                          isProminentGlass: true,
                          height: 50,
                          onPressed: () {
                            HapticFeedback.lightImpact();
                            Navigator.of(context).pop(true);
                          },
                        ),
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        width: double.infinity,
                        child: PlatformButton(
                          text: cancelLabel,
                          isGlass: true,
                          height: 50,
                          onPressed: () {
                            HapticFeedback.lightImpact();
                            Navigator.of(context).pop(false);
                          },
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

void loadingShowDialog(BuildContext context) {
  showDialog(
    context: context,
    barrierDismissible: false,
    barrierColor: Colors.black.withValues(alpha: 0.3),
    builder: (BuildContext context) {
      return Dialog(
        elevation: 0,
        backgroundColor: Colors.transparent,
        child: Center(
          child: Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Center(
              child: CircularProgressIndicator(color: AppColors.textPrimary),
            ),
          ),
        ),
      );
    },
  );
}
