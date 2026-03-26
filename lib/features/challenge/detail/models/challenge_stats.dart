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
