import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:haenaem/features/feed/provider/feed_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../data/verification_repository.dart';
import 'package:haenaem/shared/models/post.dart';
import 'package:haenaem/shared/provider/post_provider.dart';
import 'package:haenaem/shared/provider/home_provider.dart';
import 'package:haenaem/features/challenge/detail/provider/stats_provider.dart';
import 'package:haenaem/shared/provider/challenge_detail_provider.dart';
import 'package:haenaem/features/statistics/data/activity_repository.dart';
import 'package:haenaem/features/statistics/data/distribution_repository.dart';
import 'package:haenaem/features/statistics/data/monthly_weekly_repository.dart';
import 'package:haenaem/features/user/provider/my_challenge_provider.dart';

part 'verification_provider.g.dart';

// 인증글 생성, 수정 시 관련된 캐시를 한번에 갱신하는 함수
void _refreshRelatedProviders(Ref ref, int challengeId) {
  final now = DateTime.now();

  // 1. 해당 챌린지의 월간 포스트 리스트 갱신
  ref.invalidate(
    monthlyChallengePostsProvider(
      challengeId: challengeId,
      year: now.year,
      month: now.month,
    ),
  );

  // 2. 챌린지 상세 통계(총 인증 횟수, 연속 인증 횟수) 갱신
  ref.invalidate(challengeStatsProvider(challengeId));

  // 3. 홈 화면(진행 중인 챌린지 현황 등) 갱신
  ref.invalidate(homeNotifierProvider);

  // 4. 멤버 현황 갱신
  ref.invalidate(feedNotifierProvider);

  ref.invalidate(challengeDetailProvider(challengeId: challengeId));

  // 통계 탭 세 가지 카드 갱신
  ref.invalidate(activityRepositoryProvider);
  ref.invalidate(distributionRepositoryProvider);
  ref.invalidate(monthlyWeeklyRepositoryProvider);

  // 내 페이지 "나의 챌린지" 박스 + 전체 리스트 화면 갱신
  ref.invalidate(myInProgressChallengesProvider);
  ref.invalidate(mySuccessChallengesProvider);
  ref.invalidate(myFailedChallengesProvider);
}

// 인증 이미지 검증
@riverpod
class ImageUploadNotifier extends _$ImageUploadNotifier {
  @override
  AsyncValue<int?> build() => const AsyncValue.data(null);

  Future<int?> upload(File file, int challengeId) async {
    state = const AsyncValue.loading();
    final result = await AsyncValue.guard(
      () => ref
          .read(verificationRepositoryProvider)
          .uploadImage(file, challengeId),
    );
    state = result;
    return result.valueOrNull;
  }
}

// AI 챌린지 관련성 검사 전용
@riverpod
class ClipVerifyNotifier extends _$ClipVerifyNotifier {
  @override
  AsyncValue<bool?> build() => const AsyncValue.data(null);

  Future<bool> verify(int challengeId, int temporaryImageId) async {
    state = const AsyncValue.loading();
    final result = await AsyncValue.guard(
      () => ref
          .read(verificationRepositoryProvider)
          .clipVerifyImage(challengeId, temporaryImageId),
    );
    state = result;
    return result.valueOrNull ?? false;
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

    if (!result.hasError && result.value != null) {
      _refreshRelatedProviders(ref, challengeId);
    }

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

    if (!result.hasError && result.value != null) {
      _refreshRelatedProviders(ref, challengeId);
    }

    state = result;
    return !result.hasError;
  }
}
