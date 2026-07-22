import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:http_parser/http_parser.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:haenaem/core/network/dio_provider.dart';
import 'package:haenaem/shared/models/post.dart'; // [추가] 통합된 Post 모델 임포트

part 'verification_repository.g.dart';

class VerificationRepository {
  final Dio _dio;

  VerificationRepository(this._dio);

  // 1단계: 업로드만 (크기/포맷/손상 검사 + tempImageId 발급)
  Future<int?> uploadImage(File imageFile, int challengeId) async {
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

      // ✅ 204 = 성공, passed 필드 없어짐 — 상태 코드만으로 판단
      if (response.statusCode == 204 || response.statusCode == 200) {
        debugPrint('✅ 이미지 업로드 성공: ${response.data}');
        return response.data?['tempImageId'];
      }
      return null;
    } on DioException catch (e) {
      debugPrint('❌ 이미지 업로드 에러: ${e.response?.data}');
      return null;
    } catch (e) {
      debugPrint('❌ 알 수 없는 에러: $e');
      return null;
    }
  }

  // 2단계: AI 챌린지 관련성 검사 (1장만 호출)
  Future<bool> clipVerifyImage(int challengeId, int temporaryImageId) async {
    try {
      debugPrint(
        '🔍 [CLIP API] 요청: challengeId=$challengeId, tempId=$temporaryImageId',
      );
      final response = await _dio.post(
        '/api/image/clip',
        data: {
          "challengeId": challengeId,
          "temporaryImageId": temporaryImageId,
        },
      );

      debugPrint('🔍 [CLIP API] 응답 상태코드: ${response.statusCode}'); // ✅ 추가
      debugPrint('🔍 [CLIP API] 응답 바디: ${response.data}');

      final String? result = response.data?.toString();
      final bool passed = result == 'PASS' || result == 'REVIEW';

      debugPrint(
        passed
            ? '✅ CLIP 검사 통과 (result: $result)'
            : '❌ CLIP 검사 실패 (result: $result)',
      );
      return passed;
    } on DioException catch (e) {
      // 400이 DioException으로 잡힐 수 있음
      debugPrint(
        '🔍 [CLIP API] DioException: ${e.response?.statusCode} / ${e.response?.data}',
      );
      return false;
    } catch (e) {
      debugPrint('🔍 [CLIP API] 알 수 없는 에러: $e');
      return false;
    }
  }

  // 검증된 이미지 ID들과 함께 인증글을 최종 생성
  Future<Post> createArticle({
    required int challengeId,
    required String content,
    required List<int> tempImageIds,
  }) async {
    try {
      final response = await _dio.post(
        '/api/articles',
        data: {
          "content": content,
          "challengeId": challengeId,
          "tempImageIds": tempImageIds,
        },
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        debugPrint('📦 서버 응답 데이터: ${response.data}');

        // [변경] CertificationPostModel -> Post
        return Post.fromJson(response.data);
      } else {
        throw Exception('인증글 생성 실패: ${response.statusCode}');
      }
    } on DioException catch (e) {
      debugPrint('❌ 인증글 생성 에러: ${e.response?.data}');
      throw Exception(e.response?.data?['message'] ?? '게시글 업로드 실패');
    }
  }

  // 기존 인증글을 수정합니다.
  Future<Post> updateArticle({
    required int postId,
    required String content,
    required List<int> deleteImageIds,
    required List<int> tempImageIds,
  }) async {
    try {
      final response = await _dio.patch(
        '/api/articles/$postId',
        data: {
          "content": content,
          "deleteImageIds": deleteImageIds,
          "tempImageIds": tempImageIds,
        },
      );

      if (response.statusCode == 200) {
        debugPrint('✅ 인증글 수정 성공: ${response.data}');
        // [변경] CertificationPostModel -> Post
        return Post.fromJson(response.data);
      } else {
        throw Exception('수정 실패: ${response.statusCode}');
      }
    } on DioException catch (e) {
      debugPrint('❌ 수정 에러 상세: ${e.response?.data}');
      throw Exception(e.response?.data?['message'] ?? '수정 중 오류 발생');
    }
  }
}

@riverpod
VerificationRepository verificationRepository(VerificationRepositoryRef ref) {
  final dio = ref.watch(dioProvider);
  return VerificationRepository(dio);
}
