import 'package:consulting_fe/api/models/location_model.dart';

class LocationsApi {
  LocationsApi._();
  static final instance = LocationsApi._();

  Future<LocationModel> save({
    required String locationType,
    required String hereId,
    required String label,
  }) async => LocationModel(id: 0, locationType: locationType, hereId: hereId, label: label);

  Future<List<LocationModel>> getAll() async => [];
}
