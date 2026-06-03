import 'package:haenaem/shared/models/home_challenge_card.dart';

// 최초 작성자: 강선욱
// 마이페이지 챌린지 카드 모델
// HomeChallengeCard에 정의된 필드를 challengeInfo로 재사용

enum ChallengeStatus {
  inProgress, // 진행중
  success, // 완료
  fail, // 실패
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
      // 홈탭 모델의 팩토리 메서드를 그대로 호출
      challengeInfo: HomeChallengeCard.fromJson(json),

      // 마이페이지 전용 필드들만 추가로 매핑
      rate: (json['achievementRate'] as num? ?? 0).toDouble(),
      status: _mapStatus(json['status'] as String? ?? ''),
      failedDate: json['endDate'] != null
          ? DateTime.tryParse(json['endDate'])
          : null,
      maxStreakCount: json['currentStreak'] as int? ?? 0, // max를 현재 스트리크로 우선 매핑
      isParticipated: true,
    );
  }

  // 상태 값(SUCCESS, FAIL 등)을 Enum으로 안전하게 변환하는 헬퍼
  static ChallengeStatus _mapStatus(String raw) {
    switch (raw.toUpperCase()) {
      case 'SUCCESS':
        return ChallengeStatus.success;
      case 'FAIL':
        return ChallengeStatus.fail;
      default:
        return ChallengeStatus.inProgress;
    }
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
