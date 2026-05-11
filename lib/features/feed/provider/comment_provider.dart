// 최초 작성자: 정승빈 (분리 및 리팩토링)
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:haenaem/features/feed/models/comment.dart';
import '../data/feed_repository.dart';
// 💡 상세 정보 새로고침을 위해 post_detail_provider 임포트 필요
import 'package:haenaem/features/feed/provider/post_detail_provider.dart';

part 'comment_provider.g.dart';

// 1. 댓글 목록 불러오기 로직
@riverpod
Future<List<Comment>> postComments(
  // 💡 articleComments -> postComments, 타입 Comment로 변경
  PostCommentsRef ref, {
  required int postId,
  int page = 0,
}) async {
  final repository = ref.watch(feedRepositoryProvider);
  return repository.getComments(postId: postId, page: page);
}

// 2. 댓글 생성 로직
@riverpod
class CommentCreateNotifier extends _$CommentCreateNotifier {
  @override
  AsyncValue<void> build() => const AsyncValue.data(null);

  Future<bool> addComment({
    required int postId,
    required String contents,
  }) async {
    state = const AsyncValue.loading();

    final result = await AsyncValue.guard(
      () => ref
          .read(feedRepositoryProvider)
          .createComment(postId: postId, contents: contents),
    );

    if (!result.hasError) {
      // 💡 댓글 목록 및 게시글 상세 정보 새로고침
      ref.invalidate(postCommentsProvider(postId: postId));
      ref.invalidate(postDetailProvider(postId: postId));
    }

    state = result;
    return !result.hasError;
  }
}

// 3. 댓글 수정 로직
@riverpod
class CommentUpdateNotifier extends _$CommentUpdateNotifier {
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
          .read(feedRepositoryProvider)
          .updateComment(commentId: commentId, contents: contents),
    );

    if (!result.hasError) {
      ref.invalidate(postCommentsProvider(postId: postId));
    }

    state = result;
    return !result.hasError;
  }
}

// 4. 댓글 삭제 로직
@riverpod
class CommentDeleteNotifier extends _$CommentDeleteNotifier {
  @override
  AsyncValue<void> build() => const AsyncValue.data(null);

  Future<bool> removeComment({
    required int postId,
    required int commentId,
  }) async {
    state = const AsyncValue.loading();

    final result = await AsyncValue.guard(
      () => ref.read(feedRepositoryProvider).deleteComment(commentId),
    );

    if (!result.hasError) {
      // 💡 댓글 목록 및 게시글 상세 정보 새로고침
      ref.invalidate(postCommentsProvider(postId: postId));
      ref.invalidate(postDetailProvider(postId: postId));
    }

    state = result;
    return !result.hasError;
  }
}
