// 최초 작성자: 정승빈
library;

import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../data/challenge_leave_repository.dart';
import 'package:haenaem/shared/provider/home_provider.dart';
import 'package:haenaem/features/user/provider/my_challenge_provider.dart';

part 'challenge_leave_provider.g.dart';

@riverpod
class ChallengeLeaveNotifier extends _$ChallengeLeaveNotifier {
  @override
  AsyncValue<void> build() => const AsyncValue.data(null);

  // 일반 멤버용
  Future<bool> leaveChallenge(int challengeId) async {
    state = const AsyncValue.loading();

    final result = await AsyncValue.guard(
      () => ref
          .read(challengeLeaveRepositoryProvider)
          .leaveChallenge(challengeId),
    );

    state = result;

    if (!result.hasError) {
      ref.invalidate(homeNotifierProvider); // 홈 리스트 갱신
      ref.invalidate(myInProgressChallengesProvider); // 내 페이지 리스트 갱신
      return true;
    }

    return false;
  }
}
