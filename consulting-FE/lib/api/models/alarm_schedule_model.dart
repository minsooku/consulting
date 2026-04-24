class AlarmScheduleModel {
  final int id;
  final int weekday;
  final String arrivalTime;
  final bool enabled;

  const AlarmScheduleModel({
    required this.id,
    required this.weekday,
    required this.arrivalTime,
    required this.enabled,
  });

  factory AlarmScheduleModel.fromJson(Map<String, dynamic> json) =>
      AlarmScheduleModel(
        id: json['id'] as int,
        weekday: json['weekday'] as int,
        arrivalTime: json['arrival_time'] as String,
        enabled: json['enabled'] as bool,
      );
}
