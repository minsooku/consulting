class MathProblem {
  final String question;
  final int answer;
  final int? sessionId;
  const MathProblem({required this.question, required this.answer, this.sessionId});
}

class ShakeSession {
  final int id;
  final int targetCount;
  const ShakeSession({required this.id, required this.targetCount});
}

class PhotoReference {
  final int id;
  final String imageUrl;
  const PhotoReference({required this.id, required this.imageUrl});
}

class PhotoVerifyResult {
  final bool success;
  const PhotoVerifyResult({required this.success});
}
