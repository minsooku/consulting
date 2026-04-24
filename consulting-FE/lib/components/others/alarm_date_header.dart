import 'package:flutter/material.dart';

import 'package:consulting_fe/components/customs/number_flow/number_flow.dart';
import 'package:consulting_fe/const/app_colors.dart';
import 'package:consulting_fe/const/app_fonts.dart';

class AlarmDateHeader extends StatelessWidget {
  const AlarmDateHeader({
    super.key,
    required this.day,
    required this.weekday,
    required this.month,
    this.dayOfMonth,
    this.trailing,
    this.isOtherPage = false,
  });

  final int day;
  final String weekday;
  final String month;
  final int? dayOfMonth;
  final Widget? trailing;
  final bool isOtherPage;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 20, top: 20, right: 20, bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (dayOfMonth != null)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    RollingText(
                      text: '$month ',
                      style: const TextStyle(
                        fontFamily: AppFonts.normal,
                        fontSize: 30,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                      duration: const Duration(milliseconds: 500),
                      curve: Curves.fastEaseInToSlowEaseOut,
                    ),
                    NumberFlow(
                      value: dayOfMonth!,
                      style: const TextStyle(
                        fontFamily: AppFonts.normal,
                        fontSize: 30,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                      duration: const Duration(milliseconds: 500),
                      curve: Curves.fastEaseInToSlowEaseOut,
                    ),
                  ],
                )
              else
                RollingText(
                  text: month,
                  style: const TextStyle(
                    fontFamily: AppFonts.normal,
                    fontSize: 30,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
              if (!isOtherPage)
                RollingText(
                  text: weekday,
                  style: const TextStyle(
                    fontFamily: AppFonts.normal,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.fastEaseInToSlowEaseOut,
                ),
              const SizedBox(height: 2),
            ],
          ),
          const Spacer(),
          ?trailing,
        ],
      ),
    );
  }
}
