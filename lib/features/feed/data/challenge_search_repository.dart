import 'package:dio/dio.dart';
import 'package:haenaem/core/network/dio_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:haenaem/shared/models/search_challenge_card.dart';

part 'challenge_search_repository.g.dart';

@riverpod
ChallengeSearchRepository challengeSearchRepository(
  ChallengeSearchRepositoryRef ref,
) {
  final dio = ref.watch(dioProvider); // ← 공통 Dio 주입
  return ChallengeSearchRepository(dio);
}

// 최초 작성자: 강선욱
class ChallengeSearchRepository {
  final Dio _dio;
  ChallengeSearchRepository(this._dio);

  /// 챌린지 검색 API
  Future<List<SearchChallengeCard>> searchChallenges({
    required String keyword,
    int page = 0,
  }) async {
    try {
      final response = await _dio.get(
        '/api/challenges/search',
        queryParameters: {'keyword': keyword, 'page': page},
      );

      if (response.statusCode == 200) {
        // API 응답 구조에 따라 'content' 리스트 파싱
        final List<dynamic> content = response.data['content'] ?? [];
        if (content.isNotEmpty) {
          debugPrint(
            '🔍 첫 번째 항목의 키들: ${(content[0] as Map).keys.toList()}',
          ); // ✅ 키 목록만 확인
          debugPrint('🔍 첫 번째 항목 전체: ${content[0]}'); // ✅ 항목 1개만 출력 (훨씬 짧음)
        }
        return content
            .map((json) => SearchChallengeCard.fromJson(json))
            .toList();
      } else {
        throw Exception('검색 결과 조회 실패');
      }
    } on DioException catch (e) {
      debugPrint('❌ 검색 API 에러: ${e.response?.data}');
      throw Exception('검색 중 오류가 발생했습니다.');
    }
  }
}
