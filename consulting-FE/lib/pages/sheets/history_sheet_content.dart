import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:consulting_fe/api/alarms_api.dart';
import 'package:consulting_fe/api/models/alarm_model.dart';
import 'package:consulting_fe/components/customs/cupertino_native-0.1.1/lib/components/sheet_content.dart';
import 'package:consulting_fe/components/platform/platform_button.dart';
import 'package:consulting_fe/const/app_colors.dart';
import 'package:consulting_fe/const/app_fonts.dart';

/// Standalone history sheet content for use inside a native iOS sheet
/// (via `CNSheetApp`) or a Flutter `showModalBottomSheet`.
///
/// Does **not** depend on `smooth_sheets` or parent Providers – it fetches
/// data directly from the API.
class HistorySheetContent extends StatefulWidget {
  const HistorySheetContent({
    super.key,
    this.onClose,
    this.arguments = const {},
  });

  final VoidCallback? onClose;
  final Map<String, dynamic> arguments;

  @override
  State<HistorySheetContent> createState() => _HistorySheetContentState();
}

class _HistorySheetContentState extends State<HistorySheetContent> {
  late Future<List<AlarmHistoryItem>> _future;
  Map<String, dynamic>? _selectedItem;

  @override
  void initState() {
    super.initState();
    _future = AlarmsApi.instance.getHistory();
  }

  void _close() {
    if (widget.onClose != null) {
      widget.onClose!();
    } else {
      CNSheetContent.close();
    }
  }

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
    if (_selectedItem != null) {
      return _DetailView(
        item: _selectedItem!,
        onBack: () => setState(() => _selectedItem = null),
        onClose: _close,
      );
    }
    return _buildList();
  }

  Widget _buildList() {
    return FutureBuilder<List<AlarmHistoryItem>>(
      future: _future,
      builder: (context, snapshot) {
        final isLoading = snapshot.connectionState == ConnectionState.waiting;
        final items = (snapshot.data ?? [])
            .where((i) => i.alarm.status == 'departed')
            .toList();

        return Column(
          children: [
            _Header(
              title: 'History',
              subtitle: isLoading ? '...' : '${items.length} trips',
              onClose: _close,
            ),
            Expanded(child: _buildListBody(snapshot, items)),
          ],
        );
      },
    );
  }

  Widget _buildListBody(
    AsyncSnapshot<List<AlarmHistoryItem>> snapshot,
    List<AlarmHistoryItem> items,
  ) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return const Center(child: CupertinoActivityIndicator());
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

        return _HistoryCardCompact(
          originLabel: alarm.origin?.label ?? '-',
          destinationLabel: alarm.destination?.label ?? '-',
          date: alarm.targetArrivalTime,
          actualMinutes: trip?.actualMinutes?.toDouble(),
          savedVsPrediction: trip?.savedVsPrediction?.toDouble(),
          onTap: () => setState(() => _selectedItem = _toMap(historyItem)),
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Header (no native platform views – safe for secondary engine)
// ---------------------------------------------------------------------------

class _Header extends StatelessWidget {
  const _Header({
    required this.title,
    this.subtitle,
    required this.onClose,
  });

  final String title;
  final String? subtitle;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 24, right: 16, top: 16, bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontFamily: AppFonts.normal,
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle!,
                    style: const TextStyle(
                      fontFamily: AppFonts.normal,
                      fontSize: 15,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ],
            ),
          ),
          PlatformIconButton(
            iosIcon: 'xmark',
            androidIcon: Icons.close,
            onPressed: onClose,
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Compact history card (pure Flutter, no native views)
// ---------------------------------------------------------------------------

class _HistoryCardCompact extends StatelessWidget {
  const _HistoryCardCompact({
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
  Widget build(BuildContext context) {
    Color trailingColor = AppColors.textPrimary;
    String trailingText = 'N/A';
    String? badge;

    if (actualMinutes != null) {
      trailingText = '${actualMinutes!.toStringAsFixed(0)} min';
      if (savedVsPrediction != null && savedVsPrediction! > 0) {
        trailingColor = AppColors.success;
        badge = '${savedVsPrediction!.toStringAsFixed(0)}m faster';
      } else if (savedVsPrediction != null && savedVsPrediction! < 0) {
        trailingColor = AppColors.danger;
        badge = '${savedVsPrediction!.abs().toStringAsFixed(0)}m slower';
      }
    }

    final dateStr = DateFormat('MMM d, yyyy').format(date);

    return GestureDetector(
      onTap: onTap,
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
                    '$originLabel → $destinationLabel',
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
    );
  }
}

// ---------------------------------------------------------------------------
// Detail view
// ---------------------------------------------------------------------------

class _DetailView extends StatelessWidget {
  const _DetailView({
    required this.item,
    required this.onBack,
    required this.onClose,
  });

  final Map<String, dynamic> item;
  final VoidCallback onBack;
  final VoidCallback onClose;

  static final _timeFormat = DateFormat('h:mm a');
  static final _dateFormat = DateFormat('EEE, MMM d, yyyy');

  @override
  Widget build(BuildContext context) {
    final origin = item['origin'] as Map<String, dynamic>;
    final dest = item['destination'] as Map<String, dynamic>;
    final targetTime =
        DateTime.parse(item['target_arrival_time'] as String).toLocal();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 16, right: 16, top: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              PlatformIconButton(
                iosIcon: 'chevron.backward',
                androidIcon: Icons.arrow_back_ios_new_rounded,
                onPressed: onBack,
              ),
              PlatformIconButton(
                iosIcon: 'xmark',
                androidIcon: Icons.close,
                onPressed: onClose,
              ),
            ],
          ),
        ),
        Padding(
          padding:
              const EdgeInsets.only(left: 24, right: 24, top: 24, bottom: 16),
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

  Widget _buildContent() {
    final wakeRaw = item['wake_up_time'] as String?;
    final depRaw = item['estimated_departure_time'] as String?;
    final targetTime =
        DateTime.parse(item['target_arrival_time'] as String).toLocal();

    final origin = item['origin'] as Map<String, dynamic>;
    final dest = item['destination'] as Map<String, dynamic>;
    final trip = item['trip'] as Map<String, dynamic>?;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (wakeRaw != null)
          _infoRow(
            'Wake Up',
            _timeFormat.format(DateTime.parse(wakeRaw).toLocal()),
            CupertinoIcons.alarm,
          ),
        if (wakeRaw != null) const SizedBox(height: 14),
        if (depRaw != null)
          _infoRow(
            'Departure',
            _timeFormat.format(DateTime.parse(depRaw).toLocal()),
            CupertinoIcons.arrow_right_circle,
          ),
        if (depRaw != null) const SizedBox(height: 14),
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
          _statRow('Status', item['status'].toString().toUpperCase()),
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
          _statRow('Status', item['status'].toString().toUpperCase()),
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
