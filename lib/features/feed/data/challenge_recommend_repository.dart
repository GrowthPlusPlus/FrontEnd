// 최초 작성자: 김채영
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:haenaem/core/network/dio_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/recommended_challenge.dart';

part 'challenge_recommend_repository.g.dart';

@riverpod
ChallengeRecommendRepository challengeRecommendRepository(
  ChallengeRecommendRepositoryRef ref,
) {
  final dio = ref.watch(dioProvider); // ← 공통 Dio 주입
  return ChallengeRecommendRepository(dio);
}

// AI 추천 챌린지 API 레포지토리
class ChallengeRecommendRepository {
  final Dio _dio;
  ChallengeRecommendRepository(this._dio);

  /// 탐색 탭 AI 챌린지 추천 (서술 요약 + 카드 목록 합본)
  Future<RecommendedChallengeResponse> getRecommendedChallenges() async {
    try {
      final response = await _dio.post('/api/v1/rag/recommend/combined');

      if (response.statusCode == 200) {
        debugPrint('🔍 추천 응답 키들: ${(response.data as Map).keys.toList()}');
        return RecommendedChallengeResponse.fromJson(
          response.data as Map<String, dynamic>,
        );
      } else {
        throw Exception('추천 챌린지 조회 실패');
      }
    } on DioException catch (e) {
      debugPrint('❌ 추천 API 에러: ${e.response?.data}');
      throw Exception('추천 챌린지를 불러오는 중 오류가 발생했습니다.');
    }
  }
}
