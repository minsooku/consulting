import 'package:flutter/material.dart';
import 'package:consulting_fe/components/platform/platform_button.dart';
import 'package:consulting_fe/const/app_colors.dart';
import 'package:consulting_fe/const/app_fonts.dart';

class TransportModeContent extends StatefulWidget {
  const TransportModeContent({super.key, this.current = 'car', this.onResult});

  final String current;
  final ValueChanged<String?>? onResult;

  @override
  State<TransportModeContent> createState() => _TransportModeContentState();
}

class _TransportModeContentState extends State<TransportModeContent> {
  static const _modes = [
    (id: 'car', icon: Icons.directions_car_rounded, label: 'Car'),
    (id: 'bus', icon: Icons.directions_bus_rounded, label: 'Public Transit'),
    (id: 'bicycle', icon: Icons.pedal_bike_rounded, label: 'Bicycle'),
    (id: 'scooter', icon: Icons.electric_scooter_rounded, label: 'Scooter'),
    (id: 'pedestrian', icon: Icons.directions_walk_rounded, label: 'Walking'),
  ];

  late String _selected;

  @override
  void initState() {
    super.initState();
    _selected = widget.current;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildHeader(),
        const Divider(height: 1, thickness: 0.5, color: AppColors.sub),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.only(top: 8, bottom: 48),
            physics: const BouncingScrollPhysics(),
            itemCount: _modes.length,
            itemBuilder: (_, i) => _buildModeTile(_modes[i]),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.only(left: 24, right: 16, top: 16, bottom: 16),
      child: Row(
        children: [
          const Expanded(
            child: Text(
              'Transportation',
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

  Widget _buildModeTile(({String id, IconData icon, String label}) mode) {
    final isSelected = mode.id == _selected;
    return _ModeTile(
      icon: mode.icon,
      label: mode.label,
      isSelected: isSelected,
      onTap: () {
        setState(() => _selected = mode.id);
        widget.onResult?.call(mode.id);
      },
    );
  }
}

class _ModeTile extends StatefulWidget {
  const _ModeTile({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  State<_ModeTile> createState() => _ModeTileState();
}

class _ModeTileState extends State<_ModeTile> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        curve: Curves.fastEaseInToSlowEaseOut,
        color: _pressed
            ? AppColors.textPrimary.withValues(alpha: 0.05)
            : Colors.transparent,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
        foregroundDecoration: const BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: AppColors.sub,
              width: 0.5,
              strokeAlign: BorderSide.strokeAlignInside,
            ),
          ),
        ),
        child: Row(
          children: [
            Icon(
              widget.icon,
              size: 22,
              color: widget.isSelected
                  ? AppColors.accent
                  : AppColors.textSecondary,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                widget.label,
                style: TextStyle(
                  fontFamily: AppFonts.normal,
                  fontSize: 16,
                  fontWeight: widget.isSelected
                      ? FontWeight.w600
                      : FontWeight.w500,
                  color: widget.isSelected
                      ? AppColors.textPrimary
                      : AppColors.textSecondary,
                ),
              ),
            ),
            if (widget.isSelected)
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
