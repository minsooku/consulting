import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import 'package:consulting_fe/components/android/bottom_navbar_android.dart';
import 'package:consulting_fe/components/ios/bottom_navbar_ios.dart';

class PlatformNavBar extends StatelessWidget {
  const PlatformNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;

  bool get _isCupertino {
    if (kIsWeb) {
      return false;
    }
    return defaultTargetPlatform == TargetPlatform.iOS;
  }

  @override
  Widget build(BuildContext context) {
    if (_isCupertino) {
      return IosBottomNavBar(
        currentIndex: currentIndex,
        onTap: onTap,
      );
    }

    return AndroidBottomNavBar(
      currentIndex: currentIndex,
      onTap: onTap,
    );
  }
}
