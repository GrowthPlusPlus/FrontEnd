// 최초 작성자: 김채영
import 'package:haenaem/shared/models/tag_model.dart';

// AI 추천 챌린지 카드 1개
class RecommendedChallengeItem {
  final int challengeId;
  final String title;
  final int participantNumber;
  final int requiredWeeklyCount;
  final int remainingDays;
  final bool photoRequired;
  final List<ChallengeTagModel> tags;
  final String recommendReason;

  const RecommendedChallengeItem({
    required this.challengeId,
    required this.title,
    required this.participantNumber,
    required this.requiredWeeklyCount,
    required this.remainingDays,
    required this.photoRequired,
    required this.tags,
    required this.recommendReason,
  });

  factory RecommendedChallengeItem.fromJson(Map<String, dynamic> json) {
    final challenge = json['challenge'] as Map<String, dynamic>;
    return RecommendedChallengeItem(
      challengeId: challenge['challengeId'] as int,
      title: challenge['title'] as String,
      participantNumber: challenge['participantNumber'] as int,
      requiredWeeklyCount: challenge['requiredWeeklyCount'] as int,
      remainingDays: challenge['remainingDays'] as int,
      photoRequired: challenge['photoRequired'] as bool,
      tags: (challenge['tags'] as List? ?? [])
          .map((t) => ChallengeTagModel.fromJson(t as Map<String, dynamic>))
          .toList(),
      recommendReason: json['recommendReason'] as String? ?? '',
    );
  }

  /// UI용 보조 문구 (API에 없는 description/detail 대체)
  String get subtitle =>
      '주 $requiredWeeklyCount회 인증' + (photoRequired ? ' · 사진 인증 필요' : '');
}

/// combined API 전체 응답 (서술 요약 + 카드 리스트)
class RecommendedChallengeResponse {
  final String summary;
  final List<RecommendedChallengeItem> challenges;

  const RecommendedChallengeResponse({
    required this.summary,
    required this.challenges,
  });

  factory RecommendedChallengeResponse.fromJson(Map<String, dynamic> json) {
    return RecommendedChallengeResponse(
      summary: json['summary'] as String? ?? '',
      challenges: (json['challenges'] as List? ?? [])
          .map(
            (e) => RecommendedChallengeItem.fromJson(e as Map<String, dynamic>),
          )
          .toList(),
    );
  }
}
