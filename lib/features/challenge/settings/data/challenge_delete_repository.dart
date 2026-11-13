// 최초 작성자: 정승빈
import 'package:dio/dio.dart';
import 'package:haenaem/core/network/dio_provider.dart';
import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'challenge_delete_repository.g.dart';

@riverpod
ChallengeDeleteRepository challengeDeleteRepository(
  ChallengeDeleteRepositoryRef ref,
) {
  final dio = ref.watch(dioProvider); // ← 공통 Dio 주입
  return ChallengeDeleteRepository(dio);
}

class ChallengeDeleteRepository {
  final Dio _dio;

  ChallengeDeleteRepository(this._dio);

  /// 챌린지 삭제 API
  /// - [challengeId]: 삭제할 챌린지 ID
  Future<void> deleteChallenge(int challengeId) async {
    try {
      final response = await _dio.delete('/api/challenges/$challengeId');

      if (response.statusCode != 204 && response.statusCode != 200) {
        throw Exception('챌린지 삭제 실패 (Status: ${response.statusCode})');
      }
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? '챌린지 삭제 중 오류가 발생했습니다.');
    }
  }
}
