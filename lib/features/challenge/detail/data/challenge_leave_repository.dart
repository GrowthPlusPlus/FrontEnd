// 최초 작성자: 정승빈
import 'package:dio/dio.dart';
import 'package:haenaem/core/network/dio_provider.dart';
import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'challenge_leave_repository.g.dart';

@riverpod
ChallengeLeaveRepository challengeLeaveRepository(
  ChallengeLeaveRepositoryRef ref,
) {
  final dio = ref.watch(dioProvider);
  return ChallengeLeaveRepository(dio);
}

class ChallengeLeaveRepository {
  final Dio _dio;

  ChallengeLeaveRepository(this._dio);

  /// 챌린지 나가기 API
  /// - [challengeId]: 나갈 챌린지 ID
  Future<void> leaveChallenge(int challengeId) async {
    try {
      final response = await _dio.delete(
        '/api/challenges/$challengeId/leaveChallenge',
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        debugPrint('✅ [Success] 챌린지 퇴장 성공: $challengeId');
      } else {
        throw Exception(response.data['message'] ?? '챌린지 나가기에 실패했습니다.');
      }
    } catch (e) {
      debugPrint('🚫 [Exception] 챌린지 퇴장 API 에러: $e');
      rethrow;
    }
  }
}
