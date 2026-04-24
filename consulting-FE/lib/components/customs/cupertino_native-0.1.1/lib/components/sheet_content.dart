import 'package:flutter/services.dart';
import '../style/sheet_detent.dart';

/// API for widgets running inside the **secondary** Flutter engine spawned by
/// the native sheet presenter.
///
/// Unlike [CNSheet] (which communicates via the main-engine channel), this
/// class sends messages on `cupertino_native_sheet_content` — the channel
/// that the native side listens to on the secondary engine's messenger.
class CNSheetContent {
  CNSheetContent._();

  static const _channel = MethodChannel('cupertino_native_sheet_content');

  /// Dismiss the native sheet, optionally returning [result] to the caller.
  static Future<void> close([dynamic result]) async {
    await _channel.invokeMethod('closeSheet', {
      if (result != null) 'result': result,
    });
  }

  /// Animate the native sheet to a different detent.
  static Future<void> setDetent(CNSheetDetent detent) async {
    await _channel.invokeMethod('setDetent', {
      'detent': detent.name,
    });
  }

  /// Lock or unlock swipe-to-dismiss on the native iOS sheet.
  ///
  /// Call with [locked]=true while the sheet's scroll view is scrolled down
  /// (not at the top) so that downward flings scroll the list rather than
  /// triggering the sheet dismiss gesture.
  static Future<void> setScrollLocked(bool locked) async {
    await _channel.invokeMethod('setScrollLocked', {'locked': locked});
  }
}
