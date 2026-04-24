class AuthService {
  AuthService._();
  static final instance = AuthService._();

  String? _deviceId;
  String? get deviceId => _deviceId;

  Future<void> loadFromStorage() async {}

  Future<void> authenticateWithDevice(String deviceId) async {
    _deviceId = deviceId;
    // TODO: call backend API with deviceId
    // e.g. await ApiClient.instance.post('/auth/device', body: {'device_id': deviceId});
  }
}
