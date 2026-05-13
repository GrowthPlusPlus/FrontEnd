import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:haenaem/shared/models/search_challenge_card.dart';
import '../data/challenge_search_repository.dart';

part 'challenge_search_provider.g.dart';

// 최초 작성자: 강선욱
// 피드 화면에서 챌린지 검색을 위한 Provider
@riverpod
Future<List<SearchChallengeCard>> searchChallenges(
  SearchChallengesRef ref, {
  required String keyword,
  int page = 0,
}) {
  return ref
      .watch(challengeSearchRepositoryProvider)
      .searchChallenges(keyword: keyword, page: page);
}
