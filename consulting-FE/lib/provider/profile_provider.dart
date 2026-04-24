import 'package:flutter/foundation.dart';
import 'package:consulting_fe/api/profile_api.dart';
import 'package:consulting_fe/api/models/profile_model.dart';

class ProfileProvider extends ChangeNotifier {
  ProfileModel? _profile;
  bool _loading = false;
  String? _error;
  DateTime? _lastFetched;
  Future<void>? _pendingUpdate;

  static const _cacheExpiry = Duration(minutes: 10);

  ProfileModel? get profile => _profile;
  bool get loading => _loading;
  String? get error => _error;

  String get name => _profile?.name ?? '';
  bool get hasName => (_profile?.name ?? '').isNotEmpty;
  int get prepTimeMinutes => _profile?.prepTimeMinutes ?? 40;
  String get transportMode => _profile?.transportMode ?? 'car';

  bool get _cacheValid =>
      _lastFetched != null &&
      DateTime.now().difference(_lastFetched!) < _cacheExpiry;

  Future<void> load({bool force = false}) async {
    if (!force && _cacheValid && _profile != null) return;
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      _profile = await ProfileApi.instance.get();
      _lastFetched = DateTime.now();
    } catch (e) {
      _error = e.toString();
    }
    _loading = false;
    notifyListeners();
  }

  Future<void> update({
    int? prepTimeMinutes,
    String? transportMode,
    String? name,
  }) async {
    final future = _doUpdate(
      prepTimeMinutes: prepTimeMinutes,
      transportMode: transportMode,
      name: name,
    );
    _pendingUpdate = future;
    await future;
    if (_pendingUpdate == future) _pendingUpdate = null;
  }

  Future<void> _doUpdate({
    int? prepTimeMinutes,
    String? transportMode,
    String? name,
  }) async {
    try {
      _profile = await ProfileApi.instance.update(
        prepTimeMinutes: prepTimeMinutes,
        transportMode: transportMode,
        name: name,
      );
      _lastFetched = DateTime.now();
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> waitForPendingUpdates() async {
    if (_pendingUpdate != null) await _pendingUpdate;
  }

  void clear() {
    _profile = null;
    _lastFetched = null;
    _error = null;
    notifyListeners();
  }
}
