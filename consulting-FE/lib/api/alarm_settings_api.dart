enum ClockPosition { center, topLeft, topCenter, topRight, bottomLeft, bottomCenter, bottomRight, custom }
enum ClockStyle { thin, bold, minimal }

String alignmentToClockPositionName(double ax, double ay) => 'center';

class AlarmSettingsApi {
  AlarmSettingsApi._();
  static final instance = AlarmSettingsApi._();

  Future<void> save({
    required String alarmSound,
    required String clockPosition,
    required double clockAlignmentX,
    required double clockAlignmentY,
    int? wallpaperPresetId,
  }) async {}
}
