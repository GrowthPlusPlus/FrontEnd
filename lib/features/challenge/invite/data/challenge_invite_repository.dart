// 최초 작성자: 정승빈

import 'package:dio/dio.dart';
import 'package:haenaem/core/network/dio_provider.dart';
import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/invite_response.dart';

part 'challenge_invite_repository.g.dart';

@riverpod
ChallengeInviteRepository challengeInviteRepository(
  ChallengeInviteRepositoryRef ref,
) {
  final dio = ref.watch(dioProvider);
  return ChallengeInviteRepository(dio);
}

class ChallengeInviteRepository {
  final Dio _dio;

  ChallengeInviteRepository(this._dio);

  // 챌린지 초대 탭 정보 조회 API (링크 + 친구목록 + 초대여부)
  // - [challengeId]: 조회할 챌린지 ID
  Future<ChallengeInviteResponse> getChallengeInviteInfo(
    int challengeId,
  ) async {
    try {
      debugPrint('🚀 [API 요청 시작] /api/challenges/$challengeId/invite');

      final response = await _dio.get('/api/challenges/$challengeId/invite');

      debugPrint('📥 [API 응답 코드] ${response.statusCode}');
      debugPrint('📦 [API 응답 데이터 원본] ${response.data}');

      if (response.statusCode == 200) {
        try {
          final result = ChallengeInviteResponse.fromJson(response.data);
          debugPrint(
            '친구: ${result.friends.map((f) => '(${f.id}) ${f.nickname}').toList()}',
          );
          debugPrint('링크: ${result.challengeLink}');
          return result;
        } catch (e) {
          debugPrint('⚠️ [파싱 에러] 모델 변환 실패: $e');
          debugPrint('🔍 [파싱 실패 데이터] ${response.data}');
          rethrow;
        }
      } else {
        throw Exception('초대 정보 조회 실패 (Status: ${response.statusCode})');
      }
    } catch (e) {
      debugPrint('❌ [API 에러 발생] $e');
      rethrow;
    }
  }

  // 챌린지 친구 초대
  // API: POST /api/challenges/{challengeId}/invite/{friendNickname}
  Future<void> inviteFriend(int challengeId, String friendNickname) async {
    try {
      // POST 요청 전송
      await _dio.post('/api/challenges/$challengeId/invite/$friendNickname');
    } catch (e) {
      // 에러 발생 시 호출한 곳(UI)으로 에러를 던짐
      rethrow;
    }
  }
}
