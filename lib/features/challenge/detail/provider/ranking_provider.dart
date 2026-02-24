// 최초 작성자: 강선욱

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../data/ranking_repository.dart';
import '../model/ranking_model.dart';

part 'ranking_provider.g.dart';

/// 특정 챌린지의 랭킹 데이터를 관리하는 Notifier
@riverpod
class ChallengeRankingNotifier extends _$ChallengeRankingNotifier {
  @override
  FutureOr<RankingResponse> build(int challengeId) async {
    // 💡 새로운 RankingRepository를 구독합니다.
    final repository = ref.watch(rankingRepositoryProvider);
    return repository.getChallengeRanking(challengeId);
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() {
      return ref
          .read(rankingRepositoryProvider)
          .getChallengeRanking(challengeId);
    });
  }
}

/// 전체 랭킹 리스트만 따로 관리하는 파생 Provider
/// UI에서 data.topRankings에 직접 접근하는 대신 사용하면 편리합니다.
@riverpod
Future<List<RankingUser>> topRankings(
  TopRankingsRef ref,
  int challengeId,
) async {
  final rankingData = await ref.watch(
    challengeRankingNotifierProvider(challengeId).future,
  );
  return rankingData.topRankings;
}

/// 내 랭킹 정보만 따로 관리하는 파생 Provider
@riverpod
Future<RankingUser> myRanking(MyRankingRef ref, int challengeId) async {
  final rankingData = await ref.watch(
    challengeRankingNotifierProvider(challengeId).future,
  );
  return rankingData.myRanking;
}

/// 상위 3명(TOP 3) 유지만 따로 체크하는 상태 Provider
@riverpod
bool isMyRankingInTopThree(IsMyRankingInTopThreeRef ref, int challengeId) {
  final rankingAsync = ref.watch(challengeRankingNotifierProvider(challengeId));

  return rankingAsync.maybeWhen(
    data: (data) => data.myRanking.rank <= 3,
    orElse: () => false,
  );
}
