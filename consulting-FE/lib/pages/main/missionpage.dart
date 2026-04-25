import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'package:consulting_fe/api/models/fitness_models.dart';
import 'package:consulting_fe/const/app_colors.dart';
import 'package:consulting_fe/mock/machine_images.dart';
import 'package:consulting_fe/mock/mock_fitness.dart';
import 'package:consulting_fe/pages/onboarding/onboarding_intro_page.dart';
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
                if (!mounted) return;
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(
                    builder: (_) => const OnboardingIntroPage(),
                  ),
                  (_) => false,
                );
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

// ── Weekly tab — vertical day tiles ──────────────────────────────────────────

class _WeeklyTab extends StatelessWidget {
  const _WeeklyTab({required this.fp});

  final FitnessProvider fp;

  static const _weekdayNames = [
    'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun',
  ];
  static const _monthNames = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];

  @override
  Widget build(BuildContext context) {
    final plans = fp.plan?.daily ?? [];
    if (plans.isEmpty) return const _EmptyPlanState();

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 120),
      itemCount: plans.length,
      separatorBuilder: (_, _) => const SizedBox(height: 10),
      itemBuilder: (_, i) => _DayTile(
        plan: plans[i],
        weekdayNames: _weekdayNames,
        monthNames: _monthNames,
      ),
    );
  }
}

// ── Day tile ──────────────────────────────────────────────────────────────────

class _DayTile extends StatelessWidget {
  const _DayTile({
    required this.plan,
    required this.weekdayNames,
    required this.monthNames,
  });

  final DailyPlan plan;
  final List<String> weekdayNames;
  final List<String> monthNames;

  bool get _isToday {
    final now = DateTime.now();
    return plan.date.year == now.year &&
        plan.date.month == now.month &&
        plan.date.day == now.day;
  }

  @override
  Widget build(BuildContext context) {
    final isToday = _isToday;
    final workouts = plan.workoutBlocks;
    final dayLabel =
        '${weekdayNames[plan.date.weekday - 1]},  '
        '${monthNames[plan.date.month - 1]} ${plan.date.day}';

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isToday ? AppColors.mainPoint : AppColors.sub,
          width: isToday ? 1.5 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Day header ───────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
            child: Row(
              children: [
                Text(
                  dayLabel,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: isToday
                        ? AppColors.mainPoint
                        : AppColors.textPrimary,
                  ),
                ),
                if (isToday) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.mainPoint,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Text(
                      'Today',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppColors.mainPointText,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.sub),
          // ── Content ──────────────────────────────────────────────────────
          if (workouts.isEmpty)
            _buildNoWorkout()
          else
            ...workouts.map((b) => _WorkoutSection(block: b)),
        ],
      ),
    );
  }

  Widget _buildNoWorkout() {
    final hasRecovery = plan.blocks.any((b) => b.category == 'recovery');
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
      child: Row(
        children: [
          Text(
            hasRecovery ? '🌿' : '😴',
            style: const TextStyle(fontSize: 20),
          ),
          const SizedBox(width: 10),
          Text(
            hasRecovery ? 'Active Recovery' : 'Rest Day',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Workout section inside a day tile ─────────────────────────────────────────

class _WorkoutSection extends StatelessWidget {
  const _WorkoutSection({required this.block});

  final DailyBlock block;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Block header
          Row(
            children: [
              const Icon(Icons.fitness_center, size: 15, color: AppColors.accent),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  block.title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              Text(
                '${block.durationMin} min',
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Row(
            children: const [
              SizedBox(width: 21),
              Icon(Icons.location_on, size: 11, color: AppColors.textSecondary),
              SizedBox(width: 2),
              Text(
                'Eppley',
                style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
              ),
            ],
          ),
          const SizedBox(height: 10),
          // Exercise rows with machine images
          ...block.details.map((item) => _ExerciseTileRow(item: item)),
        ],
      ),
    );
  }
}

// ── Exercise row with machine image thumbnail ─────────────────────────────────

class _ExerciseTileRow extends StatelessWidget {
  const _ExerciseTileRow({required this.item});

  final ChecklistItem item;

  @override
  Widget build(BuildContext context) {
    final imagePath =
        MachineImages.resolve(machine: item.machine, exerciseName: item.label);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          // Machine image thumbnail
          if (imagePath != null)
            Container(
              width: 36,
              height: 36,
              margin: const EdgeInsets.only(right: 10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.sub, width: 1),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(7),
                child: Image.asset(
                  imagePath,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => const Icon(
                    Icons.fitness_center,
                    size: 16,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            )
          else
            const SizedBox(width: 46),
          // Name
          Expanded(
            child: Text(
              item.label,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          // Target
          if (item.targetDisplay.isNotEmpty)
            Text(
              item.targetDisplay,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
        ],
      ),
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
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.sub, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Only the header row is tappable for expand/collapse.
          // This prevents gesture conflicts with exercise row interactions.
          GestureDetector(
            onTap: () => setState(() => _expanded = !_expanded),
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
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
            ),
          ),
          if (_expanded && block.details.isNotEmpty) ...[
            const Divider(height: 1, color: AppColors.sub),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
              child: Column(
                children: block.details.map((item) => _ExerciseRow(item: item)).toList(),
              ),
            ),
          ],
        ],
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
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 5),
          child: Row(
            children: [
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => setState(() => item.done = !item.done),
                child: Icon(
                  item.done ? Icons.check_circle : Icons.radio_button_unchecked,
                  size: 18,
                  color: item.done ? AppColors.success : AppColors.sub,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => setState(() => item.done = !item.done),
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
                  behavior: HitTestBehavior.opaque,
                  onTap: () => setState(() => _showImage = !_showImage),
                  child: Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: _showImage ? AppColors.accent : AppColors.sub,
                        width: 1.5,
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(7),
                      child: Image.asset(
                        imagePath,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => const Icon(
                          Icons.fitness_center,
                          size: 16,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ],
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
                    errorBuilder: (_, _, _) => const SizedBox(
                      height: 160,
                      child: Center(
                        child: Icon(
                          Icons.fitness_center,
                          size: 40,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
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
