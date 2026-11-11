// 최초 작성자 : 김채영
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:haenaem/features/auth/services/auth_service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'dio_provider.g.dart';

// 토큰 주입과 네트워크 설정을 모든 레포지토리에서 공유하도록 함

//const _baseUrl = 'http://158.247.216.11:8080';
// ❤️❤️❤️❤️❤️❤️❤️❤️❤️❤️❤️❤️❤️❤️❤️❤️❤️
const _baseUrl = 'https://haenaem1.duckdns.org';
const _connectTimeout = Duration(seconds: 5);

@riverpod
Dio dio(DioRef ref) {
  const storage = FlutterSecureStorage();
  final dio = Dio(
    BaseOptions(baseUrl: _baseUrl, connectTimeout: _connectTimeout),
  );

  // 🔒 진행 중인 토큰 재발급 작업.
  // 여러 요청이 동시에 401을 받아도 재발급은 딱 한 번만 하고, 모두 같은 결과를 기다립니다.
  Future<String?>? refreshing;

  Future<String?> refreshAccessToken() async {
    final refreshToken = await storage.read(key: 'refreshToken');
    if (refreshToken == null) return null;

    try {
      // 🎯 토큰 갱신 전용 가벼운 Dio (인터셉터 없음)
      final refreshDio = Dio(
        BaseOptions(baseUrl: _baseUrl, connectTimeout: _connectTimeout),
      );
      final response = await refreshDio.post(
        '/api/token',
        data: {"refreshToken": refreshToken},
      );

      // 서버 응답 키값이 다르면 여기를 수정하세요
      final newAccessToken = response.data['accessToken'] as String?;
      final newRefreshToken = response.data['refreshToken'] as String?;
      if (newAccessToken == null) {
        return null;
      }

      await storage.write(key: 'accessToken', value: newAccessToken);
      if (newRefreshToken != null) {
        await storage.write(key: 'refreshToken', value: newRefreshToken);
      }

      return newAccessToken;
    } on DioException catch (err) {
      final status = err.response?.statusCode;

      // 서버가 refresh token 자체를 거부했을 때만 토큰 삭제.
      // 네트워크 끊김·타임아웃 같은 일시적 오류로 로그아웃시키지 않기 위함.
      if (status == 401 || status == 403) {
        await storage.delete(key: 'accessToken');
        await storage.delete(key: 'refreshToken');
      }
      return null;
    }
  }

  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) async {
        final String? token = await storage.read(key: 'accessToken');

        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        } else {
          // 💡 [핵심 수정] 로그아웃 등으로 토큰이 없을 때는 기존 Authorization 헤더를 반드시 삭제!
          options.headers.remove('Authorization');
        }
        return handler.next(options);
      },
      onError: (DioException e, handler) async {
        final status = e.response?.statusCode;
        final alreadyRetried = e.requestOptions.extra['retried'] == true;

        // 401이 아니거나, 이미 한 번 재시도한 요청이면 그대로 에러 전달 (무한 루프 방지)
        if (status != 401 || alreadyRetried) {
          return handler.next(e);
        }

        // 이미 재발급 중이면 그 결과를 같이 기다리고, 아니면 새로 시작
        refreshing ??= refreshAccessToken().whenComplete(() {
          refreshing = null;
        });
        final newAccessToken = await refreshing;

        if (newAccessToken == null) {
          // 재발급 불가 → UI에서 이 401을 받아 로그인 화면으로 보내면 됩니다
          return handler.next(e);
        }

        final options = e.requestOptions
          ..headers['Authorization'] = 'Bearer $newAccessToken'
          ..extra['retried'] = true;

        // 재시도 실패는 재발급 실패와 분리해서 처리 (토큰을 지우지 않음)
        try {
          final retryResponse = await dio.fetch(options);
          return handler.resolve(retryResponse);
        } on DioException catch (retryError) {
          return handler.next(retryError);
        }
      },
    ),
  );

  return dio;
}
