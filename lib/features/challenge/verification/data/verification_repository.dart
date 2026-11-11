import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:http_parser/http_parser.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:haenaem/core/network/dio_provider.dart';
import 'package:haenaem/shared/models/post.dart';
import '../data/clip_verify_result.dart';

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
        return response.data?['tempImageId'];
      }
      return null;
    } on DioException catch (e) {
      return null;
    } catch (e) {
      return null;
    }
  }

  // 2단계: AI 챌린지 관련성 검사 (1장만 호출)
  Future<ClipVerifyResult> clipVerifyImage(
    int challengeId,
    int temporaryImageId,
  ) async {
    try {
      final response = await _dio.post(
        '/api/image/clip',
        data: {
          "challengeId": challengeId,
          "temporaryImageId": temporaryImageId,
        },
      );

      // 200/204 둘 다 바디가 있으면 바디의 passed 값을 그대로 신뢰
      if (response.data is Map) {
        final result = ClipVerifyResult.fromJson(
          response.data as Map<String, dynamic>,
        );

        return result;
      }

      // 바디가 없는 순수 204는 통과로 간주
      final bool passed =
          response.statusCode == 200 || response.statusCode == 204;
      return ClipVerifyResult(passed: passed);
    } on DioException catch (e) {
      if (e.response?.data is Map) {
        return ClipVerifyResult.fromJson(
          e.response!.data as Map<String, dynamic>,
        );
      }
      return const ClipVerifyResult(passed: false);
    } catch (e) {
      return const ClipVerifyResult(passed: false);
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
        // [변경] CertificationPostModel -> Post
        return Post.fromJson(response.data);
      } else {
        throw Exception('인증글 생성 실패: ${response.statusCode}');
      }
    } on DioException catch (e) {
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
        // [변경] CertificationPostModel -> Post
        return Post.fromJson(response.data);
      } else {
        throw Exception('수정 실패: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception(e.response?.data?['message'] ?? '수정 중 오류 발생');
    }
  }
}

@riverpod
VerificationRepository verificationRepository(VerificationRepositoryRef ref) {
  final dio = ref.watch(dioProvider);
  return VerificationRepository(dio);
}
