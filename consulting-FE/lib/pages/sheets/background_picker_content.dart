import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:shimmer/shimmer.dart';

import 'package:consulting_fe/components/customs/cupertino_native-0.1.1/lib/components/sheet_content.dart';
import 'package:consulting_fe/components/platform/platform_button.dart';
import 'package:consulting_fe/components/platform/platform_sheet.dart';
import 'package:consulting_fe/const/app_colors.dart';
import 'package:consulting_fe/const/app_fonts.dart';

/// Result types:
/// - `{'type': 'preset', 'id': N}`     — built-in preset
/// - `{'type': 'custom', 'path': '…'}` — a saved custom photo
class BackgroundPickerContent extends StatefulWidget {
  const BackgroundPickerContent({
    super.key,
    this.currentPresetId,
    this.currentCustomPath,
  });

  final int? currentPresetId;

  /// Path of the currently applied custom photo (for highlighting).
  final String? currentCustomPath;

  static String assetPath(int id) => 'assets/background/$id.png';
  static const _presetCount = 10;

  /// SharedPreferences key for the ordered list of saved custom photo paths.
  static const _pathsKey = 'custom_wallpaper_paths';

  /// Legacy single-path key (written for parent-page compat on cold-start load).
  static const _legacyKey = 'custom_wallpaper_path';

  @override
  State<BackgroundPickerContent> createState() =>
      _BackgroundPickerContentState();
}

class _BackgroundPickerContentState extends State<BackgroundPickerContent> {
  final _scrollController = ScrollController();
  bool _atTop = true;

  List<String> _customPaths = [];
  bool _loadingPaths = true;

  @override
  void initState() {
    super.initState();
    _loadCustomPaths();
  }

  Future<void> _loadCustomPaths() async {
    final prefs = await SharedPreferences.getInstance();
    // Force fresh read from disk — the sheet may run in a secondary engine
    // whose in-memory cache is stale relative to the primary engine.
    await prefs.reload();
    var paths = List<String>.from(
      prefs.getStringList(BackgroundPickerContent._pathsKey) ?? [],
    );

    // Migrate legacy single-path key if not already in list.
    final legacy = prefs.getString(BackgroundPickerContent._legacyKey);
    if (legacy != null &&
        legacy.isNotEmpty &&
        !paths.contains(legacy) &&
        File(legacy).existsSync()) {
      paths = [legacy, ...paths];
      await prefs.setStringList(BackgroundPickerContent._pathsKey, paths);
    }

    // Keep only files that still exist on disk.
    paths = paths.where((p) => File(p).existsSync()).toList();

    if (mounted) {
      setState(() {
        _customPaths = paths;
        _loadingPaths = false;
      });
    }
  }

  // ── Scroll-lock ────────────────────────────────────────────────────────────

  bool _onScrollNotification(ScrollNotification n) {
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.iOS) return false;
    if (n is ScrollUpdateNotification) {
      if (_scrollController.offset > 1.0 && _atTop) {
        setState(() => _atTop = false);
        CNSheetContent.setScrollLocked(true);
      }
    } else if (n is ScrollEndNotification) {
      if (_scrollController.offset <= 0) {
        if (!_atTop) setState(() => _atTop = true);
        CNSheetContent.setScrollLocked(false);
      }
    }
    return false;
  }

  @override
  void dispose() {
    _scrollController.dispose();
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.iOS) {
      CNSheetContent.setScrollLocked(false);
    }
    super.dispose();
  }

  // ── Album picking ─────────────────────────────────────────────────────────

  Future<void> _pickFromAlbum() async {
    final image = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (image == null || !mounted) return;

    final dir = await getApplicationDocumentsDirectory();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final dest = File('${dir.path}/custom_wallpaper_$timestamp.jpg');
    await File(image.path).copy(dest.path);

    // Save to the list immediately — persisted even if the user closes with X.
    final updatedPaths = [..._customPaths, dest.path];
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(BackgroundPickerContent._pathsKey, updatedPaths);
    // _legacyKey is only updated by the parent when the user actually *applies*
    // a photo — do NOT overwrite it here.

    if (!mounted) return;
    setState(() => _customPaths = updatedPaths);
  }

  // ── Close ─────────────────────────────────────────────────────────────────

  void _close([Map<String, dynamic>? result]) =>
      PlatformSheet.close<Map<String, dynamic>>(context, result);

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final bottomPad = MediaQuery.of(context).padding.bottom;

    return Container(
      color: AppColors.background,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Header ────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.only(
              left: 24,
              right: 16,
              top: 16,
              bottom: 4,
            ),
            child: Row(
              children: [
                const Expanded(
                  child: Text(
                    'Backgrounds',
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
                  androidIcon: Icons.close,
                  isGlass: true,
                  onPressed: () => _close(),
                ),
              ],
            ),
          ),

          // ── Body ──────────────────────────────────────────────────
          Expanded(
            child: NotificationListener<ScrollNotification>(
              onNotification: _onScrollNotification,
              child: CustomScrollView(
                controller: _scrollController,
                physics: const ClampingScrollPhysics(),
                slivers: [
                  // ── Default section ──────────────────────────────
                  const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.only(left: 24, top: 12, bottom: 10),
                      child: _SectionLabel(text: 'Default'),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: _HorizontalRow(
                      children: [
                        for (
                          int i = 1;
                          i <= BackgroundPickerContent._presetCount;
                          i++
                        )
                          _PresetTile(
                            id: i,
                            isSelected: widget.currentPresetId == i,
                            onTap: () => _close({'type': 'preset', 'id': i}),
                          ),
                      ],
                    ),
                  ),

                  // ── Custom section ───────────────────────────────
                  const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.only(left: 24, top: 22, bottom: 10),
                      child: _SectionLabel(text: 'Custom'),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: _loadingPaths
                        ? _ShimmerRow()
                        : _HorizontalRow(
                            children: [
                              for (final path in _customPaths)
                                _CustomTile(
                                  path: path,
                                  isSelected: path == widget.currentCustomPath,
                                  onTap: () =>
                                      _close({'type': 'custom', 'path': path}),
                                ),
                              _AddTile(onTap: _pickFromAlbum),
                            ],
                          ),
                  ),

                  // ── Notice ───────────────────────────────────────
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(20, 14, 20, bottomPad + 28),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Custom photos are saved on this device only',
                            style: TextStyle(
                              fontFamily: AppFonts.normal,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Shimmer placeholder row ───────────────────────────────────────────────────

class _ShimmerRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 175,
      child: Shimmer.fromColors(
        baseColor: AppColors.sub.withValues(alpha: 0.35),
        highlightColor: AppColors.sub.withValues(alpha: 0.7),
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          physics: const NeverScrollableScrollPhysics(),
          itemCount: 3,
          itemBuilder: (context, i) => Padding(
            padding: const EdgeInsets.only(right: 10),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 86,
                  height: 140,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  width: 36,
                  height: 11,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Section label ─────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) => Text(
    text,
    style: const TextStyle(
      fontFamily: AppFonts.normal,
      fontSize: 13,
      fontWeight: FontWeight.w600,
      color: AppColors.textSecondary,
      letterSpacing: 0.2,
    ),
  );
}

// ── Horizontal row wrapper ────────────────────────────────────────────────────

class _HorizontalRow extends StatelessWidget {
  const _HorizontalRow({required this.children});
  final List<Widget> children;

  @override
  Widget build(BuildContext context) => SizedBox(
    height: 175,
    child: ListView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      children: children,
    ),
  );
}

// ── "+" add tile ──────────────────────────────────────────────────────────────

class _AddTile extends StatelessWidget {
  const _AddTile({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 10),
      child: GestureDetector(
        onTap: onTap,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 86,
              height: 140,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  color: AppColors.sub.withValues(alpha: 0.4),
                  child: const Icon(
                    Icons.add_rounded,
                    size: 32,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Add',
              style: TextStyle(
                fontFamily: AppFonts.normal,
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

// ── Preset tile ───────────────────────────────────────────────────────────────

class _PresetTile extends StatelessWidget {
  const _PresetTile({
    required this.id,
    required this.isSelected,
    required this.onTap,
  });
  final int id;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => _Tile(
    isSelected: isSelected,
    onTap: onTap,
    label: '$id',
    child: Image.asset(
      BackgroundPickerContent.assetPath(id),
      fit: BoxFit.cover,
    ),
  );
}

// ── Custom photo tile ─────────────────────────────────────────────────────────

class _CustomTile extends StatelessWidget {
  const _CustomTile({
    required this.path,
    required this.isSelected,
    required this.onTap,
  });
  final String path;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => _Tile(
    isSelected: isSelected,
    onTap: onTap,
    label: 'Photo',
    child: Image.file(File(path), fit: BoxFit.cover),
  );
}

// ── Shared tile shell ─────────────────────────────────────────────────────────

class _Tile extends StatelessWidget {
  const _Tile({
    required this.isSelected,
    required this.onTap,
    required this.label,
    required this.child,
  });
  final bool isSelected;
  final VoidCallback onTap;
  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 10),
      child: GestureDetector(
        onTap: onTap,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 86,
              height: 140,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: child,
                  ),
                  if (isSelected)
                    DecoratedBox(
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.accent, width: 2.5),
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  if (isSelected)
                    Positioned(
                      top: 6,
                      right: 6,
                      child: Container(
                        width: 22,
                        height: 22,
                        decoration: BoxDecoration(
                          color: AppColors.accent,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.check,
                          color: Colors.white,
                          size: 13,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 6),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontFamily: AppFonts.normal,
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: isSelected ? AppColors.accent : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
