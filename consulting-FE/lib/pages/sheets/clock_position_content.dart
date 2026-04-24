import 'package:flutter/material.dart';

import 'package:consulting_fe/components/others/lock_screen_preview.dart';
import 'package:consulting_fe/components/platform/platform_button.dart';
import 'package:consulting_fe/const/app_colors.dart';
import 'package:consulting_fe/const/app_fonts.dart';

class ClockPositionContent extends StatefulWidget {
  const ClockPositionContent({
    super.key,
    this.current = ClockPosition.center,
    this.onResult,
  });

  final ClockPosition current;

  /// Called with the selected position, or `null` when dismissed without
  /// making a selection.
  final ValueChanged<ClockPosition?>? onResult;

  @override
  State<ClockPositionContent> createState() => _ClockPositionContentState();
}

class _ClockPositionContentState extends State<ClockPositionContent> {
  late ClockPosition _selected;

  // Ordered row-by-row for the 3×3 grid
  static const _grid = [
    [ClockPosition.topLeft, ClockPosition.topCenter, ClockPosition.topRight],
    [ClockPosition.centerLeft, ClockPosition.center, ClockPosition.centerRight],
  ];

  @override
  void initState() {
    super.initState();
    _selected = widget.current;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildHeader(),
        const SizedBox(height: 20),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: _buildGrid(),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.only(left: 24, right: 16, top: 16, bottom: 16),
      child: Row(
        children: [
          const Expanded(
            child: Text(
              'Clock Position',
              style: TextStyle(
                fontFamily: AppFonts.normal,
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          PlatformIconButton(
            iosIcon: 'xmark',
            isGlass: true,
            androidIcon: Icons.close,
            onPressed: () => widget.onResult?.call(null),
          ),
        ],
      ),
    );
  }

  Widget _buildGrid() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: _grid.map((row) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Row(
            children: row.map((pos) {
              return Expanded(
                child: Padding(
                  padding: EdgeInsets.only(right: pos == row.last ? 0 : 7),
                  child: _GridCell(
                    position: pos,
                    isSelected: pos == _selected,
                    onTap: () {
                      setState(() => _selected = pos);
                      widget.onResult?.call(pos);
                    },
                  ),
                ),
              );
            }).toList(),
          ),
        );
      }).toList(),
    );
  }
}

// ── Grid cell ─────────────────────────────────────────────────────────────────

class _GridCell extends StatelessWidget {
  const _GridCell({
    required this.position,
    required this.isSelected,
    required this.onTap,
  });

  final ClockPosition position;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final (posRow, posCol) = position.gridIndex;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.fastEaseInToSlowEaseOut,
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.mainPoint : AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.mainPoint : AppColors.sub,
            width: 0.8,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 3×3 dot grid — one dot highlighted for current position
            SizedBox(
              width: 36,
              height: 36,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(3, (row) {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: List.generate(3, (col) {
                      final isHot = row == posRow && col == posCol;
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        width: isHot ? 7 : 5,
                        height: isHot ? 7 : 5,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isHot
                              ? (isSelected
                                    ? Colors.white
                                    : AppColors.mainPoint)
                              : (isSelected
                                    ? Colors.white.withValues(alpha: 0.28)
                                    : AppColors.textSecondary.withValues(
                                        alpha: 0.18,
                                      )),
                        ),
                      );
                    }),
                  );
                }),
              ),
            ),
            const SizedBox(height: 8),
            // Label
            Text(
              position.label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: AppFonts.normal,
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                color: isSelected ? Colors.white : AppColors.textSecondary,
                height: 1.3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
