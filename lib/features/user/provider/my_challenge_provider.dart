// 최초 작성자 : 강선욱
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:haenaem/features/user/models/my_page_challenge_card.dart';
import '../data/my_challenge_repository.dart';

part 'my_challenge_provider.g.dart';

// 1. 내 페이지 - 나의 챌린지 - 진행중인 챌린지
@riverpod
Future<List<MyPageChallengeCard>> myInProgressChallenges(
  MyInProgressChallengesRef ref, {
  bool onlyTwo = false,
}) {
  return ref
      .watch(myChallengeRepositoryProvider)
      .getInProgressChallenges(onlyTwo: onlyTwo);
}

// 2. 내 페이지 - 나의 챌린지 - 완료한 챌린지
@riverpod
Future<List<MyPageChallengeCard>> mySuccessChallenges(
  MySuccessChallengesRef ref, {
  bool onlyTwo = false,
}) {
  return ref
      .watch(myChallengeRepositoryProvider)
      .getSuccessChallenges(onlyTwo: onlyTwo);
}

// 3. 내 페이지 - 나의 챌린지 - 실패한 챌린지
@riverpod
Future<List<MyPageChallengeCard>> myFailedChallenges(
  MyFailedChallengesRef ref, {
  bool onlyTwo = false,
}) {
  return ref
      .watch(myChallengeRepositoryProvider)
      .getFailedChallenges(onlyTwo: onlyTwo);
}
