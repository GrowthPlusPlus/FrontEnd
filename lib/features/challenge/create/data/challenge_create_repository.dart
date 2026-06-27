// 최초 작성자 : 강선욱
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:haenaem/core/network/dio_provider.dart';
import '../models/created_response.dart';
import 'dart:io';
import 'package:http_parser/http_parser.dart';

part 'challenge_create_repository.g.dart';

class ChallengeCreateRepository {
  final Dio _dio;

  ChallengeCreateRepository(this._dio);

  // 1. 챌린지 생성 POST 요청
  Future<CreatedResponse> createChallenge(Map<String, dynamic> data) async {
    try {
      final response = await _dio.post('/api/challenges/create', data: data);
      debugPrint('📥 서버 생성 응답 원본: ${response.data}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        // ✅ 서버 응답 원본을 그대로 CreatedResponse.fromJson에 전달
        // 모델 내부에서 super(id, title)와 고유 필드들을 알아서 매핑합니다.
        return CreatedResponse.fromJson(response.data);
      } else {
        throw Exception('챌린지 생성 실패 (상태 코드: ${response.statusCode})');
      }
    } on DioException catch (e) {
      debugPrint('❌ 서버 상세 에러: ${e.response?.data}');
      throw Exception(
        '서버 에러: ${e.response?.statusCode} - ${e.response?.data['message'] ?? '잘못된 요청'}',
      );
    } catch (e) {
      // 💡 여기서 모델 파싱 에러(타입 불일치 등)가 잡힙니다.
      debugPrint('❌ 데이터 파싱 에러 발생: $e');
      throw Exception('데이터 처리 중 오류가 발생했습니다.');
    }
  }

  // 2. 인증 사진 검증 (생성 과정에서 AI 검증 등이 필요한 경우 사용)
  Future<int?> verifyImage(File imageFile, int challengeId) async {
    try {
      final formData = FormData.fromMap({
        "image": await MultipartFile.fromFile(
          imageFile.path,
          filename: imageFile.path.split('/').last,
          contentType: MediaType('image', 'jpeg'),
        ),
      });

      final response = await _dio.post(
        '/api/image/verify',
        data: formData,
        queryParameters: {'challengeId': challengeId},
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        debugPrint('✅ 이미지 요청 처리됨: ${response.data}');

        final String? passed = response.data?['passed'];
        final int? tempImageId = response.data?['tempImageId'];

        // 'PASS'일 때만 성공으로 인정
        if (passed == 'PASS') {
          return tempImageId;
        }

        debugPrint('❌ 이미지 검증 통과 못함 (passed: $passed)');
        return null;
      }
      return null;
    } on DioException catch (e) {
      debugPrint('❌ 이미지 검증 에러: ${e.response?.data}');
      return null;
    } catch (e) {
      debugPrint('❌ 알 수 없는 에러 발생: $e');
      return null;
    }
  }
}

// Provider 설정
@riverpod
ChallengeCreateRepository challengeCreateRepository(
  ChallengeCreateRepositoryRef ref,
) {
  final dio = ref.watch(dioProvider);
  return ChallengeCreateRepository(dio);
}
