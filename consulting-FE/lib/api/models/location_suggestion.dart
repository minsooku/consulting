class LocationSuggestion {
  final String hereId;
  final String label;
  final String? address;

  const LocationSuggestion({
    required this.hereId,
    required this.label,
    this.address,
  });

  factory LocationSuggestion.fromJson(Map<String, dynamic> json) =>
      LocationSuggestion(
        hereId: json['here_id'] as String,
        label: json['label'] as String,
        address: json['address'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'here_id': hereId,
        'label': label,
        if (address != null) 'address': address,
      };
}
