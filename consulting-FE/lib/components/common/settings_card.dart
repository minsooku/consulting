import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:consulting_fe/components/platform/platform_toggle.dart';
import 'package:consulting_fe/const/app_colors.dart';
import 'package:consulting_fe/const/app_fonts.dart';

class SettingsCard extends StatefulWidget {
  const SettingsCard({
    super.key,
    required this.iconPath,
    required this.label,
    this.subtitle,
    this.iconBgColor,
    this.iconColor,
    this.trailing,
    this.onTap,
    this.isToggle = false,
    this.toggleValue = false,
    this.onToggleChanged,
    this.showDivider = true,
    this.isExternalLink = false,
    this.labelColor,
    this.hideToggle = false,
  });

  final String iconPath;
  final String label;
  final String? subtitle;

  /// Colored rounded-square background for the icon (iOS settings style).
  /// When null the icon renders inline without a background box.
  final Color? iconBgColor;

  /// Override the icon's tint color (defaults to textPrimary when no bg, white when bg set).
  final Color? iconColor;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool isToggle;
  final bool toggleValue;
  final ValueChanged<bool>? onToggleChanged;
  final bool showDivider;
  final bool isExternalLink;

  /// Override label text color (e.g. red for destructive actions).
  final Color? labelColor;

  /// Temporarily hides the toggle with a fade animation.
  final bool hideToggle;

  @override
  State<SettingsCard> createState() => _SettingsCardState();
}

class _SettingsCardState extends State<SettingsCard> {
  bool _pressed = false;

  void _onDown(TapDownDetails _) => setState(() => _pressed = true);
  void _onUp(TapUpDetails _) => setState(() => _pressed = false);
  void _onCancel() => setState(() => _pressed = false);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _onDown,
      onTapUp: _onUp,
      onTapCancel: _onCancel,
      onTap: widget.isToggle ? null : widget.onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        curve: Curves.fastEaseInToSlowEaseOut,
        color: _pressed
            ? AppColors.textPrimary.withValues(alpha: 0.05)
            : Colors.transparent,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
        foregroundDecoration: widget.showDivider
            ? const BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: AppColors.sub,
                    width: 0.5,
                    strokeAlign: BorderSide.strokeAlignInside,
                  ),
                ),
              )
            : null,
        child: Row(
          children: [
            _buildIcon(),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    widget.label,
                    style: TextStyle(
                      fontFamily: AppFonts.normal,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: widget.labelColor ?? AppColors.textPrimary,
                    ),
                  ),
                  if (widget.subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      widget.subtitle!,
                      style: const TextStyle(
                        fontFamily: AppFonts.normal,
                        fontSize: 12.5,
                        fontWeight: FontWeight.w400,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (widget.isToggle)
              AnimatedOpacity(
                opacity: widget.hideToggle ? 0.0 : 1.0,
                duration: const Duration(milliseconds: 300),
                curve: Curves.fastEaseInToSlowEaseOut,
                child: IgnorePointer(
                  ignoring: widget.hideToggle,
                  child: PlatformToggle(
                    value: widget.toggleValue,
                    onChanged: widget.onToggleChanged ?? (_) {},
                  ),
                ),
              )
            else if (widget.trailing != null)
              widget.trailing!
            else if (widget.isExternalLink)
              const Icon(
                Icons.north_east_rounded,
                size: 18,
                color: AppColors.textSecondary,
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

  Widget _buildIcon() {
    final Color resolvedIconColor =
        widget.iconColor ??
        (widget.iconBgColor != null ? Colors.white : AppColors.textPrimary);

    final svg = SvgPicture.asset(
      widget.iconPath,
      width: 20,
      height: 20,
      colorFilter: ColorFilter.mode(resolvedIconColor, BlendMode.srcIn),
    );

    if (widget.iconBgColor == null) {
      return SizedBox(width: 28, height: 28, child: svg);
    }

    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: widget.iconBgColor,
        borderRadius: BorderRadius.circular(8),
      ),
      alignment: Alignment.center,
      child: svg,
    );
  }
}
