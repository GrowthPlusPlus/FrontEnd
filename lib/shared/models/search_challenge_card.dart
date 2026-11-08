import 'package:haenaem/shared/models/challenge_base.dart';
import 'package:haenaem/shared/models/tag_model.dart';
import 'package:flutter/foundation.dart';

// 최초 작성자: 강선욱
// 챌린지 검색 후 검색 결과로 나오는 챌린지 카드 모델
// ChallengeBase에 정의된 필드(id, title, isLeader)를 재사용
class SearchChallengeCard {
  final ChallengeBase base; // 챌린지 기본 정보 (id, title, isLeader)
  final int participantCount; // 챌린지 참여자 수
  final int dDay; // 챌린지 종료 D-Day
  final List<ChallengeTagModel> tags; // 챌린지 태그 리스트
  final bool join;

  const SearchChallengeCard({
    required this.base,
    required this.participantCount,
    required this.dDay,
    required this.tags,
    this.join = false,
  });

  factory SearchChallengeCard.fromJson(Map<String, dynamic> json) {
    debugPrint(
      '❣️❣️❣️ search json: join=${json['join']}, keys=${json.keys.toList()}',
    );
    return SearchChallengeCard(
      base: ChallengeBase.fromJson(json),
      participantCount: (json['participantNumber']) as int,
      dDay:
          (json['remainingDays'] as num?)?.toInt() ??
          0, // json['end_date'] as int,
      tags: (json['tags'] as List? ?? [])
          .map((t) => ChallengeTagModel.fromJson(t as Map<String, dynamic>))
          .toList(),
      join: json['join'] as bool? ?? false,
    );
  }

  SearchChallengeCard copyWith({
    ChallengeBase? base,
    int? participantCount,
    int? dDay,
    List<ChallengeTagModel>? tags,
    bool? join,
  }) {
    return SearchChallengeCard(
      base: base ?? this.base,
      participantCount: participantCount ?? this.participantCount,
      dDay: dDay ?? this.dDay,
      tags: tags ?? this.tags,
      join: join ?? this.join,
    );
  }
}
