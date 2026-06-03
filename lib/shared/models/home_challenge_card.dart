import 'challenge_base.dart';

// 최초 작성자: 강선욱
// 홈 화면 챌린지 카드 모델
// ChallengeBase에 정의된 필드(id, title, isLeader)를 토대로 홈 화면에서 필요한 데이터로 구성
class HomeChallengeCard {
  final ChallengeBase challengeBase; // id, title, isLeader
  final int streakCount; // 최근 인증 연속 일수
  final int participantCount; // 참여 인원 수
  final int successParticipantCount; // 인증 완료 인원 수
  final bool warning; // 챌린지 실패 여부
  final bool isDone; // 오늘 인증 완료 여부
  final int dDay; // 챌린지 종료까지 남은 날짜
  final int weeklyFrequency; // 주간 최소 인증 빈도

  const HomeChallengeCard({
    required this.challengeBase,
    required this.streakCount,
    required this.participantCount,
    required this.successParticipantCount,
    required this.warning,
    required this.isDone,
    required this.dDay,
    required this.weeklyFrequency,
  });

  factory HomeChallengeCard.fromJson(Map<String, dynamic> json) {
    return HomeChallengeCard(
      challengeBase: ChallengeBase.fromJson(json),
      streakCount: json['currentStreak'] as int? ?? 0,
      participantCount: json['participantNumber'] as int? ?? 0,
      successParticipantCount: json['todaySuccessCount'] as int? ?? 0,
      warning: json['warning'] as bool? ?? false,
      isDone: json['doIt'] as bool? ?? false,
      dDay: json['dueToDate'] as int? ?? 0,
      weeklyFrequency: json['requiredWeeklyCount'] as int? ?? 0,
    );
  }

  HomeChallengeCard copyWith({
    ChallengeBase? challengeBase,
    int? streakCount,
    int? participantCount,
    int? successParticipantCount,
    bool? warning,
    bool? isDone,
    int? dDay,
    int? weeklyFrequency,
  }) {
    return HomeChallengeCard(
      challengeBase: challengeBase ?? this.challengeBase,
      streakCount: streakCount ?? this.streakCount,
      participantCount: participantCount ?? this.participantCount,
      successParticipantCount:
          successParticipantCount ?? this.successParticipantCount,
      warning: warning ?? this.warning,
      isDone: isDone ?? this.isDone,
      dDay: dDay ?? this.dDay,
      weeklyFrequency: weeklyFrequency ?? this.weeklyFrequency,
    );
  }
}
