import 'package:flutter/foundation.dart';

import 'package:consulting_fe/api/auth_service.dart';
import 'package:consulting_fe/services/device_service.dart';

class AuthProvider extends ChangeNotifier {
  bool _isInitializing = true;
  bool _isLoggedIn = false;

  bool get isInitializing => _isInitializing;
  bool get isLoggedIn => _isLoggedIn;

  Future<void> initialize() async {
    await AuthService.instance.loadFromStorage();
    _isInitializing = false;
    notifyListeners();
  }

  Future<void> initWithDevice() async {
    final deviceId = await DeviceService.getDeviceId();
    await AuthService.instance.authenticateWithDevice(deviceId);
    _isLoggedIn = true;
    _isInitializing = false;
    notifyListeners();
  }

  void setLoggedIn(bool value) {
    _isLoggedIn = value;
    notifyListeners();
  }

  Future<void> signOut() async {
    _isLoggedIn = false;
    notifyListeners();
  }

  void forceLogout() {
    _isLoggedIn = false;
    notifyListeners();
  }
}
