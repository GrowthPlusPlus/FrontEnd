// 최초 작성자 : 김채영
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:haenaem/core/network/dio_provider.dart';
import 'package:flutter/foundation.dart';

part 'challenge_preview_repository.g.dart';

class ChallengePreviewRepository {
  final Dio _dio;
  ChallengePreviewRepository(this._dio);

  /// 챌린지 이름 사전 검사
  /// AI가 이 이름/주제로 사진 검증(CLIP 검사)을 자동으로 수행할 수 있는지 여부를 안내용으로 반환
  /// (백엔드 확인 결과, true/false 모두 정상 응답이며 생성 로직 자체를 막을 필요는 없음)
  Future<bool> checkPreview(String title) async {
    debugPrint('🔍 [Preview API] 요청 title: "$title"');

    try {
      final response = await _dio.post(
        '/api/challenge/preview',
        data: {'title': title},
      );

      final data = response.data;
      if (data is Map<String, dynamic>) {
        return data['autoVerifiable'] as bool? ?? true;
      }
      return true;
    } on DioException catch (e) {
      debugPrint('🔍 [Preview API] 500 에러 응답 바디: ${e.response?.data}');
      throw Exception('네트워크 에러: ${e.message}');
    }
  }
}

@riverpod
ChallengePreviewRepository challengePreviewRepository(Ref ref) {
  final dio = ref.watch(dioProvider);
  return ChallengePreviewRepository(dio);
}
