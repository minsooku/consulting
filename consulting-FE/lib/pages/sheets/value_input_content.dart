import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import 'package:consulting_fe/components/common/sheet_header.dart';
import 'package:consulting_fe/components/customs/number_flow/number_flow.dart';
import 'package:consulting_fe/components/platform/platform_sheet.dart';
import 'package:consulting_fe/const/app_colors.dart';
import 'package:consulting_fe/const/app_fonts.dart';
import 'package:consulting_fe/components/customs/cupertino_native-0.1.1/lib/style/sheet_detent.dart';

/// Shows a platform-native bottom sheet for entering a value.
///
/// iOS  → native `UISheetPresentationController` via 'valueInput' route.
/// Android → slide-up Flutter sheet fallback.
Future<String?> showValueInput(
  BuildContext context, {
  required String initialValue,
  String? label,
  String? hint,
  bool isReady = false,
  bool isPlainText = false,
}) {
  return PlatformSheet.show<String>(
    context: context,
    route: 'valueInput',
    arguments: {
      'initialValue': initialValue,
      if (label != null) 'label': label,
      if (hint != null) 'hint': hint,
      'isReady': isReady,
      'isPlainText': isPlainText,
    },
    detents: [CNSheetDetent.medium],
    initialDetent: CNSheetDetent.medium,
    showDragHandle: false,
    dismissible: true,
    cornerRadius: 30,
    builder: (ctx) => _KeyboardAwareWrap(
      child: ValueInputContent(
        initialValue: initialValue,
        label: label,
        hint: hint,
        isReady: isReady,
        isPlainText: isPlainText,
        onResult: (v) => PlatformSheet.close<String>(ctx, v),
      ),
    ),
  );
}

class _KeyboardAwareWrap extends StatefulWidget {
  const _KeyboardAwareWrap({required this.child});
  final Widget child;

  @override
  State<_KeyboardAwareWrap> createState() => _KeyboardAwareWrapState();
}

class _KeyboardAwareWrapState extends State<_KeyboardAwareWrap> {
  double _bottom = 0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final newBottom = MediaQuery.viewInsetsOf(context).bottom;
    final shouldUpdate =
        newBottom > _bottom || (newBottom < 100 && _bottom >= 100);
    if (shouldUpdate) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) setState(() => _bottom = newBottom);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: _bottom),
      child: widget.child,
    );
  }
}

class ValueInputContent extends StatefulWidget {
  const ValueInputContent({
    super.key,
    required this.initialValue,
    this.label,
    this.hint,
    this.isReady = false,
    this.isPlainText = false,
    this.onResult,
  });

  final String initialValue;
  final String? label;
  final String? hint;
  final bool isReady;
  final bool isPlainText;
  final ValueChanged<String?>? onResult;

  @override
  State<ValueInputContent> createState() => _ValueInputContentState();
}

class _ValueInputContentState extends State<ValueInputContent> {
  // ── Time (24-hour internally) ──────────────────────────────────────────────
  late int _hour24;
  late int _minute;

  // ── Duration ───────────────────────────────────────────────────────────────
  late int _duration;

  // ── Shared swipe state ─────────────────────────────────────────────────────
  double _dragAccum = 0;
  int _trend = 0; // 1 = increasing, -1 = decreasing (drives NumberFlow roll)

  // ── Plain text ─────────────────────────────────────────────────────────────
  late final TextEditingController _textCtrl;
  late final FocusNode _focusNode;

  // Pixels of drag per one step — lower = faster response.
  static const _stepPx = 6.0;

  @override
  void initState() {
    super.initState();

    if (widget.isReady) {
      final m = RegExp(r'(\d+)').firstMatch(widget.initialValue);
      _duration = int.tryParse(m?.group(0) ?? '45') ?? 45;
      _hour24 = 9;
      _minute = 0;
      _textCtrl = TextEditingController();
      _focusNode = FocusNode();
    } else if (widget.isPlainText) {
      _textCtrl = TextEditingController(text: widget.initialValue);
      _focusNode = FocusNode();
      _hour24 = 9;
      _minute = 0;
      _duration = 45;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _focusNode.requestFocus();
      });
    } else {
      final m = RegExp(r'(\d{1,2}):(\d{2})').firstMatch(widget.initialValue);
      final h12 = (int.tryParse(m?.group(1) ?? '9') ?? 9).clamp(1, 12);
      _minute = (int.tryParse(m?.group(2) ?? '0') ?? 0).clamp(0, 59);
      final ap = RegExp(
        r'(AM|PM)',
        caseSensitive: false,
      ).firstMatch(widget.initialValue);
      final amPm = ap?.group(0)?.toUpperCase() ?? 'AM';
      _hour24 = amPm == 'AM'
          ? (h12 == 12 ? 0 : h12)
          : (h12 == 12 ? 12 : h12 + 12);
      _duration = 45;
      _textCtrl = TextEditingController();
      _focusNode = FocusNode();
    }
  }

  @override
  void dispose() {
    _textCtrl.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  // ── Swipe handlers (whole-sheet gesture) ───────────────────────────────────

  void _onDragStart(DragStartDetails _) => setState(() => _dragAccum = 0);

  void _onDragUpdate(DragUpdateDetails d) {
    _dragAccum += d.delta.dx;
    while (_dragAccum >= _stepPx) {
      _dragAccum -= _stepPx;
      widget.isReady ? _stepDuration(1) : _stepTime(1);
    }
    while (_dragAccum <= -_stepPx) {
      _dragAccum += _stepPx;
      widget.isReady ? _stepDuration(-1) : _stepTime(-1);
    }
  }

  void _onDragEnd(DragEndDetails _) => setState(() => _dragAccum = 0);

  /// Advance/rewind by [delta] minutes, wrapping on 24-hour boundary.
  void _stepTime(int delta) {
    final totalMins = _hour24 * 60 + _minute + delta;
    final wrapped = ((totalMins % 1440) + 1440) % 1440;
    setState(() {
      _trend = delta > 0 ? 1 : -1;
      _hour24 = wrapped ~/ 60;
      _minute = wrapped % 60;
    });
    HapticFeedback.selectionClick();
  }

  /// Advance/rewind duration by [delta] minutes, clamped to 1–180.
  void _stepDuration(int delta) {
    final next = (_duration + delta).clamp(1, 180);
    if (next == _duration) return;
    setState(() {
      _trend = delta > 0 ? 1 : -1;
      _duration = next;
    });
    HapticFeedback.selectionClick();
  }

  // ── Result ─────────────────────────────────────────────────────────────────

  String _buildResult() {
    if (widget.isReady) return '$_duration\u00A0min';
    if (widget.isPlainText) {
      final v = _textCtrl.text.trim();
      return v.isEmpty ? widget.initialValue : v;
    }
    final h12 = _hour24 % 12 == 0 ? 12 : _hour24 % 12;
    final amPm = _hour24 < 12 ? 'AM' : 'PM';
    return '$h12:${_minute.toString().padLeft(2, '0')}\u00A0$amPm';
  }

  void _save() {
    HapticFeedback.mediumImpact();
    widget.onResult?.call(_buildResult());
  }

  void _close() => widget.onResult?.call(null);

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final title =
        widget.label ??
        (widget.isReady
            ? 'Ready Time'
            : widget.isPlainText
            ? 'Edit'
            : 'Set Time');

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SheetHeader(
          title: title,
          onClose: _close,
          showGrabber: false,
          titleFontSize: 18,
        ),

        if (widget.isPlainText) ...[
          const SizedBox(height: 28),
          _buildPlainTextSection(),
          const SizedBox(height: 28),
        ] else ...[
          // ── Swipe zone: whole area between header and save ─────────────────
          GestureDetector(
            onHorizontalDragStart: _onDragStart,
            onHorizontalDragUpdate: _onDragUpdate,
            onHorizontalDragEnd: _onDragEnd,
            behavior: HitTestBehavior.opaque,
            child: SizedBox(
              height: 280,
              width: double.infinity,
              child: Center(
                child: widget.isReady
                    ? _buildDurationDisplay()
                    : _buildTimeDisplay(),
              ),
            ),
          ),
          _buildSwipeHint(),
          const SizedBox(height: 16),
        ],

        if (widget.hint != null) ...[
          const SizedBox(height: 4),
          Text(
            widget.hint!,
            style: const TextStyle(
              fontFamily: AppFonts.normal,
              fontSize: 13,
              color: AppColors.mainPoint,
            ),
          ),
          const SizedBox(height: 12),
        ],

        // Plain-text mode: keyboard Done button acts as save — no button needed.
        if (!widget.isPlainText)
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
            child: SizedBox(
              width: double.infinity,
              height: 52,
              child: FilledButton(
                onPressed: _save,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.mainPoint,
                  foregroundColor: AppColors.mainPointText,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  textStyle: const TextStyle(
                    fontFamily: AppFonts.normal,
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                child: const Text('Save'),
              ),
            ),
          ),
      ],
    );
  }

  // ── Time display ─── pure NumberFlow, no gesture zones ────────────────────

  Widget _buildTimeDisplay() {
    final displayHour = _hour24 % 12 == 0 ? 12 : _hour24 % 12;
    final amPm = _hour24 < 12 ? 'AM' : 'PM';

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        NumberFlow(
          value: displayHour.toDouble(),
          format: NumberFormat('#0'),
          trend: _trend,
          duration: const Duration(milliseconds: 160),
          curve: Curves.easeOut,
          style: _numStyle,
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 6, left: 3, right: 3),
          child: Text(
            ':',
            style: TextStyle(
              fontFamily: AppFonts.round,
              fontSize: _fontSize * 0.82,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary.withValues(alpha: 0.35),
              height: 1,
            ),
          ),
        ),
        NumberFlow(
          value: _minute.toDouble(),
          format: NumberFormat('00'),
          trend: _trend,
          duration: const Duration(milliseconds: 160),
          curve: Curves.easeOut,
          style: _numStyle,
        ),
        Padding(
          padding: const EdgeInsets.only(left: 8, bottom: 10),
          child: RollingText(
            text: amPm,
            style: TextStyle(
              fontFamily: AppFonts.round,
              fontSize: _fontSize * 0.28,
              fontWeight: FontWeight.w700,
              color: AppColors.textSecondary,
            ),
            duration: const Duration(milliseconds: 260),
          ),
        ),
      ],
    );
  }

  // ── Duration display ───────────────────────────────────────────────────────

  Widget _buildDurationDisplay() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        NumberFlow(
          value: _duration.toDouble(),
          format: NumberFormat('#0'),
          trend: _trend,
          duration: const Duration(milliseconds: 160),
          curve: Curves.easeOut,
          style: _numStyle,
        ),
        Padding(
          padding: const EdgeInsets.only(left: 8, bottom: 10),
          child: Text(
            'min',
            style: TextStyle(
              fontFamily: AppFonts.round,
              fontSize: _fontSize * 0.28,
              fontWeight: FontWeight.w700,
              color: AppColors.textSecondary,
            ),
          ),
        ),
      ],
    );
  }

  // ── Plain text ─── no box, just large centered text ───────────────────────

  Widget _buildPlainTextSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: TextField(
        controller: _textCtrl,
        focusNode: _focusNode,
        textAlign: TextAlign.center,
        textCapitalization: TextCapitalization.words,
        textInputAction: TextInputAction.done,
        onSubmitted: (_) => _save(),
        style: const TextStyle(
          fontFamily: AppFonts.normal,
          fontSize: 38,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
          height: 1.25,
        ),
        cursorColor: AppColors.textPrimary,
        cursorWidth: 2.5,
        cursorHeight: 44,
        contextMenuBuilder: (_, __) => const SizedBox.shrink(),
        decoration: InputDecoration(
          hintText: widget.hint ?? '',
          hintStyle: TextStyle(
            fontFamily: AppFonts.normal,
            fontSize: 38,
            fontWeight: FontWeight.w700,
            color: AppColors.textSecondary.withValues(alpha: 0.22),
          ),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          contentPadding: EdgeInsets.zero,
          isDense: true,
        ),
        onTap: () => _textCtrl.selection = TextSelection(
          baseOffset: 0,
          extentOffset: _textCtrl.text.length,
        ),
      ),
    );
  }

  // ── Swipe hint ─────────────────────────────────────────────────────────────

  Widget _buildSwipeHint() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.swap_horiz_rounded,
          size: 13,
          color: AppColors.textSecondary,
        ),
        const SizedBox(width: 4),
        Text(
          'swipe to adjust',
          style: TextStyle(
            fontFamily: AppFonts.normal,
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  // ── Shared styles ──────────────────────────────────────────────────────────

  static const _fontSize = 68.0;

  static const _numStyle = TextStyle(
    fontFamily: AppFonts.round,
    fontSize: _fontSize,
    fontWeight: FontWeight.w800,
    color: AppColors.textPrimary,
    height: 1,
  );
}
