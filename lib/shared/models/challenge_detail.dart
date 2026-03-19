import 'package:haenaem/shared/models/challenge_base.dart';
import 'package:haenaem/shared/models/user.dart';

// 최초 작성자: 강선욱
// 챌린지 상세 모델
// ChallengeBase에 정의된 필드(id, title, isLeader)를 재사용
// User 모델을 방장(host), 오늘 인증한 유저 리스트(todaySuccessUsers)에 재사용
class ChallengeDetail {
  final ChallengeBase challengeBase; // 챌린지 기본 정보 (id, title, isLeader)
  final DateTime startDate; // 챌린지 시작 날짜
  final DateTime endDate; // 챌린지 종료 날짜
  final int weeklyFrequency; // 주간 최소 인증 빈도
  final bool photoRequired; // 사진 인증 필요 여부
  final List<String> tags; // 챌린지 태그 리스트
  final String description; // 챌린지 설명
  final User leader; // 방장 정보 (id, profileUrl, nickname)
  final int participantCount; // 참여자 수
  final List<User> todaySuccessUsers; // 오늘 인증 완료한 유저 리스트

  const ChallengeDetail({
    required this.challengeBase,
    required this.startDate,
    required this.endDate,
    required this.weeklyFrequency,
    required this.photoRequired,
    required this.tags,
    required this.description,
    required this.leader,
    required this.participantCount,
    required this.todaySuccessUsers,
  });

  factory ChallengeDetail.fromJson(Map<String, dynamic> json) {
    return ChallengeDetail(
      challengeBase: ChallengeBase.fromJson(json),
      startDate: DateTime.parse(json['start_date'] as String),
      endDate: DateTime.parse(json['end_date'] as String),
      weeklyFrequency: json['weekly_frequency'] as int,
      photoRequired: json['photo_required'] as bool,
      tags: List<String>.from(json['tags'] as List),
      description: json['description'] as String,
      leader: User.fromJson(json['host'] as Map<String, dynamic>),
      participantCount: json['participant_count'] as int,
      todaySuccessUsers: (json['today_success_users'] as List)
          .map((e) => User.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  ChallengeDetail copyWith({
    ChallengeBase? challengeBase,
    DateTime? startDate,
    DateTime? endDate,
    int? weeklyFrequency,
    bool? photoRequired,
    List<String>? tags,
    String? description,
    User? leader,
    int? participantCount,
    List<User>? todaySuccessUsers,
  }) {
    return ChallengeDetail(
      challengeBase: challengeBase ?? this.challengeBase,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      weeklyFrequency: weeklyFrequency ?? this.weeklyFrequency,
      photoRequired: photoRequired ?? this.photoRequired,
      tags: tags ?? this.tags,
      description: description ?? this.description,
      leader: leader ?? this.leader,
      participantCount: participantCount ?? this.participantCount,
      todaySuccessUsers: todaySuccessUsers ?? this.todaySuccessUsers,
    );
  }
}
