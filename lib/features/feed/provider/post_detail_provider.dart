// 최초 작성자: 정승빈 (분리 및 리팩토링)
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:haenaem/shared/models/post.dart';
// 💡 FeedRepository가 있는 경로를 임포트해주세요. (feed_provider.dart 내부에 있다면 해당 파일 임포트)
import '../data/feed_repository.dart';

part 'post_detail_provider.g.dart';

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
      // 💡 수정 완료 후 상세 페이지 무효화(새로고침)
      ref.invalidate(postDetailProvider(postId: postId));
      //ref.invalidate(challengePostsProvider); // 필요하다면 챌린지 피드도 무효화하여 목록 갱신
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

  Future<bool> removeArticle(int postId) async {
    state = const AsyncValue.loading();

    final result = await AsyncValue.guard(
      () => ref.read(feedRepositoryProvider).deleteArticle(postId),
    );

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
      // 💡 성공 시 해당 게시글 상세 데이터 무효화 -> 화면 자동 갱신
      ref.invalidate(postDetailProvider(postId: postId));
    }
  }
}
