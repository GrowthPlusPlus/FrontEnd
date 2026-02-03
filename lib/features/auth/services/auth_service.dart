// 최초 작성자: 김채영
import 'package:flutter/material.dart';
import 'package:flutter_appauth/flutter_appauth.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart'; // 토큰 저장을 위해 필요
import 'package:haenaem/features/auth/signup/screens/signup_main_screen.dart';
import 'package:haenaem/features/main/screens/main_screen.dart';

// 구글 OAuth 2.0 기반의 사용자 인증과 JWT 토큰의 생명주기(발급, 재발급, 파기)를 전담하는 클래스
// 서버로부터 받은 userStatus(NEW/ACTIVE)를 분석하여 사용자별 맞춤형 초기 화면 진입 경로를 제어
class AuthService {
  static const FlutterAppAuth _appAuth = FlutterAppAuth();
  static const _storage = FlutterSecureStorage(); // 보안 저장소

  // OAuth 2.0 설정을 위한 Google 클라이언트 정보
  static const String androidClientId =
      '433865217738-m3uqqdv9lumpf1ne8e3bkpsbtsa6919i.apps.googleusercontent.com';
  static const String customScheme =
      'com.googleusercontent.apps.433865217738-m3uqqdv9lumpf1ne8e3bkpsbtsa6919i';
  static const String redirectUri = '$customScheme:/oauth2redirect';

  static final Dio _dio = Dio(
    BaseOptions(baseUrl: 'https://hanaem.onrender.com'),
  );

  // 구글로부터 인가 코드 획득
  static Future<Map<String, String>?> signInWithGoogle() async {
    try {
      final AuthorizationResponse result = await _appAuth.authorize(
        AuthorizationRequest(
          androidClientId,
          redirectUri,
          discoveryUrl:
              'https://accounts.google.com/.well-known/openid-configuration',
          scopes: ['email', 'profile', 'openid'],
          promptValues: ['select_account'],
        ),
      );

      if (result.authorizationCode != null && result.codeVerifier != null) {
        return {
          "code": result.authorizationCode!,
          "codeVerifier": result.codeVerifier!,
        };
      }
    } catch (e) {
      debugPrint('🚨 구글 인증 에러: $e');
    }
    return null;
  }

  // 서버에 코드를 보내고 서비스 전용 토큰 받기
  static Future<void> sendTokenToBackend({
    required String code,
    required String codeVerifier,
    required BuildContext context,
  }) async {
    try {
      debugPrint(
        "🚀 서버 요청 데이터: code=$code, codeVerifier=$codeVerifier, clientId=$androidClientId",
      );

      final response = await _dio.post(
        '/api/oauth/google/token',
        data: {
          "code": code,
          "codeVerifier": codeVerifier,
          "clientId": androidClientId,
        },
        options: Options(contentType: Headers.jsonContentType),
      );

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data;
        final String? accessToken = data['accessToken'];
        final String? refreshToken = data['refreshToken'];
        final String? userStatus = data['userStatus'];

        // 받은 토큰을 기기에 안전하게 저장
        if (accessToken != null) {
          await _storage.write(key: 'accessToken', value: accessToken);
          await _storage.write(key: 'refreshToken', value: refreshToken);
        }

        debugPrint("🎉 로그인 성공! 유저 상태: $userStatus");

        if (!context.mounted) return;

        // 유저 상태에 따른 화면 전환
        if (userStatus == "NEW") {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const SignupMainScreen()),
          );
        } else if (userStatus == "ACTIVE") {
          // 기존 유저 -> 홈 화면(MainScreen)으로 바로 이동
          debugPrint("✅ 기존 유저: 홈 화면으로 이동합니다.");
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const MainScreen()),
          );
        }
      }
    } on DioException catch (e) {
      debugPrint(
        '🌐 서버 통신 에러: ${e.response?.statusCode} - ${e.response?.data ?? e.message}',
      );
    } catch (e) {
      debugPrint('🚨 예상치 못한 에러: $e');
    }
  }

  // 유효한 Refresh Token으로 새로운 Access Token을 발급 (로그인 유지)
  static Future<String?> refreshTokens() async {
    try {
      // 저장소에서 Refresh Token 읽기
      final String? refreshToken = await _storage.read(key: 'refreshToken');

      if (refreshToken == null) return null;

      debugPrint("🔄 토큰 재발급 요청 시작...");
      final response = await _dio.post(
        '/api/token',
        data: {"refreshToken": refreshToken},
        options: Options(contentType: Headers.jsonContentType),
      );

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data;
        final String newAccess = data['accessToken'];
        final String newRefresh = data['refreshToken'];

        // 새로운 토큰으로 업데이트
        await _storage.write(key: 'accessToken', value: newAccess);
        await _storage.write(key: 'refreshToken', value: newRefresh);

        debugPrint("✅ 토큰 재발급 성공");
        return data['accessToken'];
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        debugPrint("🚨 리프레시 토큰 만료: 다시 로그인 필요");
        await logout(); // 만료된 토큰 청소
      }
    }
    return null;
  }

  // 저장된 모든 보안 토큰을 삭제하여 초기 상태로 복구
  static Future<void> logout() async {
    await _storage.deleteAll();
    debugPrint("🧹 모든 토큰 삭제 완료");
  }

  // 저장된 Access Token 가져오기
  static Future<String?> getAccessToken() async {
    return await _storage.read(key: 'accessToken');
  }
}
