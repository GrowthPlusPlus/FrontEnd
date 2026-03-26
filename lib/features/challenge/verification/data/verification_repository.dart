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

  // 이미지를 서버에 임시 업로드하고 AI 검증을 요청
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
        return response.data?['tempImageId'];
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
