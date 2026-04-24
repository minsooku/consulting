import 'package:consulting_fe/api/client.dart';
import 'package:consulting_fe/api/models/fitness_models.dart';

class FitnessApi {
  FitnessApi._();
  static final instance = FitnessApi._();

  /// POST /test — Generate a multi-week AI fitness plan.
  Future<FitnessResponse> generatePlan(FitnessPrompt prompt) async {
    final data = await ApiClient.instance.post('/test', body: prompt.toJson());
    return FitnessResponse.fromJson(data as Map<String, dynamic>);
  }

  /// GET /health — Ping the server.
  Future<bool> healthCheck() async {
    try {
      final data = await ApiClient.instance.get('/health');
      return (data as Map<String, dynamic>)['ok'] == true;
    } catch (_) {
      return false;
    }
  }
}
