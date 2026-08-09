// 최초 작성자: 김채영
class ChallengePreviewResponse {
  final bool autoVerifiable;
  final String? category;

  const ChallengePreviewResponse({required this.autoVerifiable, this.category});

  factory ChallengePreviewResponse.fromJson(Map<String, dynamic> json) {
    return ChallengePreviewResponse(
      autoVerifiable: json['autoVerifiable'] as bool? ?? false,
      category: json['category'] as String?,
    );
  }
}
