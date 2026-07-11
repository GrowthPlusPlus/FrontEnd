// 최초 작성자: 김채영
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/recommended_challenge.dart';
import '../data/challenge_recommend_repository.dart';

part 'recommended_challenge_provider.g.dart';

// AI 추천 챌린지 (탐색 탭 상단 배너 + 카드) Provider
@riverpod
Future<RecommendedChallengeResponse> recommendedChallenges(
  RecommendedChallengesRef ref,
) {
  return ref
      .watch(challengeRecommendRepositoryProvider)
      .getRecommendedChallenges();
}
