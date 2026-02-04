// 최초 작성자 : 강선욱
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../data/challenge_repository.dart';
import '../model/challenge_model.dart';

part 'challenge_provider.g.dart';

// 1. 전체 데이터를 가져오는 비동기 Provider
@riverpod
class ChallengeHomeNotifier extends _$ChallengeHomeNotifier {
  @override
  FutureOr<ChallengeMainModel> build() async {
    // Repository를 통해 데이터를 가져옵니다.
    final repository = ref.watch(challengeRepositoryProvider);
    final String todayDate = _getFormattedDate(DateTime.now());
    return repository.getChallengeMainData(todayDate);
  }

  // 새로고침 기능
  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() {
      final String todayDate = _getFormattedDate(DateTime.now());
      return ref
          .read(challengeRepositoryProvider)
          .getChallengeMainData(todayDate);
    });
  }

  // 내부 날짜 포맷팅 유틸리티
  String _getFormattedDate(DateTime dateTime) {
    return "${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')}";
  }
}

// 2. 오늘의 종합 상태만 따로 계산하는 파생 Provider
@riverpod
ChallengeStatus todayTotalStatus(TodayTotalStatusRef ref) {
  final homeDataAsync = ref.watch(challengeHomeNotifierProvider);

  return homeDataAsync.maybeWhen(
    data: (data) {
      final challenges = data.myChallenges;
      if (challenges.isEmpty) return ChallengeStatus.normal;

      // 하나라도 긴급(warning)이 있으면 Urgent
      if (challenges.any((c) => c.isUrgent)) return ChallengeStatus.urgent;

      // 모든 챌린지가 오늘 완료(doIt)되었으면 Completed
      if (challenges.every((c) => c.isDoneToday))
        return ChallengeStatus.completed;

      return ChallengeStatus.normal;
    },
    orElse: () => ChallengeStatus.normal,
  );
}

// 생성 상태(로딩/성공/에러)를 관리할 notifier 추가
@riverpod
class ChallengeCreateNotifier extends _$ChallengeCreateNotifier {
  @override
  AsyncValue<ChallengeCreateResponse?> build() => const AsyncValue.data(null);

  // Future<ChallengeCreateResponse?>를 반환하도록 수정
  Future<ChallengeCreateResponse?> create(Map<String, dynamic> data) async {
    state = const AsyncValue.loading();

    // AsyncValue.guard의 결과를 변수에 담습니다.
    state = await AsyncValue.guard(
      () => ref.read(challengeRepositoryProvider).createChallenge(data),
    );

    // 💡 UI에서 결과를 기다릴 수 있게 value(성공 시 데이터)를 반환합니다.
    return state.valueOrNull;
  }
}

// 특정 챌린지의 ID를 기반으로 데이터를 가져옴
@riverpod
Future<ChallengeCalendarModel> challengeCalendarData(
  ChallengeCalendarDataRef ref,
  int challengeId,
) async {
  final repository = ref.watch(challengeRepositoryProvider);
  return repository.getChallengeCalendarData(challengeId);
}

// 특정 챌린지 ID, 연도, 월에 따라 데이터를 캐싱
@riverpod
Future<List<CertificationPostModel>> challengePosts(
  ChallengePostsRef ref, {
  required int challengeId,
  required int year,
  required int month,
}) async {
  final repository = ref.watch(challengeRepositoryProvider);
  return repository.getChallengePosts(
    challengeId: challengeId,
    year: year,
    month: month,
  );
}

// 챌린지 생성 로직
@riverpod
class ArticleCreateNotifier extends _$ArticleCreateNotifier {
  @override
  AsyncValue<CertificationPostModel?> build() => const AsyncValue.data(null);

  Future<bool> submitArticle({
    required int challengeId,
    required String content,
    required List<String> verifiedImageUrls,
  }) async {
    state = const AsyncValue.loading();

    // AsyncValue.guard 내부에서 ref 사용 가능
    final result = await AsyncValue.guard(
      () => ref
          .read(challengeRepositoryProvider)
          .createArticle(
            challengeId: challengeId,
            content: content,
            imageUrls: verifiedImageUrls,
          ),
    );

    state = result;
    return !result.hasError;
  }
}
