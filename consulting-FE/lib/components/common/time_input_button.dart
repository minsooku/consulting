import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:consulting_fe/components/customs/number_flow/number_flow.dart';
import 'package:consulting_fe/const/app_colors.dart';
import 'package:consulting_fe/const/app_fonts.dart';
import 'package:consulting_fe/pages/sheets/value_input_content.dart';

/// Compact inline tappable pill for RichText WidgetSpan.
///
/// Tapping opens a keyboard input bar at the bottom of the screen.
///
/// [isReady]     → duration   "45 min"
/// [isPlainText] → plain text "Work"
/// default       → clock time "9:00 AM"
class TimeInputButton extends StatefulWidget {
  const TimeInputButton({
    super.key,
    required this.value,
    this.onChanged,
    this.isReady = false,
    this.isPlainText = false,
    this.svgIcon,
    this.label,
    this.onInputActiveChanged,
  });

  final String value;
  final ValueChanged<String>? onChanged;
  final bool isReady;
  final bool isPlainText;
  final String? svgIcon;
  final String? label;
  final ValueChanged<bool>? onInputActiveChanged;

  @override
  State<TimeInputButton> createState() => _TimeInputButtonState();
}

class _TimeInputButtonState extends State<TimeInputButton> {
  bool _pressed = false;

  bool get _enabled => widget.onChanged != null;

  String _extractEditable(String v) {
    if (widget.isPlainText) return v;
    if (widget.isReady) {
      final m = RegExp(r'(\d+)').firstMatch(v);
      return m?.group(0) ?? v;
    }
    final m = RegExp(r'(\d{1,2}:\d{2})').firstMatch(v);
    return m?.group(0) ?? v;
  }

  String _extractSuffix(String v) {
    if (widget.isPlainText) return '';
    if (widget.isReady) return 'min';
    final m = RegExp(r'(AM|PM)', caseSensitive: false).firstMatch(v);
    return m?.group(0)?.toUpperCase() ?? 'AM';
  }

  Future<void> _openInput() async {
    if (!_enabled) return;

    widget.onInputActiveChanged?.call(true);
    final result = await showValueInput(
      context,
      initialValue: widget.value,
      isReady: widget.isReady,
      isPlainText: widget.isPlainText,
      label: widget.label,
    );
    widget.onInputActiveChanged?.call(false);

    if (result != null && result != widget.value) {
      widget.onChanged?.call(result);
    }
  }

  static const _valueStyle = TextStyle(
    fontFamily: AppFonts.normal,
    fontSize: 24,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    height: 1.3,
  );

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _enabled ? _openInput : null,
      onTapDown: _enabled ? (_) => setState(() => _pressed = true) : null,
      onTapUp: _enabled ? (_) => setState(() => _pressed = false) : null,
      onTapCancel: _enabled ? () => setState(() => _pressed = false) : null,
      child: AnimatedScale(
        scale: _pressed ? 0.95 : 1.0,
        duration: const Duration(milliseconds: 120),
        curve: Curves.fastEaseInToSlowEaseOut,
        child: Container(
          height: 44,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: _enabled
                ? AppColors.accent.withValues(alpha: 0.05)
                : AppColors.sub.withValues(alpha: 0.35),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: _enabled
                  ? AppColors.accent.withValues(alpha: 0.25)
                  : AppColors.sub,
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.svgIcon != null) ...[
                SvgPicture.asset(
                  widget.svgIcon!,
                  width: 20,
                  height: 20,
                  colorFilter: ColorFilter.mode(
                    _enabled ? AppColors.accent : AppColors.textSecondary,
                    BlendMode.srcIn,
                  ),
                ),
                const SizedBox(width: 4),
              ],
              RollingText(
                text: _extractEditable(widget.value),
                style: _valueStyle,
                duration: const Duration(milliseconds: 400),
              ),
              if (!widget.isPlainText) ...[
                const SizedBox(width: 4),
                RollingText(
                  text: _extractSuffix(widget.value),
                  style: _valueStyle,
                  duration: const Duration(milliseconds: 300),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
