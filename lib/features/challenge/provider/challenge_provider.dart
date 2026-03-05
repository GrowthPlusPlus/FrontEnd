// 최초 작성자 : 강선욱
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../data/challenge_repository.dart';
import 'package:haenaem/features/user/data/user_repository.dart';
import '../model/challenge_model.dart';
import 'package:haenaem/features/user/model/user_model.dart';
import 'dart:io';

part 'challenge_provider.g.dart';

// 전체 데이터를 가져오는 비동기 Provider
@riverpod
class ChallengeHomeNotifier extends _$ChallengeHomeNotifier {
  @override
  FutureOr<ChallengeMainModel> build() async {
    // Repository를 통해 데이터를 가져옵니다.
    final repository = ref.watch(challengeRepositoryProvider);
    final String todayDate = _getFormattedDate(DateTime.now());
    // print(repository.getChallengeMainData(todayDate));
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

// 챌린지 나가기 로직 (일반 멤버용)
@riverpod
class ChallengeLeaveNotifier extends _$ChallengeLeaveNotifier {
  @override
  AsyncValue<void> build() => const AsyncValue.data(null);

  Future<bool> leaveChallenge(int challengeId) async {
    state = const AsyncValue.loading();

    final result = await AsyncValue.guard(
      () => ref.read(challengeRepositoryProvider).leaveChallenge(challengeId),
    );

    state = result;

    if (!result.hasError) {
      // 💡 나가기 성공 시 관련 데이터들을 무효화하여 UI를 갱신합니다.
      ref.invalidate(challengeHomeNotifierProvider); // 홈 리스트 갱신
      // 나갔을 때 실패한 챌린지로 넣을거면 로직을 추가해야함
      ref.invalidate(myInProgressChallengesProvider); // 내 페이지 리스트 갱신
      return true;
    }

    return false;
  }
}

// 특정 챌린지 상세 정보를 가져오는 Provider
@riverpod
Future<ChallengeDetailModel> challengeDetail(
  Ref ref, {
  required int challengeId,
}) async {
  final repository = ref.watch(challengeRepositoryProvider);
  return repository.getChallengeDetail(challengeId); // 레포지토리 리턴 타입도 맞춰주세요.
}

// 오늘의 종합 상태만 따로 계산하는 파생 Provider
@riverpod
ChallengeStatus todayTotalStatus(TodayTotalStatusRef ref) {
  final homeDataAsync = ref.watch(challengeHomeNotifierProvider);

  return homeDataAsync.maybeWhen(
    data: (data) {
      final challenges = data.myChallenges;
      if (challenges.isEmpty) return ChallengeStatus.normal;

      // 하나라도 긴급(warning)이 있으면 Urgent
      if (challenges.any((c) => c['warning'] == true))
        return ChallengeStatus.urgent;

      // 모든 챌린지가 오늘 완료(doIt)되었으면 Completed
      if (challenges.every((c) => c['doIt'] == true))
        return ChallengeStatus.completed;

      return ChallengeStatus.normal;
    },
    orElse: () => ChallengeStatus.normal,
  );
}

// 서버 태그 목록 불러오기
@riverpod
Future<List<ChallengeTagModel>> allTags(AllTagsRef ref) {
  return ref.watch(userRepositoryProvider).getAllTags();
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

// 챌린지 캘린더 사진
@riverpod
Future<List<ChallengeCalendarPhoto>> challengeCalendarPhotos(
  ChallengeCalendarPhotosRef ref, {
  required int challengeId,
  required int year,
  required int month,
}) async {
  final repository = ref.watch(challengeRepositoryProvider);
  return repository.getChallengeCalendarPhotos(
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
    required List<File> imageFiles,
  }) async {
    state = const AsyncValue.loading();

    final result = await AsyncValue.guard(
      () => ref
          .read(challengeRepositoryProvider)
          .createArticle(
            challengeId: challengeId,
            content: content,
            imageFiles: imageFiles,
          ),
    );

    state = result;
    return !result.hasError;
  }
}

// 인증글 상세 정보 가져오기 로직
@riverpod
Future<CertificationPostModel> articleDetail(
  ArticleDetailRef ref, {
  required int postId,
}) async {
  final repository = ref.watch(challengeRepositoryProvider);
  return repository.getArticleDetail(postId);
}

// 인증글 수정 로직
@riverpod
class ArticleUpdateNotifier extends _$ArticleUpdateNotifier {
  @override
  AsyncValue<CertificationPostModel?> build() => const AsyncValue.data(null);

  Future<bool> editArticle({
    required int postId,
    required String content,
    List<int> deleteImageIds = const [],
    List<File> newImages = const [],
  }) async {
    state = const AsyncValue.loading();

    final result = await AsyncValue.guard(
      () => ref
          .read(challengeRepositoryProvider)
          .updateArticle(
            postId: postId,
            content: content,
            deleteImageIds: deleteImageIds,
            newImages: newImages,
          ),
    );

    if (!result.hasError) {
      // 💡 수정 성공 시 캐시 갱신
      ref.invalidate(articleDetailProvider(postId: postId)); // 상세 페이지 갱신
      ref.invalidate(challengePostsProvider); // 리스트 갱신
    }

    state = result;
    return !result.hasError;
  }
}

// 인증글 삭제 로직
@riverpod
class ArticleDeleteNotifier extends _$ArticleDeleteNotifier {
  @override
  AsyncValue<void> build() => const AsyncValue.data(null);

  Future<bool> removeArticle(int postId) async {
    state = const AsyncValue.loading();

    final result = await AsyncValue.guard(
      () => ref.read(challengeRepositoryProvider).deleteArticle(postId),
    );

    state = result;
    return !result.hasError;
  }
}

// 댓글 목록 불러오기 로직
@riverpod
Future<List<ChallengeComment>> articleComments(
  ArticleCommentsRef ref, {
  required int postId,
  int page = 0,
}) async {
  final repository = ref.watch(challengeRepositoryProvider);
  return repository.getComments(postId: postId, page: page);
}

// 댓글 생성 로직
@riverpod
class ArticleCommentCreateNotifier extends _$ArticleCommentCreateNotifier {
  @override
  AsyncValue<void> build() => const AsyncValue.data(null);

  Future<bool> addComment({
    required int postId,
    required String contents,
  }) async {
    state = const AsyncValue.loading();

    final result = await AsyncValue.guard(
      () => ref
          .read(challengeRepositoryProvider)
          .createComment(postId: postId, contents: contents),
    );

    if (!result.hasError) {
      // 댓글 목록 새로고침
      ref.invalidate(articleCommentsProvider(postId: postId));
      // 게시글 상세 정보 새로고침
      ref.invalidate(articleDetailProvider(postId: postId));
    }

    state = result;
    return !result.hasError;
  }
}

// 댓글 삭제 로직
@riverpod
class ArticleCommentDeleteNotifier extends _$ArticleCommentDeleteNotifier {
  @override
  AsyncValue<void> build() => const AsyncValue.data(null);

  Future<bool> removeComment({
    required int postId,
    required int commentId,
  }) async {
    state = const AsyncValue.loading();

    final result = await AsyncValue.guard(
      () => ref.read(challengeRepositoryProvider).deleteComment(commentId),
    );

    if (!result.hasError) {
      // 댓글 목록 새로고침
      ref.invalidate(articleCommentsProvider(postId: postId));

      // 게시글 상세 정보 새로고침
      ref.invalidate(articleDetailProvider(postId: postId));
    }

    state = result;
    return !result.hasError;
  }
}

// 댓글 수정 로직
@riverpod
class ArticleCommentUpdateNotifier extends _$ArticleCommentUpdateNotifier {
  @override
  AsyncValue<void> build() => const AsyncValue.data(null);

  Future<bool> editComment({
    required int postId,
    required int commentId,
    required String contents,
  }) async {
    state = const AsyncValue.loading();

    final result = await AsyncValue.guard(
      () => ref
          .read(challengeRepositoryProvider)
          .updateComment(commentId: commentId, contents: contents),
    );

    if (!result.hasError) {
      // 💡 댓글 수정 성공 시 해당 게시글의 댓글 목록을 새로고침합니다.
      ref.invalidate(articleCommentsProvider(postId: postId));
    }

    state = result;
    return !result.hasError;
  }
}

// 좋아요 로직
@riverpod
class ArticleLikeNotifier extends _$ArticleLikeNotifier {
  @override
  AsyncValue<void> build() => const AsyncValue.data(null);

  Future<void> toggleLike({
    required int postId,
    required bool isCurrentlyLiked,
  }) async {
    // 💡 별도의 로딩 상태 없이 즉시 실행 (사용자 체감 속도 향상)
    final result = await AsyncValue.guard(
      () => ref
          .read(challengeRepositoryProvider)
          .toggleLike(postId: postId, isCurrentlyLiked: isCurrentlyLiked),
    );

    if (!result.hasError) {
      // 💡 성공 시 해당 게시글 상세 데이터 무효화 -> 화면 자동 갱신
      ref.invalidate(articleDetailProvider(postId: postId));
      // 필요 시 리스트 화면도 무효화
      // ref.invalidate(challengePostsProvider);
    }
  }
}

// 챌린지장 위임 로직
@riverpod
class ChallengeDelegateNotifier extends _$ChallengeDelegateNotifier {
  @override
  AsyncValue<void> build() => const AsyncValue.data(null);

  Future<bool> delegateAndLeave({
    required int challengeId,
    required int delegateMemberId,
  }) async {
    state = const AsyncValue.loading();

    final result = await AsyncValue.guard(
      () => ref
          .read(challengeRepositoryProvider)
          .delegateChallengeOwner(challengeId, delegateMemberId),
    );

    state = result;

    if (!result.hasError) {
      // 위임 성공 시 홈 데이터 등을 갱신
      ref.invalidate(challengeHomeNotifierProvider);
      ref.invalidate(challengeCalendarDataProvider(challengeId));
      return true;
    }
    return false;
  }
}

// 챌린지 삭제 로직
@riverpod
class ChallengeDeleteNotifier extends _$ChallengeDeleteNotifier {
  @override
  AsyncValue<void> build() => const AsyncValue.data(null);

  Future<bool> removeChallenge(int challengeId) async {
    state = const AsyncValue.loading();

    final result = await AsyncValue.guard(
      () => ref.read(challengeRepositoryProvider).deleteChallenge(challengeId),
    );

    state = result;

    if (!result.hasError) {
      // 💡 삭제 성공 시 홈 화면 데이터를 무효화하여 리스트를 새로고침합니다.
      ref.invalidate(challengeHomeNotifierProvider);
      return true;
    }
    return false;
  }
}

// 내페이지 사용자 프로필 정보
@riverpod
Future<UserProfileModel> myProfile(MyProfileRef ref) async {
  final repository = ref.watch(userRepositoryProvider);
  return repository.getMyProfile();
}

// 내 페이지 - 나의 챌린지 - 진행중인 챌린지
@riverpod
Future<List<ChallengeInProgressModel>> myInProgressChallenges(
  MyInProgressChallengesRef ref, {
  bool onlyTwo = false,
}) {
  return ref
      .watch(challengeRepositoryProvider)
      .getInProgressChallenges(onlyTwo: onlyTwo);
}

// 내 페이지 - 나의 챌린지 - 완료한 챌린지
@riverpod
Future<List<ChallengeInProgressModel>> mySuccessChallenges(
  MySuccessChallengesRef ref, {
  bool onlyTwo = false,
}) {
  return ref
      .watch(challengeRepositoryProvider)
      .getSuccessChallenges(onlyTwo: onlyTwo);
}

// 내 페이지 - 나의 챌린지 - 실패한 챌린지
@riverpod
Future<List<ChallengeInProgressModel>> myFailedChallenges(
  MyFailedChallengesRef ref, {
  bool onlyTwo = false,
}) {
  return ref
      .watch(challengeRepositoryProvider)
      .getFailedChallenges(onlyTwo: onlyTwo);
}

// 챌린지 검색
@riverpod
Future<List<SearchChallengeModel>> searchChallenges(
  SearchChallengesRef ref, {
  required String keyword,
  int page = 0,
}) {
  return ref
      .watch(challengeRepositoryProvider)
      .searchChallenges(keyword: keyword, page: page);
}

// 챌린지 참여
@riverpod
class ChallengeParticipateNotifier extends _$ChallengeParticipateNotifier {
  @override
  AsyncValue<void> build() => const AsyncValue.data(null);

  Future<bool> participate(int challengeId) async {
    state = const AsyncValue.loading();

    final result = await AsyncValue.guard(
      () => ref
          .read(challengeRepositoryProvider)
          .participateChallenge(challengeId),
    );

    state = result;

    if (!result.hasError) {
      // 참여 성공 시, 홈 화면이나 내페이지의 진행 중인 챌린지 목록 갱신
      ref.invalidate(challengeHomeNotifierProvider);
      ref.invalidate(myInProgressChallengesProvider);
      return true;
    }
    return false;
  }
}
