import 'package:consulting_fe/api/models/alarm_schedule_model.dart';

class AlarmSchedulesApi {
  AlarmSchedulesApi._();
  static final instance = AlarmSchedulesApi._();

  Future<List<AlarmScheduleModel>> getAll() async => [];
  Future<void> delete(int id) async {}
}
