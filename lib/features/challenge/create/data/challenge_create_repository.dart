// 최초 작성자 : 강선욱
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:haenaem/core/network/dio_provider.dart';
import 'package:haenaem/shared/models/challenge_base.dart';
import 'dart:io';
import 'package:http_parser/http_parser.dart';

part 'challenge_create_repository.g.dart';

class ChallengeCreateRepository {
  final Dio _dio;

  ChallengeCreateRepository(this._dio);

  // 1. 챌린지 생성 POST 요청
  Future<ChallengeBase> createChallenge(Map<String, dynamic> data) async {
    try {
      final response = await _dio.post('/api/challenges/create', data: data);
      debugPrint('📥 서버 생성 응답 원본: ${response.data}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        // ✅ 서버 응답의 'id'를 모델의 'challengeId'로 매핑
        final responseData = {
          'challengeId': response.data['id'],
          'title': response.data['title'] ?? '',
        };
        return ChallengeBase.fromJson(responseData);
      } else {
        throw Exception('챌린지 생성 실패');
      }
    } on DioException catch (e) {
      debugPrint('❌ 서버 상세 에러: ${e.response?.data}');
      throw Exception(
        '서버 에러: ${e.response?.statusCode} - ${e.response?.data['message'] ?? '잘못된 요청'}',
      );
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
        debugPrint('✅ 이미지 검증 및 임시 업로드 성공: ${response.data}');
        return response.data['tempImageId'];
      }
      return null;
    } on DioException catch (e) {
      debugPrint('❌ 이미지 검증 에러: ${e.response?.data}');
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
