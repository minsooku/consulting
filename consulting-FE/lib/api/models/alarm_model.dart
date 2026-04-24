import 'package:consulting_fe/api/models/location_model.dart';

class TripModel {
  final String date;
  final int weekday;
  final int? predictedMinutes;
  final int? actualMinutes;
  final int? freeFlowMinutes;
  final String? trafficStatus;
  final int? savedVsPrediction;
  final int? savedVsFreeflow;

  const TripModel({
    required this.date,
    required this.weekday,
    this.predictedMinutes,
    this.actualMinutes,
    this.freeFlowMinutes,
    this.trafficStatus,
    this.savedVsPrediction,
    this.savedVsFreeflow,
  });

  factory TripModel.fromJson(Map<String, dynamic> json) => TripModel(
        date: json['date'] as String? ?? '',
        weekday: json['weekday'] as int? ?? 0,
        predictedMinutes: json['predicted_minutes'] as int?,
        actualMinutes: json['actual_minutes'] as int?,
        freeFlowMinutes: json['free_flow_minutes'] as int?,
        trafficStatus: json['traffic_status'] as String?,
        savedVsPrediction: json['saved_vs_prediction'] as int?,
        savedVsFreeflow: json['saved_vs_freeflow'] as int?,
      );
}

class AlarmModel {
  final int id;
  final DateTime targetArrivalTime;
  final String status;
  final LocationModel? origin;
  final LocationModel? destination;
  final String? transportMode;
  final DateTime? wakeUpTime;
  final DateTime? estimatedDepartureTime;
  final int? predictedTravelMinutes;
  final DateTime createdAt;

  const AlarmModel({
    required this.id,
    required this.targetArrivalTime,
    required this.status,
    this.origin,
    this.destination,
    this.transportMode,
    this.wakeUpTime,
    this.estimatedDepartureTime,
    this.predictedTravelMinutes,
    required this.createdAt,
  });

  factory AlarmModel.fromJson(Map<String, dynamic> json) => AlarmModel(
        id: json['id'] as int,
        targetArrivalTime:
            DateTime.parse(json['target_arrival_time'] as String),
        status: json['status'] as String? ?? 'pending',
        origin: json['origin'] != null
            ? LocationModel.fromJson(json['origin'] as Map<String, dynamic>)
            : null,
        destination: json['destination'] != null
            ? LocationModel.fromJson(
                json['destination'] as Map<String, dynamic>)
            : null,
        transportMode: json['transport_mode'] as String?,
        wakeUpTime: json['wake_up_time'] != null
            ? DateTime.parse(json['wake_up_time'] as String)
            : null,
        estimatedDepartureTime: json['estimated_departure_time'] != null
            ? DateTime.parse(json['estimated_departure_time'] as String)
            : null,
        predictedTravelMinutes: json['predicted_travel_minutes'] as int?,
        createdAt: json['created_at'] != null
            ? DateTime.parse(json['created_at'] as String)
            : DateTime.now(),
      );
}

class AlarmHistoryItem {
  final AlarmModel alarm;
  final DateTime? triggeredAt;
  final TripModel? trip;

  const AlarmHistoryItem({
    required this.alarm,
    this.triggeredAt,
    this.trip,
  });
}
