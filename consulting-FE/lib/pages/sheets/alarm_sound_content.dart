import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:consulting_fe/components/platform/platform_button.dart';
import 'package:consulting_fe/const/app_colors.dart';
import 'package:consulting_fe/const/app_fonts.dart';

/// Standalone alarm-sound picker for use inside a native iOS sheet or
/// Flutter `showModalBottomSheet`.
class AlarmSoundSheetContent extends StatefulWidget {
  const AlarmSoundSheetContent({
    super.key,
    this.current = 'Radar',
    this.onResult,
  });

  final String current;

  /// Called when the user selects a sound.  If null the widget does nothing
  /// on tap (caller should wrap it in a sheet that handles dismissal).
  final ValueChanged<String?>? onResult;

  @override
  State<AlarmSoundSheetContent> createState() => _AlarmSoundSheetContentState();
}

class _AlarmSoundSheetContentState extends State<AlarmSoundSheetContent> {
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
  final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();
    _selected = widget.current;
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  /// Plays a preview of the selected sound.
  /// Expects the audio files to be placed in `assets/alarm/` as `.mp3`
  Future<void> _previewSound(String soundName) async {
    try {
      await _audioPlayer.stop(); // Stop currently playing sound
      // Spaces might need to be handled, but assuming exact match with filename:
      // e.g., 'By The Seaside' -> 'By The Seaside.mp3'
      await _audioPlayer.play(AssetSource('alarm/$soundName.mp3'));
    } catch (e) {
      debugPrint('Error playing sound preview for $soundName: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.background,
      child: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.only(bottom: 48),
              physics: const BouncingScrollPhysics(),
              itemCount: _sounds.length,
              itemBuilder: (_, i) => _buildSoundTile(_sounds[i]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.only(left: 24, right: 16, top: 16, bottom: 16),
      child: Row(
        children: [
          const Expanded(
            child: Text(
              'Alarm Sound',
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

  Widget _buildSoundTile(String sound) {
    final isSelected = sound == _selected;
    return GestureDetector(
      onTap: () {
        setState(() => _selected = sound);
        _previewSound(sound);
        widget.onResult?.call(sound);
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
