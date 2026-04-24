import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:consulting_fe/const/app_colors.dart';
import 'package:consulting_fe/const/app_fonts.dart';

class HistoryCard extends StatefulWidget {
  const HistoryCard({
    super.key,
    required this.originLabel,
    required this.destinationLabel,
    required this.date,
    required this.actualMinutes,
    required this.savedVsPrediction,
    required this.onTap,
  });

  final String originLabel;
  final String destinationLabel;
  final DateTime date;
  final double? actualMinutes;
  final double? savedVsPrediction;
  final VoidCallback onTap;

  @override
  State<HistoryCard> createState() => _HistoryCardState();
}

class _HistoryCardState extends State<HistoryCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    Color trailingColor = AppColors.textPrimary;
    String trailingText = 'N/A';
    String? badge;

    if (widget.actualMinutes != null) {
      trailingText = '${widget.actualMinutes!.toStringAsFixed(0)} min';
      if (widget.savedVsPrediction != null && widget.savedVsPrediction! > 0) {
        trailingColor = AppColors.success;
        badge = '${widget.savedVsPrediction!.toStringAsFixed(0)}m faster';
      } else if (widget.savedVsPrediction != null &&
          widget.savedVsPrediction! < 0) {
        trailingColor = AppColors.danger;
        badge = '${widget.savedVsPrediction!.abs().toStringAsFixed(0)}m slower';
      }
    }

    final dateStr = DateFormat('MMM d, yyyy').format(widget.date);

    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 120),
        curve: Curves.fastEaseInToSlowEaseOut,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.sub, width: 0.5),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      dateStr,
                      style: const TextStyle(
                        fontFamily: AppFonts.normal,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${widget.originLabel} → ${widget.destinationLabel}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontFamily: AppFonts.normal,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    trailingText,
                    style: TextStyle(
                      fontFamily: AppFonts.normal,
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: trailingColor,
                    ),
                  ),
                  if (badge != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      badge,
                      style: TextStyle(
                        fontFamily: AppFonts.normal,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: trailingColor,
                      ),
                    ),
                  ],
                ],
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
    );
  }
}
