/// Detent sizes for [CNSheet].
///
/// Maps directly to `UISheetPresentationController.Detent` on iOS 15+.
/// Custom fractional detents require iOS 16+; on iOS 15 they fall back to
/// the nearest standard detent.
class CNSheetDetent {
  final String name;
  const CNSheetDetent._(this.name);

  /// Approximately half-screen height.
  static const medium = CNSheetDetent._('medium');

  /// Full-screen height.
  static const large = CNSheetDetent._('large');

  /// Custom fractional height (0.0–1.0). Requires iOS 16+.
  factory CNSheetDetent.custom(double fraction) {
    assert(fraction > 0 && fraction <= 1.0);
    return CNSheetDetent._('custom:${fraction.toStringAsFixed(2)}');
  }
}
