// 최초 작성자: 강선욱
// 챌린지 총 인증 횟수, 연속 인증 횟수 관리 모델

class ChallengeStats {
  final int totalSuccessDays;
  final int currentStreakDays;

  ChallengeStats({
    required this.totalSuccessDays,
    required this.currentStreakDays,
  });

  factory ChallengeStats.fromJson(Map<String, dynamic> json) {
    return ChallengeStats(
      totalSuccessDays: json['totalSuccessDays'] ?? 0,
      currentStreakDays: json['currentStreakDays'] ?? 0,
    );
  }
}
