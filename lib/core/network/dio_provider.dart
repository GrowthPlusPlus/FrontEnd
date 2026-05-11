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
      connectTimeout: const Duration(seconds: 45),
      receiveTimeout: const Duration(seconds: 45),
    ),
  );

  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) async {
        const storage = FlutterSecureStorage();
        final String? token = await storage.read(key: 'accessToken');
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
      onError: (DioException e, handler) async {
        if (e.response?.statusCode == 401) {
          final newToken = await AuthService.refreshTokens();
          if (newToken != null) {
            e.requestOptions.headers['Authorization'] = 'Bearer $newToken';
            final response = await dio.fetch(e.requestOptions);
            return handler.resolve(response);
          }
        }
        return handler.next(e);
      },
    ),
  );

  return dio;
}
