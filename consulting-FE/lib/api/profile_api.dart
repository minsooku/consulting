import 'package:consulting_fe/api/models/profile_model.dart';

class ProfileApi {
  ProfileApi._();
  static final instance = ProfileApi._();

  Future<ProfileModel> get() async => const ProfileModel(name: '');
  Future<ProfileModel> update({
    int? prepTimeMinutes,
    String? transportMode,
    String? name,
  }) async => ProfileModel(name: name ?? '');
}
