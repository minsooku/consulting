import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:consulting_fe/components/platform/platform_toggle.dart';
import 'package:consulting_fe/const/app_colors.dart';
import 'package:consulting_fe/const/app_fonts.dart';

class MissionCard extends StatefulWidget {
  const MissionCard({
    super.key,
    required this.iconPath,
    required this.title,
    required this.description,
    required this.isEnabled,
    this.onToggle,
    this.onTap,
  });

  final String iconPath;
  final String title;
  final String description;
  final bool isEnabled;
  final ValueChanged<bool>? onToggle;
  final VoidCallback? onTap;

  @override
  State<MissionCard> createState() => _MissionCardState();
}

class _MissionCardState extends State<MissionCard> {
  bool _pressed = false;

  void _onDown(TapDownDetails _) => setState(() => _pressed = true);
  void _onUp(TapUpDetails _) => setState(() => _pressed = false);
  void _onCancel() => setState(() => _pressed = false);

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 120),
      curve: Curves.fastEaseInToSlowEaseOut,
      decoration: BoxDecoration(
        color: _pressed
            ? AppColors.surface.withValues(alpha: 0.7)
            : AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.sub, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        children: [
          // Tappable body — opens the settings sheet
          Expanded(
            child: GestureDetector(
              onTapDown: _onDown,
              onTapUp: _onUp,
              onTapCancel: _onCancel,
              onTap: widget.onTap,
              behavior: HitTestBehavior.opaque,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                child: Row(
                  children: [
                    SvgPicture.asset(
                      widget.iconPath,
                      width: 28,
                      height: 28,
                      colorFilter: ColorFilter.mode(
                        widget.isEnabled
                            ? AppColors.textPrimary
                            : AppColors.textPrimary,
                        BlendMode.srcIn,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.title,
                            style: const TextStyle(
                              fontFamily: AppFonts.normal,
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            widget.description,
                            style: const TextStyle(
                              fontFamily: AppFonts.normal,
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: AppColors.textSecondary,
                              height: 1.3,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(
                      Icons.chevron_right_rounded,
                      size: 20,
                      color: AppColors.textSecondary,
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Toggle — only shown when onToggle is provided
          if (widget.onToggle != null)
            Padding(
              padding: const EdgeInsets.only(right: 14),
              child: PlatformToggle(
                value: widget.isEnabled,
                onChanged: widget.onToggle!,
                activeColor: AppColors.accent,
              ),
            ),
        ],
      ),
    );
  }
}
