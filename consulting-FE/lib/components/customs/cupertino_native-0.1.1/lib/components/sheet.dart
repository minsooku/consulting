import 'package:flutter/services.dart';

import '../style/sheet_detent.dart';

/// Presents a **native** iOS bottom sheet (`UISheetPresentationController`)
/// whose content is rendered by a secondary Flutter engine.
///
/// On the native side the entry-point `sheetMain` is launched in a new
/// `FlutterEngine` (via `FlutterEngineGroup`).  The [route] name and
/// [arguments] are forwarded to that engine so the `CNSheetApp` running
/// inside it can build the correct content widget.
///
/// Returns the result passed to [close], or `null` if dismissed by gesture.
class CNSheet {
  CNSheet._();

  static const _channel = MethodChannel('cupertino_native_sheet');

  /// Show a native iOS sheet.
  ///
  /// * [route] – named route that the secondary engine's `CNSheetApp` will
  ///   resolve to a widget builder.
  /// * [arguments] – serialisable data forwarded to the builder.
  /// * [detents] – allowed sheet heights (default medium + large).
  /// * [initialDetent] – starting height.
  /// * [showDragHandle] – whether the native grabber is visible.
  /// * [dismissible] – whether the user can swipe to dismiss.
  /// * [cornerRadius] – override the default sheet corner radius.
  static Future<T?> show<T>({
    required String route,
    Map<String, dynamic>? arguments,
    List<CNSheetDetent> detents = const [
      CNSheetDetent.medium,
      CNSheetDetent.large,
    ],
    CNSheetDetent initialDetent = CNSheetDetent.medium,
    bool showDragHandle = true,
    bool dismissible = true,
    double? cornerRadius,
  }) async {
    final result = await _channel.invokeMethod<dynamic>('showSheet', {
      'route': route,
      'arguments': arguments ?? <String, dynamic>{},
      'detents': detents.map((d) => d.name).toList(),
      'initialDetent': initialDetent.name,
      'showDragHandle': showDragHandle,
      'dismissible': dismissible,
      if (cornerRadius != null) 'cornerRadius': cornerRadius,
    });
    return result as T?;
  }

  /// Pre-spawn the secondary Flutter engine so the first [show] call is
  /// nearly instant.  Safe to call on every app boot – subsequent calls
  /// are no-ops while a warmed engine exists.
  static Future<void> warmUp() async {
    await _channel.invokeMethod<void>('warmUp');
  }

  /// Programmatically dismiss the currently-presented native sheet,
  /// optionally returning a [result] to the caller of [show].
  static Future<void> close([dynamic result]) async {
    await _channel.invokeMethod('closeSheet', {
      if (result != null) 'result': result,
    });
  }
}
