import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:smooth_sheets/smooth_sheets.dart';

import 'package:consulting_fe/components/platform/platform_navbar.dart';
import 'package:consulting_fe/const/app_colors.dart';
import 'package:consulting_fe/pages/main/alarmpage.dart';
import 'package:consulting_fe/pages/main/missionpage.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key, this.fromOnboarding = false});

  final bool fromOnboarding;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with WidgetsBindingObserver {
  int _currentIndex = 0;
  bool _searchActive = false;

  bool get _hideNavBar => _searchActive;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  List<Widget> get _pages => <Widget>[
    AlarmPage(
      isActive: _currentIndex == 0,
      onSearchActiveChanged: (active) => setState(() => _searchActive = active),
      fromOnboarding: widget.fromOnboarding,
    ),
    const MissionPage(),
  ];

  static const List<String> _titles = <String>['Agenda', 'Weekly'];

  bool get _isCupertino {
    if (kIsWeb) return false;
    return defaultTargetPlatform == TargetPlatform.iOS;
  }

  @override
  Widget build(BuildContext context) {
    return DefaultSheetController(
      child: _isCupertino
          ? _buildCupertino()
          : _buildMaterial(),
    );
  }

  Widget _buildCupertino() {
    return _CupertinoScaffoldPlaceholder(
      title: _titles[_currentIndex],
      pages: _pages,
      currentIndex: _currentIndex,
      hideNavBar: _hideNavBar,
      onTap: (index) => setState(() => _currentIndex = index),
    );
  }

  Widget _buildMaterial() {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _pages),
      bottomNavigationBar: Builder(
        builder: (ctx) {
          final navBar = PlatformNavBar(
            currentIndex: _currentIndex,
            onTap: (index) => setState(() => _currentIndex = index),
          );

          final Animation<Offset> slideAnim;
          if (_hideNavBar) {
            slideAnim = const AlwaysStoppedAnimation(Offset(0, 1));
          } else if (_currentIndex == 0) {
            slideAnim = SheetOffsetDrivenAnimation(
              controller: DefaultSheetController.of(ctx),
              initialValue: 1,
            ).drive(Tween(begin: const Offset(0, 1), end: Offset.zero));
          } else {
            slideAnim = const AlwaysStoppedAnimation(Offset.zero);
          }

          return SlideTransition(position: slideAnim, child: navBar);
        },
      ),
    );
  }
}

class _CupertinoScaffoldPlaceholder extends StatelessWidget {
  const _CupertinoScaffoldPlaceholder({
    required this.title,
    required this.pages,
    required this.currentIndex,
    required this.hideNavBar,
    required this.onTap,
  });

  final String title;
  final List<Widget> pages;
  final int currentIndex;
  final bool hideNavBar;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        top: true,
        bottom: false,
        child: Stack(
          children: [
            IndexedStack(index: currentIndex, children: pages),
            Align(
              alignment: Alignment.bottomCenter,
              child: Builder(
                builder: (ctx) {
                  final navBar = PlatformNavBar(
                    currentIndex: currentIndex,
                    onTap: onTap,
                  );

                  final Animation<Offset> slideAnim;
                  if (hideNavBar) {
                    slideAnim = const AlwaysStoppedAnimation(Offset(0, 1));
                  } else if (currentIndex == 0) {
                    slideAnim = SheetOffsetDrivenAnimation(
                      controller: DefaultSheetController.of(ctx),
                      initialValue: 1,
                    ).drive(Tween(begin: const Offset(0, 1), end: Offset.zero));
                  } else {
                    slideAnim = const AlwaysStoppedAnimation(Offset.zero);
                  }

                  return SlideTransition(position: slideAnim, child: navBar);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
