class LocationModel {
  final int id;
  final String locationType;
  final String hereId;
  final String label;

  const LocationModel({
    required this.id,
    required this.locationType,
    required this.hereId,
    required this.label,
  });

  factory LocationModel.fromJson(Map<String, dynamic> json) => LocationModel(
        id: json['id'] as int,
        locationType: json['location_type'] as String,
        hereId: json['here_id'] as String,
        label: json['label'] as String,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'location_type': locationType,
        'here_id': hereId,
        'label': label,
      };
}
