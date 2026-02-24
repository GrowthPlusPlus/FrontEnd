import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:haenaem/core/network/dio_provider.dart';
import '../model/ranking_model.dart';

part 'ranking_repository.g.dart';

class RankingRepository {
  final Dio _dio;

  RankingRepository(this._dio);

  /// 특정 챌린지의 멤버 랭킹 정보를 가져옵니다.
  /// GET /api/challenges/{challengeId}/ranking
  Future<RankingResponse> getChallengeRanking(int challengeId) async {
    print('🔥 [API Request] 랭킹 정보 조회 요청 (ChallengeId: $challengeId)');

    try {
      final response = await _dio.get('/api/challenges/$challengeId/ranking');

      print('✨ [API Response] Status: ${response.statusCode}');
      print('📦 [API Response] Data: ${response.data}');

      if (response.statusCode == 200) {
        // 성공 시 JSON 데이터를 모델로 변환
        return RankingResponse.fromJson(response.data);
      } else {
        throw Exception(
          '랭킹 데이터를 불러오는데 실패했습니다. (Status: ${response.statusCode})',
        );
      }
    } on DioException catch (e) {
      // Dio 전용 에러 핸들링
      print('🚨 [DioError] ${e.response?.statusCode} / ${e.response?.data}');
      throw Exception(e.response?.data['message'] ?? '서버 연결 실패');
    } catch (e) {
      print('🚫 [Exception] $e');
      throw Exception('랭킹 정보를 불러오는데 실패했습니다.');
    }
  }
}

// Riverpod Provider 설정 (기존 파일의 스타일과 일치)
@riverpod
RankingRepository rankingRepository(RankingRepositoryRef ref) {
  // 1. 공통 dioProvider를 감시(watch)하여 설정이 완료된 인스턴스를 가져옵니다.
  final dio = ref.watch(dioProvider);

  // 2. BaseURL, 토큰 주입 등이 완료된 dio를 주입합니다.
  return RankingRepository(dio);
}
