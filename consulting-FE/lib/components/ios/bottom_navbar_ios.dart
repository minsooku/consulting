import 'package:consulting_fe/components/customs/cupertino_native-0.1.1/lib/components/tab_bar.dart';
import 'package:consulting_fe/components/customs/cupertino_native-0.1.1/lib/style/sf_symbol.dart';
import 'package:flutter/widgets.dart';
import 'package:consulting_fe/const/app_colors.dart';

class IosBottomNavBar extends StatelessWidget {
  const IosBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    return CNTabBar(
      tint: AppColors.mainPoint,
      backgroundColor: AppColors.background,
      items: [
        const CNTabBarItem(icon: CNSymbol('calendar')),
        const CNTabBarItem(icon: CNSymbol('figure.run')),
      ],
      currentIndex: currentIndex,
      onTap: onTap,
    );
  }
}
