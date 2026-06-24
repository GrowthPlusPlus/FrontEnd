import 'package:haenaem/shared/models/challenge_base.dart';

// 최초 작성자: 강선욱
// 챌린지 검색 후 검색 결과로 나오는 챌린지 카드 모델
// ChallengeBase에 정의된 필드(id, title, isLeader)를 재사용
class SearchChallengeCard {
  final ChallengeBase base; // 챌린지 기본 정보 (id, title, isLeader)
  final int participantCount; // 챌린지 참여자 수
  final int dDay; // 챌린지 종료 D-Day
  final List<String> tags; // 챌린지 태그 리스트

  const SearchChallengeCard({
    required this.base,
    required this.participantCount,
    required this.dDay,
    required this.tags,
  });

  //
  // factory SearchChallengeCard.fromJson(Map<String, dynamic> json) {
  //   return SearchChallengeCard(
  //     base: ChallengeBase.fromJson(json),
  //     participantCount: json['participant_count'] as int,
  //     dDay: json['end_date'] as int,
  //     tags: List<String>.from(json['tag'] as List),
  //   );
  // }
  //

  factory SearchChallengeCard.fromJson(Map<String, dynamic> json) {
    return SearchChallengeCard(
      base: ChallengeBase(
        id: json['id'] as int, // ✅ 검색 API는 id로 직접 매핑
        title: json['title'] as String,
      ),
      // base: ChallengeBase.fromJson(json),
      participantCount: json['participantNumber'] as int,
      // TODO: api 수정해주시면 dDay 수정 ㄱㄱ
      dDay: 0, // dDay: json['end_date'] as int,
      tags: (json['tags'] as List)
          .map((tagObj) => tagObj['tag'] as String)
          .toList(),
      // tags: List<String>.from(json['tag'] as List),
    );
  }

  SearchChallengeCard copyWith({
    ChallengeBase? base,
    int? participantCount,
    int? dDay,
    List<String>? tags,
  }) {
    return SearchChallengeCard(
      base: base ?? this.base,
      participantCount: participantCount ?? this.participantCount,
      dDay: dDay ?? this.dDay,
      tags: tags ?? this.tags,
    );
  }
}
