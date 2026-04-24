import 'package:consulting_fe/api/models/alarm_model.dart';

class AlarmsApi {
  AlarmsApi._();
  static final instance = AlarmsApi._();

  Future<void> create({
    required String targetArrivalTime,
    required int originId,
    required int destinationId,
    required String transportMode,
    bool silent = false,
  }) async {}

  Future<List<AlarmHistoryItem>> getHistory() async => [];
}
