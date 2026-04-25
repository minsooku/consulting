import 'package:flutter/material.dart';
import 'package:smooth_sheets/smooth_sheets.dart';

import 'package:consulting_fe/api/models/fitness_models.dart';
import 'package:consulting_fe/components/common/sheet_header.dart';
import 'package:consulting_fe/const/app_colors.dart';
import 'package:consulting_fe/const/app_fonts.dart';
import 'package:consulting_fe/mock/machine_images.dart';
import 'package:consulting_fe/mock/mock_fitness.dart';

// ---------------------------------------------------------------------------
// Public entry point — mirrors HistorySheet.show()
// ---------------------------------------------------------------------------

class WorkoutBlockSheet {
  WorkoutBlockSheet._();

  static Future<void> show(BuildContext context, DailyBlock block) {
    return Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        barrierColor: Colors.black54,
        barrierDismissible: true,
        transitionDuration: const Duration(milliseconds: 400),
        reverseTransitionDuration: const Duration(milliseconds: 300),
        pageBuilder: (_, _, _) => _WorkoutBlockSheetPage(block: block),
        transitionsBuilder: (_, animation, _, child) {
          final slide = Tween(begin: const Offset(0, 1), end: Offset.zero)
              .animate(
                CurvedAnimation(
                  parent: animation,
                  curve: Curves.fastEaseInToSlowEaseOut,
                  reverseCurve: Curves.fastEaseInToSlowEaseOut,
                ),
              );
          return SlideTransition(position: slide, child: child);
        },
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Sheet root — PagedSheet with single content page
// ---------------------------------------------------------------------------

class _WorkoutBlockSheetPage extends StatelessWidget {
  const _WorkoutBlockSheetPage({required this.block});

  final DailyBlock block;

  void _close(BuildContext outerContext) {
    Future.delayed(const Duration(milliseconds: 80), () {
      if (outerContext.mounted) Navigator.of(outerContext).pop();
    });
  }

  @override
  Widget build(BuildContext context) {
    final outerContext = context;
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        bottom: false,
        child: SheetViewport(
          child: PagedSheet(
            decoration: const MaterialSheetDecoration(
              size: SheetSize.stretch,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              clipBehavior: Clip.antiAlias,
              color: AppColors.background,
            ),
            navigator: Material(
              color: Colors.transparent,
              child: Navigator(
                pages: [
                  PagedSheetPage<void>(
                    key: const ValueKey('block'),
                    transitionDuration: const Duration(milliseconds: 300),
                    transitionsBuilder: _pageTransition,
                    child: _BlockDetailPage(
                      block: block,
                      onClose: () => _close(outerContext),
                    ),
                  ),
                ],
                onDidRemovePage: (_) {},
              ),
            ),
          ),
        ),
      ),
    );
  }
}

Widget _pageTransition(
  BuildContext context,
  Animation<double> animation,
  Animation<double> secondaryAnimation,
  Widget child,
) {
  return FadeTransition(
    opacity: CurveTween(curve: Curves.easeInExpo).animate(animation),
    child: child,
  );
}

// ---------------------------------------------------------------------------
// Block detail page
// ---------------------------------------------------------------------------

class _BlockDetailPage extends StatefulWidget {
  const _BlockDetailPage({required this.block, required this.onClose});

  final DailyBlock block;
  final VoidCallback onClose;

  @override
  State<_BlockDetailPage> createState() => _BlockDetailPageState();
}

class _BlockDetailPageState extends State<_BlockDetailPage> {
  String? _expandedImagePath;

  @override
  Widget build(BuildContext context) {
    final block = widget.block;
    final isWorkout = block.category == 'workout';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SheetHeader(
          title: block.title,
          showGrabber: true,
          subtitle: isWorkout
              ? '${block.durationMin} min  •  ${MockFitness.location}'
              : '${block.durationMin} min  •  ${block.category}',
          onClose: widget.onClose,
        ),
        Expanded(
          child: block.details.isEmpty
              ? _buildEmpty()
              : _buildExerciseList(block.details),
        ),
      ],
    );
  }

  Widget _buildEmpty() {
    return const Center(
      child: Text(
        'No exercises listed.',
        style: TextStyle(
          fontFamily: AppFonts.normal,
          fontSize: 16,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }

  Widget _buildExerciseList(List<ChecklistItem> items) {
    return ListView.separated(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        bottom: MediaQuery.of(context).padding.bottom + 24,
      ),
      itemCount: items.length,
      separatorBuilder: (_, _) => const Divider(height: 1, color: AppColors.sub),
      itemBuilder: (_, index) => _ExerciseDetailRow(
        item: items[index],
        isImageExpanded: _expandedImagePath ==
            MachineImages.resolve(machine: items[index].machine, exerciseName: items[index].label),
        onToggleImage: (path) => setState(() {
          _expandedImagePath = _expandedImagePath == path ? null : path;
        }),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Exercise row with inline machine image
// ---------------------------------------------------------------------------

class _ExerciseDetailRow extends StatefulWidget {
  const _ExerciseDetailRow({
    required this.item,
    required this.isImageExpanded,
    required this.onToggleImage,
  });

  final ChecklistItem item;
  final bool isImageExpanded;
  final ValueChanged<String?> onToggleImage;

  @override
  State<_ExerciseDetailRow> createState() => _ExerciseDetailRowState();
}

class _ExerciseDetailRowState extends State<_ExerciseDetailRow> {
  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    final imagePath = MachineImages.resolve(machine: item.machine, exerciseName: item.label);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Main row ────────────────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 14),
          child: Row(
            children: [
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => setState(() => item.done = !item.done),
                child: Icon(
                  item.done
                      ? Icons.check_circle
                      : Icons.radio_button_unchecked,
                  size: 22,
                  color: item.done ? AppColors.success : AppColors.sub,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => setState(() => item.done = !item.done),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.label,
                        style: TextStyle(
                          fontFamily: AppFonts.normal,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: item.done
                              ? AppColors.textSecondary
                              : AppColors.textPrimary,
                          decoration: item.done
                              ? TextDecoration.lineThrough
                              : null,
                        ),
                      ),
                      if (item.targetDisplay.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          item.targetDisplay,
                          style: const TextStyle(
                            fontFamily: AppFonts.normal,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              if (imagePath != null)
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => widget.onToggleImage(imagePath),
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: widget.isImageExpanded
                            ? AppColors.accent
                            : AppColors.sub,
                        width: 1.5,
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(9),
                      child: Image.asset(
                        imagePath,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => const Icon(
                          Icons.fitness_center,
                          size: 20,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),

        // ── Expanded machine image ───────────────────────────────────────
        if (imagePath != null && widget.isImageExpanded)
          GestureDetector(
            onTap: () => widget.onToggleImage(null),
            child: Container(
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.sub),
              ),
              clipBehavior: Clip.antiAlias,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Image.asset(
                    imagePath,
                    fit: BoxFit.contain,
                    height: 200,
                    errorBuilder: (_, _, _) => const SizedBox(
                      height: 200,
                      child: Center(
                        child: Icon(
                          Icons.fitness_center,
                          size: 48,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    color: AppColors.surface,
                    child: Row(
                      children: [
                        const Icon(
                          Icons.location_on,
                          size: 13,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          MockFitness.location,
                          style: const TextStyle(
                            fontFamily: AppFonts.normal,
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
