import 'package:flutter/material.dart';

import 'package:consulting_fe/components/common/sheet_header.dart';
import 'package:consulting_fe/const/app_colors.dart';
import 'package:consulting_fe/const/app_fonts.dart';

class AlarmSoundSheet {
  AlarmSoundSheet._();

  static Future<String?> show(BuildContext context, {String? current}) {
    return Navigator.of(context).push<String>(
      PageRouteBuilder(
        opaque: false,
        barrierColor: Colors.black54,
        barrierDismissible: true,
        transitionDuration: const Duration(milliseconds: 400),
        reverseTransitionDuration: const Duration(milliseconds: 300),
        pageBuilder: (_, _, _) =>
            _AlarmSoundSheetPage(current: current ?? 'Radar'),
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

class _AlarmSoundSheetPage extends StatefulWidget {
  const _AlarmSoundSheetPage({required this.current});

  final String current;

  @override
  State<_AlarmSoundSheetPage> createState() => _AlarmSoundSheetPageState();
}

class _AlarmSoundSheetPageState extends State<_AlarmSoundSheetPage> {
  static const _sounds = [
    'Radar',
    'Beacon',
    'Ripple',
    'Reflection',
    'Chime',
    'Apex',
    'Bulletin',
    'By The Seaside',
    'Hillside',
    'Illuminate',
    'Night Owl',
    'Presto',
  ];

  late String _selected;

  @override
  void initState() {
    super.initState();
    _selected = widget.current;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        bottom: false,
        child: Container(
          decoration: const BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildHandle(),
              Flexible(
                child: ListView.builder(
                  padding: const EdgeInsets.only(bottom: 48),
                  shrinkWrap: true,
                  physics: const BouncingScrollPhysics(),
                  itemCount: _sounds.length,
                  itemBuilder: (_, i) => _buildSoundTile(_sounds[i]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHandle() {
    return Column(
      children: [
        SheetHeader(
          title: 'Alarm Sound',
          showGrabber: false,
          onClose: () => Navigator.pop(context),
        ),
        const Divider(height: 1, thickness: 0.5, color: AppColors.sub),
      ],
    );
  }

  Widget _buildSoundTile(String sound) {
    final isSelected = sound == _selected;
    return GestureDetector(
      onTap: () {
        setState(() => _selected = sound);
        Navigator.of(context).pop(sound);
      },
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: AppColors.sub, width: 0.5)),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                sound,
                style: TextStyle(
                  fontFamily: AppFonts.normal,
                  fontSize: 16,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: isSelected
                      ? AppColors.textPrimary
                      : AppColors.textSecondary,
                ),
              ),
            ),
            if (isSelected)
              const Icon(
                Icons.check_rounded,
                size: 20,
                color: AppColors.accent,
              ),
          ],
        ),
      ),
    );
  }
}
