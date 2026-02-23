// 최초 작성자 : 김채영
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:haenaem/core/network/dio_provider.dart';
part 'user_repository.g.dart';

class UserRepository {
  final Dio _dio;
  UserRepository(this._dio);

  // 프로필 변경 api
  Future<void> uploadProfileImage(File imageFile) async {
    try {
      final formData = FormData.fromMap({
        // 💡 명세서의 키값인 "image"를 파라미터명으로 사용
        "image": await MultipartFile.fromFile(
          imageFile.path,
          filename: "profile_${DateTime.now().millisecondsSinceEpoch}.jpg",
          contentType: MediaType('image', 'jpeg'), // 💡 http_parser 패키지 필요
        ),
      });

      final response = await _dio.post(
        '/api/users/me/profile-image',
        data: formData,
        options: Options(contentType: 'multipart/form-data'),
      );

      if (response.statusCode != 204) {
        throw Exception('이미지 업로드 실패');
      }
    } on DioException catch (e) {
      throw Exception('네트워크 에러: ${e.message}');
    }
  }

  // 💡 프로필 이미지 삭제 API
  Future<void> deleteProfileImage() async {
    try {
      final response = await _dio.delete('/api/users/me/profile-image');
      if (response.statusCode != 204) {
        throw Exception('이미지 삭제 실패');
      }
    } on DioException catch (e) {
      throw Exception('네트워크 에러: ${e.message}');
    }
  }

  // 닉네임 변경 api
  Future<void> updateNickname(String nickname) async {
    try {
      final response = await _dio.patch(
        '/api/users/me/nickname',
        data: {'nickname': nickname},
      );

      if (response.statusCode != 204) {
        throw Exception('닉네임 변경 실패');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 409) {
        throw Exception('DUPLICATE'); // 중복 에러 구분
      } else if (e.response?.statusCode == 400) {
        throw Exception('INVALID'); // 형식 에러 구분
      }
      throw Exception('네트워크 에러: ${e.message}');
    }
  }

  // 한줄소개 수정 api
  Future<void> updateIntroduction(String introduction) async {
    try {
      final response = await _dio.patch(
        '/api/users/me/introduction',
        data: {'introduction': introduction},
      );

      if (response.statusCode != 204 && response.statusCode != 200) {
        throw Exception('한 줄 소개 수정 실패');
      }
    } on DioException catch (e) {
      throw Exception('네트워크 에러: ${e.message}');
    }
  }
}

// 💡 UserRepository를 공급할 프로바이더
@riverpod
UserRepository userRepository(Ref ref) {
  final dio = ref.watch(dioProvider);
  return UserRepository(dio);
}
