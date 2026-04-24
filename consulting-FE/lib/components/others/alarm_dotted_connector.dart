import 'package:flutter/material.dart';

import 'package:consulting_fe/components/customs/number_flow/rolling_text.dart';
import 'package:consulting_fe/const/app_colors.dart';
import 'package:consulting_fe/const/app_fonts.dart';

class AlarmDottedConnector extends StatelessWidget {
  const AlarmDottedConnector({
    super.key,
    required this.label,
    this.trafficStatus,
    this.predictedMinutes,
    this.freeFlowMinutes,
  });

  final String label;
  // "faster_than_usual" | "normal" | "slower_than_usual" | "incident_likely"
  final String? trafficStatus;
  final double? predictedMinutes;
  final double? freeFlowMinutes;

  static _TrafficInfo? _trafficInfo(
    String? status,
    double? predictedMinutes,
    double? freeFlowMinutes,
  ) {
    final int? delayMin = (predictedMinutes != null && freeFlowMinutes != null)
        ? (predictedMinutes - freeFlowMinutes).round()
        : null;

    // Derive status from numbers when backend doesn't provide one
    final effective = status ?? _deriveStatus(delayMin);
    if (effective == null) return null;

    switch (effective) {
      case 'faster_than_usual':
        final text = delayMin != null && delayMin < 0
            ? '${-delayMin} min faster than usual'
            : 'Faster than usual';
        return _TrafficInfo(text, const Color(0xFF34C759));
      case 'normal':
        return const _TrafficInfo('Normal traffic', Color(0xFF8E8E93));
      case 'slower_than_usual':
        final text = delayMin != null && delayMin > 0
            ? '+$delayMin min from traffic'
            : 'Slower than usual';
        return _TrafficInfo(text, const Color(0xFFFF9500));
      case 'incident_likely':
        final text = delayMin != null && delayMin > 0
            ? '+$delayMin min — heavy traffic'
            : 'Heavy traffic';
        return _TrafficInfo(text, const Color(0xFFFF3B30));
      default:
        return null;
    }
  }

  static String? _deriveStatus(int? delayMin) {
    if (delayMin == null) return null;
    if (delayMin <= -3) return 'faster_than_usual';
    if (delayMin >= 10) return 'slower_than_usual';
    if (delayMin >= 3) return 'slower_than_usual';
    return 'normal';
  }

  @override
  Widget build(BuildContext context) {
    final info = _trafficInfo(trafficStatus, predictedMinutes, freeFlowMinutes);
    final height = info != null ? 92.0 : 72.0;

    // Pill label style
    const labelStyle = TextStyle(
      fontFamily: AppFonts.normal,
      fontSize: 11,
      fontWeight: FontWeight.w600,
      color: AppColors.textSecondary,
    );

    return SizedBox(
      height: height,
      child: Stack(
        children: [
          Center(
            child: CustomPaint(
              size: Size(50, height),
              painter: _BouncyCurveDotPainter(color: AppColors.sub),
            ),
          ),
          Positioned.fill(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Main label — solid background hides dots behind it
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.sub, width: 0.5),
                  ),
                  child: RollingText(
                    text: label,
                    style: labelStyle,
                    duration: const Duration(milliseconds: 400),
                    curve: Curves.fastEaseInToSlowEaseOut,
                  ),
                ),
                if (info != null) ...[
                  const SizedBox(height: 6),
                  // Traffic pill — solid (alpha-blended) bg so dots are fully hidden
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 9,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      // Blend transparent color over white → fully opaque
                      color: Color.alphaBlend(
                        info.color.withValues(alpha: 0.14),
                        AppColors.surface,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      info.label,
                      style: TextStyle(
                        fontFamily: AppFonts.normal,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: info.color,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TrafficInfo {
  const _TrafficInfo(this.label, this.color);
  final String label;
  final Color color;
}

class _BouncyCurveDotPainter extends CustomPainter {
  _BouncyCurveDotPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final cx = size.width / 2;
    final h = size.height;

    final path = Path()
      ..moveTo(cx, 0)
      ..cubicTo(cx + 20, h * 0.15, cx + 22, h * 0.30, cx, h * 0.42)
      ..cubicTo(cx - 22, h * 0.55, cx - 20, h * 0.75, cx, h);

    final metrics = path.computeMetrics().first;
    final totalLength = metrics.length;
    const dotSpacing = 4.5;
    const dotRadius = 1.3;

    for (double d = 0; d <= totalLength; d += dotSpacing) {
      final tangent = metrics.getTangentForOffset(d);
      if (tangent != null) {
        canvas.drawCircle(tangent.position, dotRadius, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

