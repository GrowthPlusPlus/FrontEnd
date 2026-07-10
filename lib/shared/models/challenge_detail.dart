import 'package:haenaem/shared/models/challenge_base.dart';
import 'package:haenaem/shared/models/user.dart';

// 최초 작성자: 강선욱
// 챌린지 상세 모델
// ChallengeBase에 정의된 필드(id, title, isLeader)를 재사용
// User 모델을 방장(host), 오늘 인증한 유저 리스트(todaySuccessUsers)에 재사용
class ChallengeDetail {
  final DateTime startDate; // 챌린지 시작 날짜
  final DateTime endDate; // 챌린지 종료 날짜
  final int weeklyFrequency; // 주간 최소 인증 빈도
  final bool photoRequired; // 사진 인증 필요 여부
  final List<String> tags; // 챌린지 태그 리스트
  final String description; // 챌린지 설명
  final User leader; // 방장 정보 (id, profileUrl, nickname)
  final int participantCount; // 참여자 수
  final List<User> todaySuccessUsers; // 오늘 인증 완료한 유저 리스트
  final DateTime? joinDate;

  const ChallengeDetail({
    required this.startDate,
    required this.endDate,
    required this.weeklyFrequency,
    required this.photoRequired,
    required this.tags,
    required this.description,
    required this.leader,
    required this.participantCount,
    required this.todaySuccessUsers,
    this.joinDate,
  });

  factory ChallengeDetail.fromJson(Map<String, dynamic> json) {
    return ChallengeDetail(
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: DateTime.parse(json['endDate'] as String),
      weeklyFrequency: json['requiredWeeklyCount'] as int,
      photoRequired: json['photoRequired'] as bool,
      tags: List<String>.from(json['tags'] as List),
      description: json['description'] as String,
      leader: User.fromJson(json['host'] as Map<String, dynamic>),
      participantCount: json['participantCount'] as int,
      joinDate: json['joinDate'] != null
          ? DateTime.parse(json['joinDate'] as String)
          : null,
      todaySuccessUsers: (json['todaySuccessUsers'] as List)
          .map((e) => User.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  ChallengeDetail copyWith({
    DateTime? startDate,
    DateTime? endDate,
    int? weeklyFrequency,
    bool? photoRequired,
    List<String>? tags,
    String? description,
    User? leader,
    int? participantCount,
    DateTime? joinDate,
    List<User>? todaySuccessUsers,
  }) {
    return ChallengeDetail(
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      weeklyFrequency: weeklyFrequency ?? this.weeklyFrequency,
      photoRequired: photoRequired ?? this.photoRequired,
      tags: tags ?? this.tags,
      description: description ?? this.description,
      leader: leader ?? this.leader,
      participantCount: participantCount ?? this.participantCount,
      joinDate: joinDate ?? this.joinDate,
      todaySuccessUsers: todaySuccessUsers ?? this.todaySuccessUsers,
    );
  }
}
