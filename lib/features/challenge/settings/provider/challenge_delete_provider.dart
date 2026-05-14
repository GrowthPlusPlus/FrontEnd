/// 최초 작성자: 정승빈
library;

import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../data/challenge_delete_repository.dart';
import 'package:haenaem/shared/provider/home_provider.dart'; // challengeHomeNotifierProvider 위치에 맞게 수정

part 'challenge_delete_provider.g.dart';

@riverpod
class ChallengeDeleteNotifier extends _$ChallengeDeleteNotifier {
  @override
  AsyncValue<void> build() => const AsyncValue.data(null);

  Future<bool> removeChallenge(int challengeId) async {
    state = const AsyncValue.loading();

    final result = await AsyncValue.guard(
      () => ref
          .read(challengeDeleteRepositoryProvider)
          .deleteChallenge(challengeId),
    );

    state = result;

    if (!result.hasError) {
      ref.invalidate(homeNotifierProvider); // 홈 리스트 갱신
      return true;
    }
    return false;
  }
}
