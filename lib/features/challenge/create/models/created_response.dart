import 'package:haenaem/shared/models/challenge_base.dart';
import 'package:haenaem/shared/models/user.dart';

class CreatedResponse extends ChallengeBase {
  final String challengeLink;

  const CreatedResponse({
    required super.id,
    required super.title,
    required this.challengeLink,
  });

  factory CreatedResponse.fromJson(Map<String, dynamic> json) {
    return CreatedResponse(
      // ChallengeBase 필드 (서버 원본 키 'id' 사용)
      id: json['id'] as int? ?? 0,
      title: json['title'] as String? ?? '',

      // CreatedResponse 전용 필드
      challengeLink: json['challengeLink'] as String? ?? '',
    );
  }
}
