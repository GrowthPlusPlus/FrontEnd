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
        // 1. 401 에러(토큰 만료) 발생 시
        if (e.response?.statusCode == 401) {
          debugPrint(
            '⚠️ [401 Detected] 토큰 만료됨. 재발급 시도 중... (Path: ${e.requestOptions.path})',
          );

          const storage = FlutterSecureStorage();
          final refreshToken = await storage.read(key: 'refreshToken');

          if (refreshToken != null) {
            try {
              final refreshDio = Dio(
                BaseOptions(baseUrl: e.requestOptions.baseUrl),
              );

              debugPrint('🔄 [Refresh] 리프레시 토큰으로 전송 중: $refreshToken');

              final response = await refreshDio.post(
                '/api/token',
                data: {"refreshToken": refreshToken},
              );

              // 성공 시 로그 (여기에 새 토큰 저장 로직이 추가되어야 합니다)
              debugPrint('✅ [Refresh Success] 새로운 토큰 발급 완료: ${response.data}');

              // TODO: 여기서 발급받은 새 토큰을 storage에 저장하고
              // 원래 실패했던 요청(e.requestOptions)을 다시 시도(dio.fetch)하는 로직이 필요합니다.
            } catch (err) {
              // 2. 재발급 과정에서 발생한 상세 에러 로그
              if (err is DioException) {
                debugPrint(
                  '❌ [Refresh Failed] 상태 코드: ${err.response?.statusCode}',
                );
                debugPrint('❌ [Refresh Failed] 서버 메시지: ${err.response?.data}');
                debugPrint('❌ [Refresh Failed] 에러 타입: ${err.type}');
              } else {
                debugPrint('❌ [Refresh Failed] 알 수 없는 에러: $err');
              }
            }
          } else {
            debugPrint('🚫 [Refresh Aborted] 저장된 리프레시 토큰이 없습니다.');
          }
        }
        return handler.next(e);
      },
    ),
  );

  return dio;
}
