import 'package:flutter/material.dart';

class AppFonts {
  static const String family = 'NanumSquareRound';

  // Convenience aliases — use with TextStyle(fontFamily: AppFonts.family, fontWeight: ...)
  static const String light = family;   // w300
  static const String normal = family;  // w400
  static const String bold = family;    // w700
  static const String round = family;   // w800 (ExtraBold)

  // Predefined TextStyle shortcuts
  static const TextStyle lightStyle = TextStyle(
    fontFamily: family,
    fontWeight: FontWeight.w300,
  );
  static const TextStyle normalStyle = TextStyle(
    fontFamily: family,
    fontWeight: FontWeight.w400,
  );
  static const TextStyle boldStyle = TextStyle(
    fontFamily: family,
    fontWeight: FontWeight.w700,
  );
  static const TextStyle extraBoldStyle = TextStyle(
    fontFamily: family,
    fontWeight: FontWeight.w800,
  );
}
