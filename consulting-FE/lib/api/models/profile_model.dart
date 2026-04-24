class ProfileModel {
  final String name;
  final int? prepTimeMinutes;
  final String? transportMode;

  const ProfileModel({
    required this.name,
    this.prepTimeMinutes,
    this.transportMode,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) => ProfileModel(
        name: json['name'] as String? ?? '',
        prepTimeMinutes: json['prep_time_minutes'] as int?,
        transportMode: json['transport_mode'] as String?,
      );
}
