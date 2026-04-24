import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:consulting_fe/components/customs/cupertino_native-0.1.1/lib/cupertino_native.dart';
import 'package:consulting_fe/const/app_colors.dart';

bool get _isCupertino {
  if (kIsWeb) return false;
  return defaultTargetPlatform == TargetPlatform.iOS;
}

class PlatformToggle extends StatelessWidget {
  const PlatformToggle({
    super.key,
    required this.value,
    required this.onChanged,
    this.activeColor,
  });

  final bool value;
  final ValueChanged<bool> onChanged;
  final Color? activeColor;

  void _handleChanged(bool v) {
    HapticFeedback.selectionClick();
    onChanged(v);
  }

  @override
  Widget build(BuildContext context) {
    if (_isCupertino) {
      return CNSwitch(
        value: value,
        onChanged: _handleChanged,
        height: 28,
        color: activeColor,
      );
    }

    return SizedBox(
      height: 28,
      width: 46,
      child: FittedBox(
        fit: BoxFit.contain,
        child: Switch(
          value: value,
          onChanged: _handleChanged,
          activeColor: activeColor ?? AppColors.accent,
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
      ),
    );
  }
}
