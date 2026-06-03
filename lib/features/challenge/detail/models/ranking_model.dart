@Deprecated('challenge/models/rank_card.dart에 정의된 모델을 대신 사용')
class RankingResponse {
  final List<RankingUser> topRankings;
  final RankingUser myRanking;

  RankingResponse({required this.topRankings, required this.myRanking});

  factory RankingResponse.fromJson(Map<String, dynamic> json) {
    return RankingResponse(
      topRankings: (json['topRankings'] as List)
          .map((item) => RankingUser.fromJson(item))
          .toList(),
      myRanking: RankingUser.fromJson(json['myRanking']),
    );
  }
}

@Deprecated('challenge/models/rank_card.dart에 정의된 모델을 대신 사용')
class RankingUser {
  final int userId;
  final String nickname;
  final String? profileImageUrl;
  final int totalCount; // 총 인증 횟수
  final int streakCount; // 연속 인증 횟수
  final int rank;

  RankingUser({
    required this.userId,
    required this.nickname,
    required this.profileImageUrl,
    required this.totalCount,
    required this.streakCount,
    required this.rank,
  });

  factory RankingUser.fromJson(Map<String, dynamic> json) {
    return RankingUser(
      userId: json['userId'] ?? 0,
      nickname: json['nickname'] ?? '이름 없음',
      profileImageUrl: json['profileImageUrl'],
      totalCount: json['totalSuccessDays'] ?? 0,
      streakCount: json['currentStreakDate'] ?? 0,
      rank: json['rank'] ?? 0,
    );
  }
}
