import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:haenaem/shared/models/challenge_detail.dart';
import 'package:haenaem/core/network/dio_provider.dart';

part 'challenge_detail_repository.g.dart';

// 최초 작성자 : 강선욱
class ChallengeDetailRepository {
  final Dio _dio;

  ChallengeDetailRepository(this._dio);

  // 챌린지 상세 정보 조회
  Future<ChallengeDetail> getChallengeDetail(int challengeId) async {
    try {
      final response = await _dio.get('/api/challenge/$challengeId');

      if (response.statusCode == 200) {
        return ChallengeDetail.fromJson(response.data as Map<String, dynamic>);
      } else {
        throw Exception('챌린지 상세 조회 실패');
      }
    } on DioException catch (e) {
      debugPrint('❌ 챌린지 상세 API 에러: ${e.response?.data}');
      throw Exception('챌린지 정보를 불러오지 못했습니다.');
    }
  }
}

@riverpod
ChallengeDetailRepository challengeDetailRepository(Ref ref) {
  final dio = ref.watch(dioProvider);
  return ChallengeDetailRepository(dio);
}
