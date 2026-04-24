import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:consulting_fe/api/models/fitness_models.dart';
import 'package:consulting_fe/const/app_colors.dart';
import 'package:consulting_fe/provider/fitness_provider.dart';

class AlarmPage extends StatefulWidget {
  const AlarmPage({
    super.key,
    this.isActive = true,
    this.onSearchActiveChanged,
    this.fromOnboarding = false,
  });

  final bool isActive;
  final bool fromOnboarding;
  final ValueChanged<bool>? onSearchActiveChanged;

  @override
  State<AlarmPage> createState() => _AlarmPageState();
}

class _AlarmPageState extends State<AlarmPage> {
  late DateTime _selectedDate;
  late DateTime _today;

  static const List<String> _weekdayShort = [
    'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun',
  ];

  static const List<String> _monthNames = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December',
  ];

  @override
  void initState() {
    super.initState();
    _today = DateTime.now();
    _selectedDate = DateTime(_today.year, _today.month, _today.day);
  }

  List<DateTime> get _weekDays {
    final weekday = _selectedDate.weekday; // 1=Mon
    final monday = _selectedDate.subtract(Duration(days: weekday - 1));
    return List.generate(7, (i) => monday.add(Duration(days: i)));
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  DailyPlan? _findDayPlan(FitnessProvider fp) {
    if (!fp.hasPlan) return null;
    final daily = fp.plan!.daily;
    try {
      return daily.firstWhere((d) => _isSameDay(d.date, _selectedDate));
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            _buildWeekStrip(),
            const SizedBox(height: 8),
            Expanded(child: _buildBody()),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final isToday = _isSameDay(_selectedDate, _today);
    final label = isToday
        ? 'Today'
        : '${_weekdayShort[_selectedDate.weekday - 1]}, '
            '${_monthNames[_selectedDate.month - 1]} ${_selectedDate.day}';

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Agenda',
            style: TextStyle(
              fontSize: 34,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              fontSize: 15,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeekStrip() {
    final days = _weekDays;
    final fp = context.watch<FitnessProvider>();
    final weekPlans = fp.plan?.daily ?? [];

    return SizedBox(
      height: 76,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        itemCount: 7,
        separatorBuilder: (_, _) => const SizedBox(width: 6),
        itemBuilder: (context, i) {
          final day = days[i];
          final isSelected = _isSameDay(day, _selectedDate);
          final isToday = _isSameDay(day, _today);
          final hasBlocks = weekPlans.any(
            (d) => _isSameDay(d.date, day) && d.blocks.isNotEmpty,
          );

          return GestureDetector(
            onTap: () => setState(() => _selectedDate = day),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 44,
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.mainPoint
                    : isToday
                    ? AppColors.sub
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isSelected ? AppColors.mainPoint : AppColors.sub,
                  width: 1,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _weekdayShort[day.weekday - 1][0],
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: isSelected
                          ? AppColors.mainPointText
                          : AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${day.day}',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: isSelected
                          ? AppColors.mainPointText
                          : AppColors.textPrimary,
                    ),
                  ),
                  if (hasBlocks && !isSelected)
                    Container(
                      width: 4,
                      height: 4,
                      margin: const EdgeInsets.only(top: 2),
                      decoration: BoxDecoration(
                        color: AppColors.accent,
                        shape: BoxShape.circle,
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBody() {
    final fp = context.watch<FitnessProvider>();

    if (!fp.hasPlan) {
      return _EmptyState(
        icon: Icons.calendar_today_outlined,
        title: 'No plan yet',
        subtitle: 'Go to the Workout tab\nto generate your AI fitness plan.',
      );
    }

    final dayPlan = _findDayPlan(fp);
    if (dayPlan == null) {
      return _EmptyState(
        icon: Icons.event_available_outlined,
        title: 'No activities',
        subtitle: 'Nothing scheduled for this day.',
      );
    }

    if (dayPlan.blocks.isEmpty) {
      return _EmptyState(
        icon: Icons.self_improvement_outlined,
        title: 'Rest Day',
        subtitle: 'Recovery is part of the plan.',
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 120),
      itemCount: dayPlan.blocks.length,
      separatorBuilder: (_, _) => const SizedBox(height: 10),
      itemBuilder: (context, i) => _BlockCard(block: dayPlan.blocks[i]),
    );
  }
}

// ── Widgets ──────────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  const _EmptyState({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 48, color: AppColors.sub),
          const SizedBox(height: 14),
          Text(
            title,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _BlockCard extends StatefulWidget {
  const _BlockCard({required this.block});

  final DailyBlock block;

  @override
  State<_BlockCard> createState() => _BlockCardState();
}

class _BlockCardState extends State<_BlockCard> {
  bool _expanded = false;

  static const _categoryColors = {
    'workout': AppColors.accent,
    'nutrition': AppColors.success,
    'habit': AppColors.warning,
    'recovery': Color(0xFF8E8E93),
  };

  static const _categoryIcons = {
    'workout': Icons.fitness_center,
    'nutrition': Icons.restaurant_outlined,
    'habit': Icons.check_circle_outline,
    'recovery': Icons.self_improvement_outlined,
  };

  Color get _accent =>
      _categoryColors[widget.block.category] ?? AppColors.textSecondary;

  IconData get _icon =>
      _categoryIcons[widget.block.category] ?? Icons.circle_outlined;

  @override
  Widget build(BuildContext context) {
    final block = widget.block;
    final hasDetails = block.details.isNotEmpty;

    return GestureDetector(
      onTap: hasDetails ? () => setState(() => _expanded = !_expanded) : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.sub, width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: _accent.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(_icon, size: 18, color: _accent),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        block.title,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        '${block.durationMin} min · ${block.category}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                if (hasDetails)
                  Icon(
                    _expanded ? Icons.expand_less : Icons.expand_more,
                    size: 20,
                    color: AppColors.textSecondary,
                  ),
              ],
            ),
            if (_expanded && hasDetails) ...[
              const SizedBox(height: 12),
              const Divider(height: 1, color: AppColors.sub),
              const SizedBox(height: 10),
              ...block.details.map(
                (item) => _ChecklistRow(item: item),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ChecklistRow extends StatefulWidget {
  const _ChecklistRow({required this.item});

  final ChecklistItem item;

  @override
  State<_ChecklistRow> createState() => _ChecklistRowState();
}

class _ChecklistRowState extends State<_ChecklistRow> {
  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    return GestureDetector(
      onTap: () => setState(() => item.done = !item.done),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 5),
        child: Row(
          children: [
            Icon(
              item.done ? Icons.check_circle : Icons.radio_button_unchecked,
              size: 18,
              color: item.done ? AppColors.success : AppColors.sub,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                item.label,
                style: TextStyle(
                  fontSize: 14,
                  color: item.done
                      ? AppColors.textSecondary
                      : AppColors.textPrimary,
                  decoration: item.done ? TextDecoration.lineThrough : null,
                ),
              ),
            ),
            if (item.targetDisplay.isNotEmpty)
              Text(
                item.targetDisplay,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondary,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
