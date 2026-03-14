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
  final DateTime endDate; // 챌린지 종료 날짜
  final int weeklyFrequency; // 주간 최소 인증 빈도
  final bool isStreak; // 연속 인증 중인지 여부

  const HomeChallengeCard({
    required this.challengeBase,
    required this.streakCount,
    required this.participantCount,
    required this.successParticipantCount,
    required this.warning,
    required this.isDone,
    required this.endDate,
    required this.weeklyFrequency,
    required this.isStreak,
  });

  factory HomeChallengeCard.fromJson(Map<String, dynamic> json) {
    return HomeChallengeCard(
      challengeBase: ChallengeBase.fromJson(json),
      streakCount: json['streak_count'] as int,
      participantCount: json['participant_count'] as int,
      successParticipantCount: json['success_participant_count'] as int,
      warning: json['warning'] as bool,
      isDone: json['is_done'] as bool,
      endDate: DateTime.parse(json['end_date'] as String),
      weeklyFrequency: json['weekly_frequency'] as int,
      isStreak: json['is_streak'] as bool,
    );
  }

  HomeChallengeCard copyWith({
    ChallengeBase? challengeBase,
    int? streakCount,
    int? participantCount,
    int? successParticipantCount,
    bool? warning,
    bool? isDone,
    DateTime? endDate,
    int? weeklyFrequency,
    bool? isStreak,
  }) {
    return HomeChallengeCard(
      challengeBase: challengeBase ?? this.challengeBase,
      streakCount: streakCount ?? this.streakCount,
      participantCount: participantCount ?? this.participantCount,
      successParticipantCount:
          successParticipantCount ?? this.successParticipantCount,
      warning: warning ?? this.warning,
      isDone: isDone ?? this.isDone,
      endDate: endDate ?? this.endDate,
      weeklyFrequency: weeklyFrequency ?? this.weeklyFrequency,
      isStreak: isStreak ?? this.isStreak,
    );
  }
}
