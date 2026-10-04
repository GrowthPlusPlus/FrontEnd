// 최초 작성자: 정승빈 (분리 및 리팩토링)
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:haenaem/shared/models/post.dart';
// 💡 FeedRepository가 있는 경로를 임포트해주세요. (feed_provider.dart 내부에 있다면 해당 파일 임포트)
import '../data/feed_repository.dart';
import './feed_provider.dart';
import '../../../../shared/provider/post_provider.dart'; // monthlyChallengePostsProvider
import 'package:haenaem/shared/provider/challenge_detail_provider.dart';
import 'package:haenaem/features/challenge/detail/provider/stats_provider.dart';
import 'package:haenaem/shared/provider/home_provider.dart';
import 'package:haenaem/features/statistics/data/activity_repository.dart';
import 'package:haenaem/features/statistics/data/distribution_repository.dart';
import 'package:haenaem/features/statistics/data/monthly_weekly_repository.dart';

part 'post_detail_provider.g.dart';

// 💡 공통 캐시 무효화 & 피드 새로고침 통합 헬퍼 함수
void _refreshAllRelatedFeeds(
  Ref ref, {
  int? postId,
  int? challengeId,
  bool isFullStatsRefresh = false,
}) {
  // 1. 피드 목록 새로고침 (둘러보기, 친구 탭)
  ref.read(exploreFeedProvider.notifier).refresh();
  ref.read(friendFeedProvider.notifier).refresh();

  // 2. 해당 게시글 상세 캐시 무효화
  if (postId != null) {
    ref.invalidate(postDetailProvider(postId: postId));
  }

  // 3. 챌린지/생성/삭제 시 관련 통계 및 캘린더, 홈 상태 전체 무효화
  if (challengeId != null && isFullStatsRefresh) {
    final now = DateTime.now();
    ref.invalidate(
      monthlyChallengePostsProvider(
        challengeId: challengeId,
        year: now.year,
        month: now.month,
      ),
    );
    ref.invalidate(challengeStatsProvider(challengeId));
    ref.invalidate(challengeDetailProvider(challengeId: challengeId));
    ref.invalidate(homeNotifierProvider);

    // 통계 탭 3가지 카드 갱신
    ref.invalidate(activityRepositoryProvider);
    ref.invalidate(distributionRepositoryProvider);
    ref.invalidate(monthlyWeeklyRepositoryProvider);
  }
}

// 1. 인증글 상세 정보 가져오기 로직
@riverpod
Future<Post> postDetail(
  // 💡 articleDetail -> postDetail로 변경, 타입 Post로 변경
  PostDetailRef ref, {
  required int postId,
}) async {
  final repository = ref.watch(
    feedRepositoryProvider,
  ); // 💡 challenge -> feed 레포지토리로 변경
  return repository.getArticleDetail(postId);
}

// 2. 인증글 생성 로직
@riverpod
class PostCreateNotifier extends _$PostCreateNotifier {
  @override
  AsyncValue<Post?> build() => const AsyncValue.data(null); // 💡 타입 Post로 변경

  Future<bool> submitArticle({
    required int challengeId,
    required String content,
    required List<int> tempImageIds,
  }) async {
    state = const AsyncValue.loading();

    final result = await AsyncValue.guard(
      () => ref
          .read(feedRepositoryProvider)
          .createArticle(
            challengeId: challengeId,
            content: content,
            tempImageIds: tempImageIds,
          ),
    );

    if (!result.hasError) {
      _refreshAllRelatedFeeds(
        ref,
        challengeId: challengeId,
        isFullStatsRefresh: true,
      );
    }

    state = result;
    return !result.hasError;
  }
}

// 3. 인증글 수정 로직
@riverpod
class PostUpdateNotifier extends _$PostUpdateNotifier {
  @override
  AsyncValue<Post?> build() => const AsyncValue.data(null); // 💡 타입 Post로 변경

  Future<bool> editArticle({
    required int postId,
    required int challengeId,
    required String content,
    List<int> deleteImageIds = const [],
    List<int> tempImageIds = const [],
  }) async {
    state = const AsyncValue.loading();

    final result = await AsyncValue.guard(
      () => ref
          .read(feedRepositoryProvider)
          .updateArticle(
            postId: postId,
            content: content,
            deleteImageIds: deleteImageIds,
            tempImageIds: tempImageIds,
          ),
    );

    if (!result.hasError) {
      _refreshAllRelatedFeeds(
        ref,
        postId: postId,
        challengeId: challengeId,
        isFullStatsRefresh: true,
      );
    }

    state = result;
    return !result.hasError;
  }
}

// 4. 인증글 삭제 로직
@riverpod
class PostDeleteNotifier extends _$PostDeleteNotifier {
  @override
  AsyncValue<void> build() => const AsyncValue.data(null);

  Future<bool> removeArticle(int postId, int challengeId) async {
    state = const AsyncValue.loading();

    final result = await AsyncValue.guard(
      () => ref.read(feedRepositoryProvider).deleteArticle(postId),
    );

    if (!result.hasError) {
      // 💡 삭제 성공 시 피드 목록 + 챌린지/홈/통계 전체 새로고침
      _refreshAllRelatedFeeds(
        ref,
        postId: postId,
        challengeId: challengeId,
        isFullStatsRefresh: true,
      );
    }

    state = result;
    return !result.hasError;
  }
}

// 5. 좋아요 로직
@riverpod
class PostLikeNotifier extends _$PostLikeNotifier {
  @override
  AsyncValue<void> build() => const AsyncValue.data(null);

  Future<void> toggleLike({
    required int postId,
    required bool isCurrentlyLiked,
  }) async {
    final result = await AsyncValue.guard(
      () =>
          ref.read(feedRepositoryProvider).toggleLike(postId, isCurrentlyLiked),
    );

    if (!result.hasError) {
      _refreshAllRelatedFeeds(ref, postId: postId);
    }
  }
}
