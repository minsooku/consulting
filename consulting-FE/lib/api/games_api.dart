import 'package:consulting_fe/api/models/game_models.dart';

class GamesApi {
  GamesApi._();
  static final instance = GamesApi._();

  Future<MathProblem> getMathProblem() async =>
      const MathProblem(question: '2 + 2', answer: 4);

  Future<bool> verifyMathAnswer(int sessionId, int answer) async => false;

  Future<ShakeSession> startShakeSession() async => const ShakeSession(id: 0, targetCount: 20);

  Future<bool> completeShakeSession(int sessionId) async => false;

  Future<PhotoReference> getPhotoReference() async =>
      const PhotoReference(id: 0, imageUrl: '');

  Future<PhotoVerifyResult> verifyPhoto(int refId, String imagePath) async =>
      const PhotoVerifyResult(success: false);
}
