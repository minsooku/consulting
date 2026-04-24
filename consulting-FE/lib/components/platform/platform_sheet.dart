import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:consulting_fe/components/customs/cupertino_native-0.1.1/lib/cupertino_native.dart';
import 'package:consulting_fe/const/app_colors.dart';

/// Cross-platform bottom sheet that delegates to the **native**
/// `UISheetPresentationController` on iOS and falls back to a
/// `PageRouteBuilder`-based sheet (matching smooth_sheets style) on Android.
///
/// ```dart
/// await PlatformSheet.show(
///   context: context,
///   route: 'history',
///   builder: (ctx) => const HistoryContent(),
///   detents: [CNSheetDetent.medium, CNSheetDetent.large],
/// );
/// ```
class PlatformSheet {
  PlatformSheet._();

  /// `true` when the platform uses the native iOS sheet presenter.
  static bool get isNative {
    if (kIsWeb) return false;
    return defaultTargetPlatform == TargetPlatform.iOS ||
        defaultTargetPlatform == TargetPlatform.macOS;
  }

  /// Pre-warm the native sheet engine so the first [show] is instant.
  /// No-op on non-Apple platforms.
  static Future<void> warmUp() async {
    if (!isNative) return;
    await CNSheet.warmUp();
  }

  static bool get _isApple => isNative;

  /// Show a platform-appropriate bottom sheet.
  ///
  /// [fromResult] – optional mapper that converts the raw MethodChannel result
  /// (always JSON-serialisable on iOS) back into the expected Dart type [T].
  /// Only needed when [T] is not a primitive (String, int, bool, Map).
  static Future<T?> show<T>({
    required BuildContext context,
    required String route,
    required Widget Function(BuildContext) builder,
    Map<String, dynamic>? arguments,
    List<CNSheetDetent> detents = const [
      CNSheetDetent.medium,
      CNSheetDetent.large,
    ],
    CNSheetDetent initialDetent = CNSheetDetent.medium,
    bool showDragHandle = true,
    bool dismissible = true,
    double? cornerRadius,
    T Function(dynamic raw)? fromResult,
  }) {
    if (_isApple) {
      return CNSheet.show<dynamic>(
        route: route,
        arguments: arguments,
        detents: detents,
        initialDetent: initialDetent,
        showDragHandle: showDragHandle,
        dismissible: dismissible,
        cornerRadius: cornerRadius,
      ).then((raw) {
        if (raw == null) return null;
        if (fromResult != null) return fromResult(raw);
        return raw as T?;
      });
    }

    return _showFlutterSheet<T>(
      context: context,
      builder: builder,
      detents: detents,
      initialDetent: initialDetent,
      showDragHandle: showDragHandle,
      dismissible: dismissible,
      cornerRadius: cornerRadius,
    );
  }

  /// Programmatically close the current sheet.
  ///
  /// On iOS delegates to the native presenter; on other platforms pops the
  /// Navigator.
  static Future<void> close<T>(BuildContext context, [T? result]) async {
    if (_isApple) {
      await CNSheet.close(result);
    } else {
      Navigator.of(context).pop(result);
    }
  }

  // ---------------------------------------------------------------------------
  // Flutter fallback (Android / web) — matches smooth_sheets visual style
  // ---------------------------------------------------------------------------

  static Future<T?> _showFlutterSheet<T>({
    required BuildContext context,
    required Widget Function(BuildContext) builder,
    required List<CNSheetDetent> detents,
    required CNSheetDetent initialDetent,
    required bool showDragHandle,
    required bool dismissible,
    double? cornerRadius,
  }) {
    return Navigator.of(context, rootNavigator: true).push<T>(
      PageRouteBuilder<T>(
        opaque: false,
        barrierColor: Colors.black54,
        barrierDismissible: dismissible,
        transitionDuration: const Duration(milliseconds: 400),
        reverseTransitionDuration: const Duration(milliseconds: 300),
        pageBuilder: (_, _, _) => Scaffold(
          backgroundColor: Colors.transparent,
          body: SafeArea(
            bottom: false,
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(cornerRadius ?? 24),
                ),
              ),
              clipBehavior: Clip.antiAlias,
              child: builder(context),
            ),
          ),
        ),
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
