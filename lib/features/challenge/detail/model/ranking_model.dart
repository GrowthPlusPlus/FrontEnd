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

class RankingUser {
  final int userId;
  final String nickname;
  final String? profileImageUrl;
  final double rankingScore;
  final int rank;

  RankingUser({
    required this.userId,
    required this.nickname,
    required this.profileImageUrl,
    required this.rankingScore,
    required this.rank,
  });

  factory RankingUser.fromJson(Map<String, dynamic> json) {
    return RankingUser(
      userId: json['userId'] ?? 0,
      nickname: json['nickname'] ?? '이름 없음',
      profileImageUrl: json['profileImageUrl'],
      rankingScore: json['rankingScore'] ?? 0,
      rank: json['rank'] ?? 0,
    );
  }
}
