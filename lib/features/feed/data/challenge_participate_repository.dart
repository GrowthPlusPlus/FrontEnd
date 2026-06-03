import 'package:dio/dio.dart';
import 'package:haenaem/core/network/dio_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'challenge_participate_repository.g.dart';

@riverpod
ChallengeParticipateRepository challengeParticipateRepository(
  ChallengeParticipateRepositoryRef ref,
) {
  final dio = ref.watch(dioProvider); // ← 공통 Dio 주입
  return ChallengeParticipateRepository(dio);
}

// 최초 작성자 : 강선욱
class ChallengeParticipateRepository {
  final Dio _dio;

  ChallengeParticipateRepository(this._dio);

  /// 챌린지 참여하기 API
  Future<void> participateChallenge(int challengeId) async {
    try {
      debugPrint('🚀 [POST Request] /api/challenges/$challengeId/participate');

      final response = await _dio.post(
        '/api/challenges/$challengeId/participate',
      );

      // 성공 조건 체크 (200 또는 201)
      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('챌린지 참여에 실패했습니다.');
      }
      debugPrint('✅ 챌린지 참여 성공');
    } on DioException catch (e) {
      debugPrint('❌ 챌린지 참여 API 에러: ${e.response?.data}');
      throw Exception(
        e.response?.data?['message'] ?? '이미 참여 중이거나 참여할 수 없는 챌린지입니다.',
      );
    }
  }
}
