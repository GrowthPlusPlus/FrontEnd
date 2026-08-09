// 최초 작성자 : 김채영
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:haenaem/core/network/dio_provider.dart';
import 'package:flutter/foundation.dart';
import '../models/challenge_preview_response.dart';

part 'challenge_preview_repository.g.dart';

class ChallengePreviewRepository {
  final Dio _dio;
  ChallengePreviewRepository(this._dio);

  /// 챌린지 이름 사전 검사
  /// AI가 이 이름/주제로 사진 검증(CLIP 검사)을 자동으로 수행할 수 있는지 여부를 안내용으로 반환
  /// (백엔드 확인 결과, true/false 모두 정상 응답이며 생성 로직 자체를 막을 필요는 없음)
  Future<ChallengePreviewResponse> checkPreview(String title) async {
    debugPrint('🔍 [Preview API] 요청 title: "$title"');

    try {
      final response = await _dio.post(
        '/api/challenge/preview',
        data: {'title': title},
      );

      debugPrint('🔍 [Preview API] 응답 상태코드: ${response.statusCode}');
      debugPrint('🔍 [Preview API] 응답 바디: ${response.data}');

      if (response.data is Map<String, dynamic>) {
        return ChallengePreviewResponse.fromJson(
          response.data as Map<String, dynamic>,
        );
      }
      // 바디 없는 순수 204라면 기본적으로 자동 검증 가능하다고 간주
      return const ChallengePreviewResponse(autoVerifiable: true);
    } on DioException catch (e) {
      debugPrint(
        '🔍 [Preview API] 상태코드: ${e.response?.statusCode} / 바디: ${e.response?.data}',
      );

      // ✅ 400은 "자동 검증 어려움"이라는 정상 판정 — 예외로 던지지 않고 결과로 반환
      if (e.response?.statusCode == 400 && e.response?.data is Map) {
        return ChallengePreviewResponse.fromJson(
          e.response!.data as Map<String, dynamic>,
        );
      }

      // 그 외(500, 타임아웃, 네트워크 끊김 등)만 진짜 에러로 처리
      throw Exception('네트워크 에러: ${e.message}');
    }
  }
}

@riverpod
ChallengePreviewRepository challengePreviewRepository(Ref ref) {
  final dio = ref.watch(dioProvider);
  return ChallengePreviewRepository(dio);
}
