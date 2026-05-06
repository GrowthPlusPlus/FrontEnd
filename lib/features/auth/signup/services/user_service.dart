// 최초 작성자 : 김채영
import 'package:flutter/material.dart';
import 'package:flutter_appauth/flutter_appauth.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

// 유저 정보와 관련된 API 통신을 담당하는 서비스 클래스
class UserService {
  final Dio _dio = Dio(BaseOptions(baseUrl: 'http://158.247.216.11:8080'));
  // final Dio _dio = Dio(
  //   BaseOptions(
  //     // 1. 서버 주소를 팀원이 준 ngrok 주소로 변경
  //     baseUrl: 'https://ungenially-undebatable-sindy.ngrok-free.dev',
  //     connectTimeout: const Duration(seconds: 30),
  //     receiveTimeout: const Duration(seconds: 30),
  //     // 2. ngrok 경고창 우회를 위한 헤더 필수 추가
  //     headers: {'ngrok-skip-browser-warning': 'true'},
  //   ),
  // );

  final _storage = const FlutterSecureStorage(); // 로컬 기기에 저장된 토큰을 읽기 위한 보안 저장소

  // 닉네임 변경 요청
  // 반환값: 성공 시 204, 실패 시 해당 에러 상태 코드(int) 반환
  Future<int?> updateNickname(String newNickname) async {
    try {
      final accessToken = await _storage.read(
        key: 'accessToken',
      ); // 요청 헤더에 담을 Access Token을 보안 저장소에서 불러옴

      final response = await _dio.patch(
        '/api/users/me/nickname',
        data: {"nickname": newNickname},
        options: Options(
          headers: {'Authorization': 'Bearer $accessToken'},
          contentType: Headers.jsonContentType,
        ),
      );

      // 204 No Content: 성공 시 상태 코드만 오기.
      return response.statusCode;
    } on DioException catch (e) {
      debugPrint("🚨 닉네임 변경 에러: ${e.response?.statusCode}");
      return e.response?.statusCode;
    }
  }
}
