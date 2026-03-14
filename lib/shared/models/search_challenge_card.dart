import 'package:haenaem/features/challenge/models/challenge_base.dart';

// 최초 작성자: 강선욱
// 챌린지 검색 후 검색 결과로 나오는 챌린지 카드 모델
// ChallengeBase에 정의된 필드(id, title, isLeader)를 재사용
class SearchChallengeCard {
  final ChallengeBase base; // 챌린지 기본 정보 (id, title, isLeader)
  final int participantCount; // 챌린지 참여자 수
  final DateTime endDate; // 챌린지 완료일
  final List<String> tags; // 챌린지 태그 리스트

  const SearchChallengeCard({
    required this.base,
    required this.participantCount,
    required this.endDate,
    required this.tags,
  });

  factory SearchChallengeCard.fromJson(Map<String, dynamic> json) {
    return SearchChallengeCard(
      base: ChallengeBase.fromJson(json),
      participantCount: json['participant_count'] as int,
      endDate: DateTime.parse(json['end_date'] as String),
      tags: List<String>.from(json['tag'] as List),
    );
  }

  SearchChallengeCard copyWith({
    ChallengeBase? base,
    int? participantCount,
    DateTime? endDate,
    List<String>? tags,
  }) {
    return SearchChallengeCard(
      base: base ?? this.base,
      participantCount: participantCount ?? this.participantCount,
      endDate: endDate ?? this.endDate,
      tags: tags ?? this.tags,
    );
  }
}
