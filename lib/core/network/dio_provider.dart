// 최초 작성자 : 김채영
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:haenaem/features/auth/services/auth_service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'dio_provider.g.dart';

// 토큰 주입과 네트워크 설정을 모든 레포지토리에서 공유하도록 함

@riverpod
Dio dio(DioRef ref) {
  final dio = Dio(
    BaseOptions(
      baseUrl: 'http://158.247.216.11:8080',
      connectTimeout: const Duration(seconds: 5),
    ),
  );

  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) async {
        const storage = FlutterSecureStorage();
        final String? token = await storage.read(key: 'accessToken');
        // 💡 [디버깅 로그] 저장소에서 꺼낸 생생한 토큰 상태를 확인합니다.
        debugPrint('🕵️‍♂️ [Interceptor] Storage Read (accessToken): $token');
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
      onError: (DioException e, handler) async {
        if (e.response?.statusCode == 401) {
          const storage = FlutterSecureStorage();
          final refreshToken = await storage.read(key: 'refreshToken');
          if (refreshToken != null) {
            try {
              // 🎯 토큰 갱신 전용 가벼운 Dio 생성 (인터셉터 없음)
              final refreshDio = Dio(
                BaseOptions(baseUrl: e.requestOptions.baseUrl),
              );

              final response = await refreshDio.post(
                '/api/token',
                data: {"refreshToken": refreshToken},
              );
            } catch (err) {
              // 재발급 실패 시 로그아웃 처리
              debugPrint("재발급 실패!");
            }
          }
        }
        return handler.next(e);
      },
    ),
  );

  return dio;
}
