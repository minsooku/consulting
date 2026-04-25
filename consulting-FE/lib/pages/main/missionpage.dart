import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'package:consulting_fe/api/models/fitness_models.dart';
import 'package:consulting_fe/const/app_colors.dart';
import 'package:consulting_fe/mock/machine_images.dart';
import 'package:consulting_fe/mock/mock_fitness.dart';
import 'package:consulting_fe/provider/fitness_provider.dart';

class MissionPage extends StatefulWidget {
  const MissionPage({super.key});

  @override
  State<MissionPage> createState() => _MissionPageState();
}

class _MissionPageState extends State<MissionPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final fp = context.watch<FitnessProvider>();

    if (fp.loading) return const _LoadingView();
    if (!fp.hasProfile) return const _SetupView();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(fp),
            _buildTabBar(),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _WeeklyTab(fp: fp),
                  _SummaryTab(fp: fp),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(FitnessProvider fp) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 8),
      child: Row(
        children: [
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Weekly Workout',
                  style: TextStyle(
                    fontSize: 34,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                    letterSpacing: -0.5,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Regenerate Plan?'),
                  content: const Text(
                    'This will clear your current plan and generate a new one.',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx, false),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(ctx, true),
                      child: const Text(
                        'Regenerate',
                        style: TextStyle(color: AppColors.danger),
                      ),
                    ),
                  ],
                ),
              );
              if (confirm == true && mounted) {
                await context.read<FitnessProvider>().clearPlan();
              }
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.sub,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                'Regenerate',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: TabBar(
        controller: _tabController,
        labelColor: AppColors.textPrimary,
        unselectedLabelColor: AppColors.textSecondary,
        labelStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
        indicatorColor: AppColors.mainPoint,
        indicatorSize: TabBarIndicatorSize.label,
        dividerColor: Colors.transparent,
        tabs: const [Tab(text: 'This Week'), Tab(text: 'Summary')],
      ),
    );
  }
}

// ── Weekly tab ────────────────────────────────────────────────────────────────

class _WeeklyTab extends StatefulWidget {
  const _WeeklyTab({required this.fp});

  final FitnessProvider fp;

  @override
  State<_WeeklyTab> createState() => _WeeklyTabState();
}

class _WeeklyTabState extends State<_WeeklyTab> {
  late int _selectedWeekday; // 1=Mon … 7=Sun

  static const List<String> _weekdayShort = [
    'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun',
  ];

  @override
  void initState() {
    super.initState();
    _selectedWeekday = DateTime.now().weekday;
  }

  DailyPlan? get _selectedDayPlan {
    final weekDays = widget.fp.thisWeekDays;
    final idx = _selectedWeekday - 1;
    return idx < weekDays.length ? weekDays[idx] : null;
  }

  @override
  Widget build(BuildContext context) {
    final weekDays = widget.fp.thisWeekDays;

    return Column(
      children: [
        const SizedBox(height: 12),
        _buildDayStrip(weekDays),
        const SizedBox(height: 8),
        Expanded(child: _buildDayContent()),
      ],
    );
  }

  Widget _buildDayStrip(List<DailyPlan?> weekDays) {
    final today = DateTime.now().weekday;
    return SizedBox(
      height: 76,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        itemCount: 7,
        separatorBuilder: (_, _) => const SizedBox(width: 6),
        itemBuilder: (context, i) {
          final weekday = i + 1;
          final isSelected = weekday == _selectedWeekday;
          final isToday = weekday == today;
          final dayPlan = weekDays[i];
          final hasWorkout =
              dayPlan != null && dayPlan.workoutBlocks.isNotEmpty;

          return GestureDetector(
            onTap: () => setState(() => _selectedWeekday = weekday),
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
                    _weekdayShort[i][0],
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
                    _weekdayShort[i][0].toLowerCase(),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: isSelected
                          ? AppColors.mainPointText
                          : AppColors.textPrimary,
                    ),
                  ),
                  if (hasWorkout && !isSelected)
                    Container(
                      width: 4,
                      height: 4,
                      margin: const EdgeInsets.only(top: 2),
                      decoration: const BoxDecoration(
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

  Widget _buildDayContent() {
    final dayPlan = _selectedDayPlan;

    if (!widget.fp.hasPlan) {
      return const _EmptyPlanState();
    }

    if (dayPlan == null) {
      return const _EmptyDayState(
        emoji: '📅',
        title: 'No plan for this day',
        subtitle: 'This day falls outside your plan window.',
      );
    }

    if (dayPlan.isRestDay) {
      return const _EmptyDayState(
        emoji: '😴',
        title: 'Rest Day',
        subtitle: 'Recovery is part of the process.',
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 120),
      itemCount: dayPlan.workoutBlocks.length,
      separatorBuilder: (_, _) => const SizedBox(height: 10),
      itemBuilder: (context, i) =>
          _WorkoutBlockCard(block: dayPlan.workoutBlocks[i]),
    );
  }
}

// ── Summary tab ───────────────────────────────────────────────────────────────

class _SummaryTab extends StatelessWidget {
  const _SummaryTab({required this.fp});

  final FitnessProvider fp;

  @override
  Widget build(BuildContext context) {
    final weekly = fp.currentWeekPlan;
    if (weekly == null) return const _EmptyPlanState();

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 120),
      children: [
        _ThemeCard(weekly: weekly),
        const SizedBox(height: 14),
        if (weekly.details.isNotEmpty) ...[
          const Text(
            'Weekly Targets',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 10),
          ...weekly.details.map((item) => _SummaryChecklistRow(item: item)),
        ],
      ],
    );
  }
}

// ── Setup view ────────────────────────────────────────────────────────────────

class _SetupView extends StatefulWidget {
  const _SetupView();

  @override
  State<_SetupView> createState() => _SetupViewState();
}

class _SetupViewState extends State<_SetupView> {
  final _nameCtrl = TextEditingController();
  final _heightCtrl = TextEditingController();
  final _weightCtrl = TextEditingController();
  final _ageCtrl = TextEditingController();
  String _gender = 'Male';
  String _goalType = 'hypertrophy';
  String _experience = 'Beginner';
  double _daysPerWeek = 4;
  bool _diet = false;

  static const _goalOptions = [
    ('hypertrophy', 'Muscle Gain'),
    ('weight_loss', 'Lose Weight'),
    ('endurance', 'Endurance'),
    ('general_fitness', 'Stay Fit'),
  ];

  static const _experienceOptions = ['Beginner', 'Intermediate', 'Advanced'];

  bool get _isValid {
    if (_nameCtrl.text.trim().isEmpty) return false;
    if (int.tryParse(_heightCtrl.text) == null) return false;
    if (int.tryParse(_weightCtrl.text) == null) return false;
    if (int.tryParse(_ageCtrl.text) == null) return false;
    return true;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _heightCtrl.dispose();
    _weightCtrl.dispose();
    _ageCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final fp = context.watch<FitnessProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 40),
          children: [
            const Text(
              'Your Profile',
              style: TextStyle(
                fontSize: 34,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Tell us about yourself to generate\nyour personalized AI fitness plan.',
              style: TextStyle(
                fontSize: 15,
                color: AppColors.textSecondary,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 32),

            // Name
            _FormLabel(label: 'Name'),
            const SizedBox(height: 8),
            _TextField(controller: _nameCtrl, hint: 'e.g. Alex', onChanged: (_) => setState(() {})),
            const SizedBox(height: 20),

            // Body stats row
            _FormLabel(label: 'Body Stats'),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _TextField(
                    controller: _heightCtrl,
                    hint: 'Height (cm)',
                    keyboardType: TextInputType.number,
                    onChanged: (_) => setState(() {}),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _TextField(
                    controller: _weightCtrl,
                    hint: 'Weight (kg)',
                    keyboardType: TextInputType.number,
                    onChanged: (_) => setState(() {}),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _TextField(
                    controller: _ageCtrl,
                    hint: 'Age',
                    keyboardType: TextInputType.number,
                    onChanged: (_) => setState(() {}),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Gender
            _FormLabel(label: 'Gender'),
            const SizedBox(height: 8),
            _SegmentedPicker<String>(
              options: const ['Male', 'Female'],
              labels: const ['Male', 'Female'],
              selected: _gender,
              onSelected: (v) => setState(() => _gender = v),
            ),
            const SizedBox(height: 20),

            // Goal
            _FormLabel(label: 'Goal'),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _goalOptions.map((opt) {
                final isSelected = _goalType == opt.$1;
                return GestureDetector(
                  onTap: () => setState(() => _goalType = opt.$1),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.mainPoint : AppColors.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected ? AppColors.mainPoint : AppColors.sub,
                      ),
                    ),
                    child: Text(
                      opt.$2,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: isSelected
                            ? AppColors.mainPointText
                            : AppColors.textPrimary,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),

            // Experience
            _FormLabel(label: 'Experience'),
            const SizedBox(height: 8),
            _SegmentedPicker<String>(
              options: _experienceOptions,
              labels: _experienceOptions,
              selected: _experience,
              onSelected: (v) => setState(() => _experience = v),
            ),
            const SizedBox(height: 20),

            // Days per week
            _FormLabel(label: 'Workout Days / Week: ${_daysPerWeek.toInt()}'),
            Slider(
              min: 1,
              max: 7,
              divisions: 6,
              value: _daysPerWeek,
              activeColor: AppColors.mainPoint,
              inactiveColor: AppColors.sub,
              onChanged: (v) => setState(() => _daysPerWeek = v),
            ),
            const SizedBox(height: 12),

            // Diet
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Include Diet Plan',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                  ),
                ),
                Switch(
                  value: _diet,
                  activeColor: AppColors.mainPoint,
                  onChanged: (v) => setState(() => _diet = v),
                ),
              ],
            ),
            const SizedBox(height: 32),

            if (fp.error != null)
              Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.danger.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.danger.withValues(alpha: 0.3)),
                ),
                child: Text(
                  fp.error!,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.danger,
                  ),
                ),
              ),

            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _isValid && !fp.loading ? _generate : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.mainPoint,
                  disabledBackgroundColor: AppColors.sub,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: fp.loading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text(
                        'Generate My Plan',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _generate() async {
    FocusScope.of(context).unfocus();
    final fp = context.read<FitnessProvider>();

    final prompt = FitnessPrompt(
      name: _nameCtrl.text.trim(),
      physique: Physique(
        height: int.parse(_heightCtrl.text),
        weight: int.parse(_weightCtrl.text),
        gender: _gender,
        age: int.parse(_ageCtrl.text),
      ),
      goalType: _goalType,
      experience: _experience,
      daysPerWeek: _daysPerWeek.toInt(),
      diet: _diet,
    );

    await fp.generatePlan(prompt);
  }
}

// ── Loading view ──────────────────────────────────────────────────────────────

class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(color: AppColors.mainPoint),
            SizedBox(height: 20),
            Text(
              'Generating your plan…',
              style: TextStyle(
                fontSize: 15,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Reusable sub-widgets ──────────────────────────────────────────────────────

class _EmptyPlanState extends StatelessWidget {
  const _EmptyPlanState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.fitness_center, size: 48, color: AppColors.sub),
          SizedBox(height: 14),
          Text(
            'No plan loaded',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 6),
          Text(
            'Regenerate your plan to see workouts.',
            style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}

class _EmptyDayState extends StatelessWidget {
  const _EmptyDayState({
    required this.emoji,
    required this.title,
    required this.subtitle,
  });

  final String emoji;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 48)),
          const SizedBox(height: 12),
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
            style: const TextStyle(fontSize: 14, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}

class _WorkoutBlockCard extends StatefulWidget {
  const _WorkoutBlockCard({required this.block});

  final DailyBlock block;

  @override
  State<_WorkoutBlockCard> createState() => _WorkoutBlockCardState();
}

class _WorkoutBlockCardState extends State<_WorkoutBlockCard> {
  bool _expanded = true;

  @override
  Widget build(BuildContext context) {
    final block = widget.block;
    return GestureDetector(
      onTap: () => setState(() => _expanded = !_expanded),
      child: Container(
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
                    color: AppColors.mainPoint.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.fitness_center,
                    size: 18,
                    color: AppColors.mainPoint,
                  ),
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
                      Row(
                        children: [
                          Text(
                            '${block.durationMin} min',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(width: 6),
                          const Icon(
                            Icons.location_on,
                            size: 11,
                            color: AppColors.textSecondary,
                          ),
                          const SizedBox(width: 2),
                          const Text(
                            'Eppley',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Icon(
                  _expanded ? Icons.expand_less : Icons.expand_more,
                  size: 20,
                  color: AppColors.textSecondary,
                ),
              ],
            ),
            if (_expanded && block.details.isNotEmpty) ...[
              const SizedBox(height: 12),
              const Divider(height: 1, color: AppColors.sub),
              const SizedBox(height: 10),
              ...block.details.map((item) => _ExerciseRow(item: item)),
            ],
          ],
        ),
      ),
    );
  }
}

class _ExerciseRow extends StatefulWidget {
  const _ExerciseRow({required this.item});

  final ChecklistItem item;

  @override
  State<_ExerciseRow> createState() => _ExerciseRowState();
}

class _ExerciseRowState extends State<_ExerciseRow> {
  bool _showImage = false;

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    final imagePath = MachineImages.resolve(machine: item.machine, exerciseName: item.label);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () {
            setState(() => item.done = !item.done);
          },
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
                      decoration:
                          item.done ? TextDecoration.lineThrough : null,
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
                if (imagePath != null) ...[
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () => setState(() => _showImage = !_showImage),
                    child: Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: _showImage
                              ? AppColors.accent
                              : AppColors.sub,
                          width: 1,
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(5),
                        child: Image.asset(
                          imagePath,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
        if (imagePath != null && _showImage)
          GestureDetector(
            onTap: () => setState(() => _showImage = false),
            child: Container(
              margin: const EdgeInsets.only(left: 28, bottom: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.sub),
              ),
              clipBehavior: Clip.antiAlias,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Image.asset(
                    imagePath,
                    fit: BoxFit.contain,
                    height: 160,
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    color: AppColors.surface,
                    child: Row(
                      children: [
                        const Icon(
                          Icons.location_on,
                          size: 12,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          MockFitness.location,
                          style: const TextStyle(
                            fontSize: 11,
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

class _ThemeCard extends StatelessWidget {
  const _ThemeCard({required this.weekly});

  final WeeklyPlan weekly;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.mainPoint,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Week ${weekly.weekNumber}',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: AppColors.mainPointText.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            weekly.theme,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppColors.mainPointText,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            weekly.notes,
            style: TextStyle(
              fontSize: 13,
              color: AppColors.mainPointText.withValues(alpha: 0.8),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryChecklistRow extends StatefulWidget {
  const _SummaryChecklistRow({required this.item});

  final ChecklistItem item;

  @override
  State<_SummaryChecklistRow> createState() => _SummaryChecklistRowState();
}

class _SummaryChecklistRowState extends State<_SummaryChecklistRow> {
  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    return GestureDetector(
      onTap: () => setState(() => item.done = !item.done),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.sub, width: 1),
        ),
        child: Row(
          children: [
            Icon(
              item.done ? Icons.check_circle : Icons.radio_button_unchecked,
              size: 18,
              color: item.done ? AppColors.success : AppColors.sub,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                item.label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
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
                  fontSize: 13,
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

// ── Form helpers ──────────────────────────────────────────────────────────────

class _FormLabel extends StatelessWidget {
  const _FormLabel({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: AppColors.textSecondary,
        letterSpacing: 0.3,
      ),
    );
  }
}

class _TextField extends StatelessWidget {
  const _TextField({
    required this.controller,
    required this.hint,
    this.keyboardType,
    this.onChanged,
  });

  final TextEditingController controller;
  final String hint;
  final TextInputType? keyboardType;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      inputFormatters: keyboardType == TextInputType.number
          ? [FilteringTextInputFormatter.digitsOnly]
          : null,
      onChanged: onChanged,
      style: const TextStyle(fontSize: 15, color: AppColors.textPrimary),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: AppColors.textSecondary),
        filled: true,
        fillColor: AppColors.surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.sub),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.sub),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.mainPoint),
        ),
      ),
    );
  }
}

class _SegmentedPicker<T> extends StatelessWidget {
  const _SegmentedPicker({
    required this.options,
    required this.labels,
    required this.selected,
    required this.onSelected,
  });

  final List<T> options;
  final List<String> labels;
  final T selected;
  final ValueChanged<T> onSelected;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(options.length, (i) {
        final isSelected = options[i] == selected;
        final isFirst = i == 0;
        final isLast = i == options.length - 1;
        return Expanded(
          child: GestureDetector(
            onTap: () => onSelected(options[i]),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.mainPoint : AppColors.surface,
                borderRadius: BorderRadius.horizontal(
                  left: isFirst ? const Radius.circular(12) : Radius.zero,
                  right: isLast ? const Radius.circular(12) : Radius.zero,
                ),
                border: Border.all(color: AppColors.sub),
              ),
              child: Center(
                child: Text(
                  labels[i],
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: isSelected
                        ? AppColors.mainPointText
                        : AppColors.textPrimary,
                  ),
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}
