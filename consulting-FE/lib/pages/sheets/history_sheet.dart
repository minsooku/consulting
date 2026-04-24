import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:consulting_fe/api/alarms_api.dart';
import 'package:consulting_fe/api/models/alarm_model.dart';
import 'package:consulting_fe/components/common/history_card.dart';
import 'package:consulting_fe/components/common/sheet_header.dart';
import 'package:consulting_fe/components/platform/platform_button.dart';
import 'package:consulting_fe/const/app_colors.dart';
import 'package:consulting_fe/const/app_fonts.dart';
import 'package:smooth_sheets/smooth_sheets.dart';

// ---------------------------------------------------------------------------
// Public entry point
// ---------------------------------------------------------------------------

class HistorySheet {
  HistorySheet._();

  static Future<void> show(BuildContext context, {VoidCallback? onWillClose}) {
    return Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        barrierColor: Colors.black54,
        barrierDismissible: true,
        transitionDuration: const Duration(milliseconds: 400),
        reverseTransitionDuration: const Duration(milliseconds: 300),
        pageBuilder: (_, _, _) => _HistorySheetPage(onWillClose: onWillClose),
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
// Sheet root — PagedSheet with in-place page navigation
// ---------------------------------------------------------------------------

class _HistorySheetPage extends StatefulWidget {
  const _HistorySheetPage({this.onWillClose});

  final VoidCallback? onWillClose;

  @override
  State<_HistorySheetPage> createState() => _HistorySheetPageState();
}

class _HistorySheetPageState extends State<_HistorySheetPage> {
  Map<String, dynamic>? _selectedItem;

  void _handleClose(BuildContext outerContext) {
    widget.onWillClose?.call();
    Future.delayed(const Duration(milliseconds: 80), () {
      if (outerContext.mounted) Navigator.of(outerContext).pop();
    });
  }

  @override
  Widget build(BuildContext context) {
    final outerContext = context;

    final pages = <Page<void>>[
      PagedSheetPage<void>(
        key: const ValueKey('list'),
        transitionDuration: const Duration(milliseconds: 300),
        transitionsBuilder: _pageTransition,
        child: _HistoryListPage(
          onItemTap: (item) => setState(() => _selectedItem = item),
          onClose: () => _handleClose(outerContext),
        ),
      ),
      if (_selectedItem != null)
        PagedSheetPage<void>(
          key: ValueKey(_selectedItem!['id']),
          transitionDuration: const Duration(milliseconds: 300),
          transitionsBuilder: _pageTransition,
          child: _HistoryDetailPage(
            item: _selectedItem!,
            onClose: () => _handleClose(outerContext),
          ),
        ),
    ];

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
                pages: pages,
                onDidRemovePage: (page) {
                  if (page.key != const ValueKey('list')) {
                    setState(() => _selectedItem = null);
                  }
                },
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
  final theme = Theme.of(context).pageTransitionsTheme;
  return FadeTransition(
    opacity: CurveTween(curve: Curves.easeInExpo).animate(animation),
    child: FadeTransition(
      opacity: Tween(begin: 1.0, end: 0.0)
          .chain(CurveTween(curve: Curves.easeOutExpo))
          .animate(secondaryAnimation),
      child: theme.buildTransitions(
        ModalRoute.of(context) as PageRoute,
        context,
        animation,
        secondaryAnimation,
        child,
      ),
    ),
  );
}

// ---------------------------------------------------------------------------
// List page
// ---------------------------------------------------------------------------

class _HistoryListPage extends StatefulWidget {
  const _HistoryListPage({required this.onItemTap, required this.onClose});

  final ValueChanged<Map<String, dynamic>> onItemTap;
  final VoidCallback onClose;

  @override
  State<_HistoryListPage> createState() => _HistoryListPageState();
}

class _HistoryListPageState extends State<_HistoryListPage> {
  late Future<List<AlarmHistoryItem>> _future;

  @override
  void initState() {
    super.initState();
    _future = AlarmsApi.instance.getHistory();
  }

  /// AlarmHistoryItem → 기존 UI가 기대하는 Map 구조로 변환
  Map<String, dynamic> _toMap(AlarmHistoryItem item) {
    final alarm = item.alarm;
    final trip = item.trip;
    return {
      'id': alarm.id,
      'origin': alarm.origin != null
          ? {'label': alarm.origin!.label, 'address': alarm.origin!.label}
          : {'label': '-', 'address': ''},
      'destination': alarm.destination != null
          ? {
              'label': alarm.destination!.label,
              'address': alarm.destination!.label,
            }
          : {'label': '-', 'address': ''},
      'target_arrival_time': alarm.targetArrivalTime.toIso8601String(),
      'transport_mode': alarm.transportMode,
      'wake_up_time': alarm.wakeUpTime?.toIso8601String(),
      'estimated_departure_time':
          alarm.estimatedDepartureTime?.toIso8601String(),
      'predicted_travel_minutes': alarm.predictedTravelMinutes,
      'status': alarm.status,
      'created_at': alarm.createdAt.toIso8601String(),
      'trip': trip != null
          ? {
              'date': trip.date,
              'weekday': trip.weekday,
              'predicted_minutes': trip.predictedMinutes,
              'actual_minutes': trip.actualMinutes,
              'free_flow_minutes': trip.freeFlowMinutes,
              'traffic_status': trip.trafficStatus,
              'saved_vs_prediction': trip.savedVsPrediction,
              'saved_vs_freeflow': trip.savedVsFreeflow,
            }
          : null,
    };
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<AlarmHistoryItem>>(
      future: _future,
      builder: (context, snapshot) {
        final isLoading = snapshot.connectionState == ConnectionState.waiting;
        final tripCount = (snapshot.data ?? [])
            .where((i) => i.alarm.status == 'departed')
            .length;

        return Column(
          children: [
            SheetHeader(
              title: 'History',
              showGrabber: false,
              subtitle: isLoading ? '...' : '$tripCount trips',
              onClose: widget.onClose,
            ),
            Expanded(child: _buildList(snapshot)),
          ],
        );
      },
    );
  }

  Widget _buildList(AsyncSnapshot<List<AlarmHistoryItem>> snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return const Center(child: CircularProgressIndicator());
    }
    if (snapshot.hasError) {
      return Center(
        child: Text(
          'Could not load history.',
          style: TextStyle(
            fontSize: 15,
            color: AppColors.textSecondary.withValues(alpha: 0.7),
          ),
        ),
      );
    }

    final items = (snapshot.data ?? [])
        .where((i) => i.alarm.status == 'departed')
        .toList();

    if (items.isEmpty) {
      return const Center(
        child: Text(
          'No trips yet.',
          style: TextStyle(fontSize: 16, color: AppColors.textSecondary),
        ),
      );
    }

    return ListView.separated(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        bottom: MediaQuery.of(context).padding.bottom + 20,
      ),
      itemCount: items.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final historyItem = items[index];
        final alarm = historyItem.alarm;
        final trip = historyItem.trip;

        return HistoryCard(
          originLabel: alarm.origin?.label ?? '-',
          destinationLabel: alarm.destination?.label ?? '-',
          date: alarm.targetArrivalTime,
          actualMinutes: trip?.actualMinutes?.toDouble(),
          savedVsPrediction: trip?.savedVsPrediction?.toDouble(),
          onTap: () => widget.onItemTap(_toMap(historyItem)),
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Detail page
// ---------------------------------------------------------------------------

class _HistoryDetailPage extends StatefulWidget {
  const _HistoryDetailPage({required this.item, this.onClose});

  final Map<String, dynamic> item;
  final VoidCallback? onClose;

  @override
  State<_HistoryDetailPage> createState() => _HistoryDetailPageState();
}

class _HistoryDetailPageState extends State<_HistoryDetailPage> {
  final _timeFormat = DateFormat('h:mm a');
  final _dateFormat = DateFormat('EEE, MMM d, yyyy');

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SheetGrabber(),
        _buildHeader(),

        Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.only(
              left: 20,
              right: 20,
              bottom: MediaQuery.of(context).padding.bottom + 24,
            ),
            child: _buildContent(),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    final origin = widget.item['origin'] as Map<String, dynamic>;
    final dest = widget.item['destination'] as Map<String, dynamic>;
    final targetTime = DateTime.parse(
      widget.item['target_arrival_time'] as String,
    ).toLocal();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 20, right: 16, top: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              PlatformIconButton(
                iosIcon: 'chevron.backward',
                androidIcon: Icons.arrow_back_ios_new_rounded,
                onPressed: () => Navigator.of(context).pop(),
              ),
              PlatformIconButton(
                iosIcon: 'xmark',
                androidIcon: Icons.close,
                onPressed: widget.onClose,
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(
            left: 24,
            right: 24,
            top: 24,
            bottom: 16,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${origin['label']} → ${dest['label']}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontFamily: AppFonts.normal,
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                _dateFormat.format(targetTime),
                style: const TextStyle(
                  fontFamily: AppFonts.normal,
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildContent() {
    final wakeTime = DateTime.parse(
      widget.item['wake_up_time'] as String,
    ).toLocal();
    final depTime = DateTime.parse(
      widget.item['estimated_departure_time'] as String,
    ).toLocal();
    final targetTime = DateTime.parse(
      widget.item['target_arrival_time'] as String,
    ).toLocal();

    final origin = widget.item['origin'] as Map<String, dynamic>;
    final dest = widget.item['destination'] as Map<String, dynamic>;
    final trip = widget.item['trip'] as Map<String, dynamic>?;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _infoRow('Wake Up', _timeFormat.format(wakeTime), CupertinoIcons.alarm),
        const SizedBox(height: 14),
        _infoRow(
          'Departure',
          _timeFormat.format(depTime),
          CupertinoIcons.arrow_right_circle,
        ),
        const SizedBox(height: 14),
        _infoRow(
          'Target Arrival',
          _timeFormat.format(targetTime),
          CupertinoIcons.flag,
        ),
        const Divider(height: 32, color: AppColors.sub),
        _addressRow('From', origin['address'] as String),
        const SizedBox(height: 14),
        _addressRow('To', dest['address'] as String),
        const Divider(height: 32, color: AppColors.sub),
        if (trip != null) ...[
          const Text(
            'Trip Summary',
            style: TextStyle(
              fontFamily: AppFonts.normal,
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          _statRow('Status', widget.item['status'].toString().toUpperCase()),
          const SizedBox(height: 10),
          _statRow('Predicted', '${trip['predicted_minutes']} min'),
          const SizedBox(height: 10),
          _statRow(
            'Actual',
            '${trip['actual_minutes']} min',
            isHighlight: true,
            isPositive: (trip['saved_vs_prediction'] as num) > 0,
          ),
          const SizedBox(height: 10),
          _statRow(
            'Traffic',
            (trip['traffic_status'] as String)
                .replaceAll('_', ' ')
                .toUpperCase(),
          ),
        ] else ...[
          const Text(
            'No trip data available.',
            style: TextStyle(
              fontFamily: AppFonts.normal,
              fontSize: 16,
              color: AppColors.textSecondary,
              fontStyle: FontStyle.italic,
            ),
          ),
          const SizedBox(height: 10),
          _statRow('Status', widget.item['status'].toString().toUpperCase()),
        ],
      ],
    );
  }

  Widget _infoRow(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppColors.textSecondary),
        const SizedBox(width: 12),
        Flexible(
          child: Text(
            label,
            style: const TextStyle(
              fontFamily: AppFonts.normal,
              fontSize: 15,
              color: AppColors.textSecondary,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          value,
          style: const TextStyle(
            fontFamily: AppFonts.normal,
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _addressRow(String label, String address) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontFamily: AppFonts.normal,
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          address,
          style: const TextStyle(
            fontFamily: AppFonts.normal,
            fontSize: 15,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _statRow(
    String label,
    String value, {
    bool isHighlight = false,
    bool isPositive = true,
  }) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              fontFamily: AppFonts.normal,
              fontSize: 15,
              color: AppColors.textSecondary,
            ),
          ),
        ),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.end,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontFamily: AppFonts.normal,
              fontSize: 15,
              fontWeight: isHighlight ? FontWeight.bold : FontWeight.w500,
              color: isHighlight
                  ? (isPositive ? AppColors.success : AppColors.danger)
                  : AppColors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }
}

