// 최초 작성자: 강선욱
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:haenaem/features/feed/data/feed_repository.dart';
import 'package:haenaem/features/feed/models/feed_model.dart';

part 'feed_provider.g.dart';

@riverpod
class FeedNotifier extends _$FeedNotifier {
  @override
  FeedState build(String apiPath) => FeedState();

  // feed_repository.dart의 @riverpod 어노테이션으로 생성된 Provider를 사용
  FeedRepository get _repository => ref.read(feedRepositoryProvider);

  // ── 피드 최초 로드 ────────────────────────────

  Future<void> fetchFeeds() async {
    if (state.isLoading) return;

    state = state.copyWith(
      isLoading: true,
      errorMessage: null,
      currentPage: 0,
      isLastPage: false,
    );

    try {
      print("📡 [FeedNotifier] 요청 → $apiPath");
      final result = await _repository.getFeeds(apiPath, 0);
      print("✅ [FeedNotifier] ${result['posts'].length}개 수신");

      state = state.copyWith(
        posts: result['posts'],
        isLastPage: result['isLast'],
        isLoading: false,
      );
    } catch (e, st) {
      print("❌ [FeedNotifier] fetchFeeds 에러: $e\n$st");
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  // ── 무한 스크롤 추가 로드 ─────────────────────

  Future<void> loadMore() async {
    if (state.isLoading || state.isLastPage) return;

    state = state.copyWith(isLoading: true);

    try {
      final nextPage = state.currentPage + 1;
      final result = await _repository.getFeeds(apiPath, nextPage);

      state = state.copyWith(
        posts: [...state.posts, ...result['posts']],
        currentPage: nextPage,
        isLastPage: result['isLast'],
        isLoading: false,
      );
    } catch (e) {
      print("❌ [FeedNotifier] loadMore 에러: $e");
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  // ── 좋아요 토글 (Optimistic Update + Rollback) ─

  Future<void> toggleLike(int postId) async {
    final post = state.posts.firstWhere((p) => p.id == postId);
    final wasLiked = post.isLiked;

    _updateLikeLocally(postId); // 즉시 UI 반영

    try {
      await _repository.toggleLike(postId, wasLiked);
    } catch (e) {
      _updateLikeLocally(postId); // 실패 시 롤백
      print("⚠️ [FeedNotifier] 좋아요 실패 → 롤백: $e");
    }
  }

  void _updateLikeLocally(int postId) {
    state = state.copyWith(
      posts: state.posts.map((post) {
        if (post.id != postId) return post;
        return post.copyWith(
          isLiked: !post.isLiked,
          likeCount: post.isLiked ? post.likeCount - 1 : post.likeCount + 1,
        );
      }).toList(),
    );
  }

  // ── 댓글 수 로컬 업데이트 ─────────────────────

  void incrementCommentCountLocally(int postId) =>
      _updateCommentCount(postId, 1);

  void decrementCommentCountLocally(int postId) =>
      _updateCommentCount(postId, -1);

  void _updateCommentCount(int postId, int delta) {
    state = state.copyWith(
      posts: state.posts.map((post) {
        if (post.id != postId) return post;
        final updated = post.commentCount + delta;
        return post.copyWith(commentCount: updated < 0 ? 0 : updated);
      }).toList(),
    );
  }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 각 탭·화면 전용 Provider alias
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

/// 친구 피드 (FeedScreen 친구 탭)
/// 사용: ref.watch(friendFeedProvider)
final friendFeedProvider = feedNotifierProvider('/api/feed/friends');

/// 둘러보기 피드 (FeedScreen 둘러보기 탭)
/// 사용: ref.watch(exploreFeedProvider)
final exploreFeedProvider = feedNotifierProvider('/api/feed/public');

/// 챌린지 멤버 피드
/// 사용: ref.watch(memberFeedProvider(42))
memberFeedProvider(int challengeId) =>
    feedNotifierProvider('/api/feed/challengeMember/$challengeId');
