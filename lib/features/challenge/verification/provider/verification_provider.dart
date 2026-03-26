import 'dart:io';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../data/verification_repository.dart';
import 'package:haenaem/shared/models/post.dart';
import 'package:haenaem/shared/provider/post_provider.dart';
import 'package:haenaem/shared/provider/home_provider.dart';

part 'verification_provider.g.dart';

// 인증 이미지 검증
@riverpod
class ImageVerifyNotifier extends _$ImageVerifyNotifier {
  @override
  AsyncValue<int?> build() => const AsyncValue.data(null);

  Future<int?> verify(File file, int challengeId) async {
    state = const AsyncValue.loading();

    // [변경] 기존 challengeRepository 대신 신규 verificationRepository 사용
    final result = await AsyncValue.guard(
      () => ref
          .read(verificationRepositoryProvider)
          .verifyImage(file, challengeId),
    );

    state = result;
    return result.valueOrNull;
  }
}

// 인증글 생성
@riverpod
class ArticleCreateNotifier extends _$ArticleCreateNotifier {
  @override
  AsyncValue<Post?> build() => const AsyncValue.data(null);

  Future<bool> submitArticle({
    required int challengeId,
    required String content,
    required List<int> tempImageIds, // 검증 완료된 ID 리스트
  }) async {
    state = const AsyncValue.loading();

    final result = await AsyncValue.guard(
      () => ref
          .read(verificationRepositoryProvider)
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

// 인증글 수정
@riverpod
class ArticleUpdateNotifier extends _$ArticleUpdateNotifier {
  @override
  AsyncValue<Post?> build() => const AsyncValue.data(null);

  Future<bool> editArticle({
    required int postId,
    required int challengeId,
    required String content,
    List<int> deleteImageIds = const [],
    List<int> tempImageIds = const [], // 새 이미지의 임시 ID 리스트
  }) async {
    state = const AsyncValue.loading();

    final result = await AsyncValue.guard(
      () => ref
          .read(verificationRepositoryProvider)
          .updateArticle(
            postId: postId,
            content: content,
            deleteImageIds: deleteImageIds,
            tempImageIds: tempImageIds,
          ),
    );

    if (!result.hasError) {
      final now = DateTime.now();

      // 수정 성공 시 관련 데이터 캐시 갱신
      ref.invalidate(
        monthlyChallengePostsProvider(
          challengeId: challengeId,
          year: now.year,
          month: now.month,
        ),
      );
      ref.invalidate(homeNotifierProvider);
    }

    state = result;
    return !result.hasError;
  }
}
