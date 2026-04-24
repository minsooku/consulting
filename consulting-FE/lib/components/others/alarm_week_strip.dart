import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:consulting_fe/const/app_colors.dart';

class AlarmWeekStrip extends StatelessWidget {
  const AlarmWeekStrip({
    super.key,
    required this.selectedWeekday,
    required this.onWeekdaySelected,
  });

  final int selectedWeekday;
  final ValueChanged<int> onWeekdaySelected;

  static const _labels = ['SUN', 'MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT'];
  static const _weekdays = [7, 1, 2, 3, 4, 5, 6];

  @override
  Widget build(BuildContext context) {
    final todayWd = DateTime.now().weekday;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(7, (i) {
          final wd = _weekdays[i];
          final selected = wd == selectedWeekday;
          final isToday = wd == todayWd;
          final isWeekend = wd == 6 || wd == 7;

          return GestureDetector(
            onTap: () {
              HapticFeedback.selectionClick();
              onWeekdaySelected(wd);
            },
            behavior: HitTestBehavior.opaque,
            child: Stack(
              alignment: Alignment.topCenter,
              clipBehavior: Clip.none,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  curve: Curves.easeOut,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: selected
                        ? AppColors.textPrimary
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 150),
                    curve: Curves.easeOut,
                    style: TextStyle(
                      fontSize: selected ? 12.5 : 12,
                      fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                      color: selected
                          ? Colors.white
                          : isWeekend
                          ? AppColors.textSecondary.withValues(alpha: 0.5)
                          : AppColors.textSecondary,
                      letterSpacing: 0.3,
                    ),
                    child: Text(_labels[i]),
                  ),
                ),
                if (isToday)
                  Positioned(
                    top: 2,
                    child: Container(
                      width: 5,
                      height: 5,
                      decoration: BoxDecoration(
                        color: AppColors.danger,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
          );
        }),
      ),
    );
  }
}
