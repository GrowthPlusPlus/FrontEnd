import 'package:haenaem/shared/models/home_challenge_card.dart';

// 최초 작성자: 강선욱
// 마이페이지 챌린지 카드 모델
// HomeChallengeCard에 정의된 필드를 challengeInfo로 재사용

enum ChallengeStatus {
  inProgress, // 진행중
  completed, // 완료
  failed, // 실패
}

class MyPageChallengeCard {
  final HomeChallengeCard challengeInfo; // 챌린지 기본 정보
  final double rate; // 챌린지 달성률
  final ChallengeStatus status; // 챌린지 상태
  final DateTime? failedDate; // 챌린지 실패 날짜
  final int maxStreakCount; // 최고 연속 일수
  final bool isParticipated; // 참여중 여부

  const MyPageChallengeCard({
    required this.challengeInfo,
    required this.rate,
    required this.status,
    this.failedDate,
    required this.maxStreakCount,
    required this.isParticipated,
  });

  factory MyPageChallengeCard.fromJson(Map<String, dynamic> json) {
    return MyPageChallengeCard(
      challengeInfo: HomeChallengeCard.fromJson(json),
      rate: (json['rate'] as num).toDouble(),
      status: ChallengeStatus.values.byName(json['status'] as String),
      failedDate: json['failed_date'] != null
          ? DateTime.parse(json['failed_date'] as String)
          : null,
      maxStreakCount: json['max_streak_count'] as int,
      isParticipated: json['is_participated'] as bool,
    );
  }

  MyPageChallengeCard copyWith({
    HomeChallengeCard? challengeInfo,
    double? rate,
    ChallengeStatus? status,
    DateTime? failedDate,
    int? maxStreakCount,
    bool? isParticipated,
  }) {
    return MyPageChallengeCard(
      challengeInfo: challengeInfo ?? this.challengeInfo,
      rate: rate ?? this.rate,
      status: status ?? this.status,
      failedDate: failedDate ?? this.failedDate,
      maxStreakCount: maxStreakCount ?? this.maxStreakCount,
      isParticipated: isParticipated ?? this.isParticipated,
    );
  }
}
