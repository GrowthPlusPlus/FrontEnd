// 최초 작성자: 김채영
class ChallengePreviewResponse {
  final bool autoVerifiable;

  const ChallengePreviewResponse({required this.autoVerifiable});

  factory ChallengePreviewResponse.fromJson(Map<String, dynamic> json) {
    return ChallengePreviewResponse(
      autoVerifiable: json['autoVerifiable'] as bool? ?? false,
    );
  }
}
