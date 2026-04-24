import 'package:flutter/material.dart';
import 'package:consulting_fe/components/platform/platform_button.dart';
import 'package:consulting_fe/const/app_colors.dart';
import 'package:consulting_fe/const/app_fonts.dart';

class SheetHeader extends StatelessWidget {
  const SheetHeader({
    super.key,
    required this.title,
    this.subtitle,
    required this.onClose,
    this.showGrabber = true,
    this.titleFontSize = 28,
  });

  final String title;
  final String? subtitle;
  final VoidCallback onClose;
  final bool showGrabber;
  final double titleFontSize;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (showGrabber) const SheetGrabber(),
        Padding(
          padding: EdgeInsets.only(
            left: 24,
            right: 16,
            top: showGrabber ? 4 : 16,
            bottom: 16,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontFamily: AppFonts.normal,
                        fontSize: titleFontSize,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle!,
                        style: const TextStyle(
                          fontFamily: AppFonts.normal,
                          fontSize: 15,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              PlatformIconButton(
                iosIcon: 'xmark',
                androidIcon: Icons.close,
                onPressed: onClose,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class SheetGrabber extends StatelessWidget {
  const SheetGrabber({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        margin: const EdgeInsets.only(top: 12, bottom: 12),
        width: 36,
        height: 5,
        decoration: BoxDecoration(
          color: AppColors.sub,
          borderRadius: BorderRadius.circular(3),
        ),
      ),
    );
  }
}
