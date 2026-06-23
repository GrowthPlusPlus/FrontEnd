// 최초 작성자 : 강선욱
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../data/challenge_participate_repository.dart';
import 'package:haenaem/features/user/provider/my_challenge_provider.dart';
import 'package:haenaem/shared/provider/home_provider.dart';
import 'package:haenaem/features/feed/provider/feed_provider.dart';

part 'challenge_participate_provider.g.dart';

@riverpod
class ChallengeParticipateNotifier extends _$ChallengeParticipateNotifier {
  @override
  // 초기 상태는 아무 작업도 하지 않은 'data(null)' 상태로 둡니다.
  AsyncValue<void> build() => const AsyncValue.data(null);

  Future<bool> participate(int challengeId) async {
    // 1. 상태를 로딩 중으로 변경 (UI에서 로딩바를 보여줄 수 있게 합니다)
    state = const AsyncValue.loading();

    // 2. 리포지토리에 실제 API 요청을 보냅니다.
    final result = await AsyncValue.guard(
      () => ref
          .read(
            challengeParticipateRepositoryProvider,
          ) // [수정] Notifier가 아닌 Repository를 읽어야 합니다!
          .participateChallenge(challengeId),
    );

    // 3. 결과(성공 또는 에러)를 상태에 저장합니다.
    state = result;

    if (!result.hasError) {
      // 4. 참여 성공 시, 내페이지의 내 진행 중인 챌린지 목록을 새로고침합니다.
      // (기존 데이터가 무효화되어 다시 서버에서 받아오게 됩니다)
      ref.invalidate(myInProgressChallengesProvider);
      ref.invalidate(aiRecommendationProvider);
      ref.invalidate(homeNotifierProvider);
      return true;
    }

    // 에러 발생 시 false 반환
    return false;
  }
}
