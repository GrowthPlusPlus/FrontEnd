// 최초 작성자: 김채영
import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:flutter_appauth/flutter_appauth.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart'; // 토큰 저장을 위해 필요
import 'package:haenaem/features/auth/signup/screens/signup_main_screen.dart';
import 'package:haenaem/features/main/screens/main_screen.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';

// 구글 OAuth 2.0 기반의 사용자 인증과 JWT 토큰의 생명주기(발급, 재발급, 파기)를 전담하는 클래스
// 서버로부터 받은 userStatus(NEW/ACTIVE)를 분석하여 사용자별 맞춤형 초기 화면 진입 경로를 제어
class AuthService {
  static const FlutterAppAuth _appAuth = FlutterAppAuth();
  static const _storage = FlutterSecureStorage(); // 보안 저장소

  // 구글 설정 정보
  static const String androidClientId =
      '433865217738-m3uqqdv9lumpf1ne8e3bkpsbtsa6919i.apps.googleusercontent.com';
  static const String customScheme =
      'com.googleusercontent.apps.433865217738-m3uqqdv9lumpf1ne8e3bkpsbtsa6919i';
  static const String redirectUri = '$customScheme:/oauth2redirect';

  // 카카오 설정 정보
  static const String kakaoRestApiKey = '9fdd13c0777c415d8fa4055b5b26a6c5';
  static const String kakaoNativeAppKey = '05a36f172ea2945260862834654385ea';
  // static const String kakaoRedirectUri =
  //     'https://hanaem.onrender.com/api/oauth/kakao/token';

  static const String kakaoRedirectUri =
      'https://hanaem.onrender.com/oauth/kakao/callback';

  //static const String kakaoRedirectUri =
  //'kakao9fdd13c0777c415d8fa4055b5b26a6c5://oauth';

  // ♥️ 로컬 서버로 테스트
  // static const String kakaoRedirectUri =
  //     'https://ungenially-undebatable-sindy.ngrok-free.dev/oauth/kakao/callback';

  static final Dio _dio = Dio(
    BaseOptions(baseUrl: 'https://hanaem.onrender.com'),
  );

  // ♥️ 로컬 서버로 테스트
  // static final Dio _dio = Dio(
  //   BaseOptions(
  //     baseUrl: 'https://ungenially-undebatable-sindy.ngrok-free.dev',
  //     headers: {
  //       'ngrok-skip-browser-warning': 'true',
  //       'Content-Type': 'application/json',
  //     },
  //   ),
  // );

  // 1. PKCE 쌍 생성 (RFC 7636 표준 방식)
  static Map<String, String> generatePkcePair() {
    // 1-1. Verifier 생성: 표준에 정의된 [A-Z, a-z, 0-9, -, ., _, ~] 문자만 사용
    const chars =
        'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-._~';
    final random = Random.secure();

    // 64자리의 무작위 문자열 생성 (표준 범위 43~128자 준수)
    final verifier = List.generate(
      64,
      (_) => chars[random.nextInt(chars.length)],
    ).join();
    debugPrint("🔒 verifier 생성: $verifier");

    // 1-2. Challenge 생성: Verifier를 SHA256으로 해싱 후 Base64Url 인코딩
    final bytes = utf8.encode(verifier); // plain string을 바이트로 변환
    final digest = sha256.convert(bytes); // SHA256 해싱

    // Base64UrlEncode 후 패딩(=) 제거 및 특수문자 치환
    final challenge = base64UrlEncode(
      digest.bytes,
    ).replaceAll('=', '').replaceAll('+', '-').replaceAll('/', '_');
    debugPrint('🔒 생성된 Challenge: $challenge');

    return {'codeVerifier': verifier, 'challenge': challenge};
  }

  // 2. 카카오 인증 URL 생성
  static String getKakaoAuthUrl(String challenge) {
    final clientId = kakaoRestApiKey;
    final redirectUri = Uri.encodeComponent(kakaoRedirectUri);

    return 'https://kauth.kakao.com/oauth/authorize'
        '?client_id=$clientId'
        '&redirect_uri=$redirectUri'
        '&response_type=code'
        '&code_challenge=$challenge'
        '&code_challenge_method=S256';
  }

  // 서버 통신 부분
  static Future<void> sendKakaoAuthToBackend({
    required String code,
    required String codeVerifier,
    required BuildContext context,
  }) async {
    try {
      debugPrint("🚀 서버로 카카오 인가 데이터 전송 시작...");
      debugPrint("서버 전송 verifier: $codeVerifier");

      final response = await _dio.post(
        '/api/oauth/kakao/token',
        data: {
          "code": code,
          "codeVerifier": codeVerifier, // 백엔드 변수명과 일치
          "fcmToken": "", // 현재는 빈 값으로 전송
        },
        options: Options(contentType: Headers.jsonContentType),
      );

      debugPrint("📥 서버 응답 코드: ${response.statusCode}");
      debugPrint("📥 서버 응답 데이터: ${response.data}");

      if (response.statusCode == 200 && response.data != null) {
        await _handleAuthResponse(response.data, context);
      }
    } on DioException catch (e) {
      debugPrint('🌐 서버 통신 에러: ${e.response?.statusCode}');
      debugPrint('내용: ${e.response?.data}');
    }
  }

  // 공통 응답 처리 (유저 상태에 따른 화면 전환)
  static Future<void> _handleAuthResponse(
    Map<String, dynamic> data,
    BuildContext context,
  ) async {
    final String? accessToken = data['accessToken'];
    final String? refreshToken = data['refreshToken'];
    final String? userStatus = data['userStatus'];

    if (accessToken != null) {
      await _storage.write(key: 'accessToken', value: accessToken);
      await _storage.write(key: 'refreshToken', value: refreshToken);
    }

    if (!context.mounted) return;

    if (userStatus == "NEW") {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const SignupMainScreen()),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const MainScreen()),
      );
    }
  }

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

  // 로그아웃: 서버의 리프레시 토큰을 삭제하고, 앱(클라이언트)의 모든 토큰을 삭제합니다.
  static Future<void> logout() async {
    try {
      // 1. 사전 준비 단계 (Access Token 확인)
      final String? accessToken = await _storage.read(key: 'accessToken');

      if (accessToken != null) {
        // 2. 서버 통신 단계 (추가된 기능)
        // 서버에게 "이 사용자의 리프레시 토큰을 지워줘"라고 요청합니다.
        debugPrint("🚀 서버 로그아웃 요청 (리프레시 토큰 삭제)");
        await _dio.delete(
          '/api/me/logout',
          options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
        );
      }
    } on DioException catch (e) {
      // 3. 예외 처리 단계
      // 네트워크가 끊겼거나 서버 에러가 나도 로그를 남기고 넘어갑니다.
      debugPrint("⚠️ 서버 로그아웃 통신 실패: ${e.response?.statusCode}");
    } finally {
      // 4. 로컬 정리 단계 (기존 logout기능)
      // 서버 성공 여부와 상관없이 '무조건' 내 폰의 토큰을 싹 지웁니다.
      await _storage.deleteAll();
      debugPrint("✅ 클라이언트 엑세스 토큰 및 모든 정보 삭제 완료");
    }
  }

  // 회원탈퇴: 서버에 탈퇴 요청을 보내고, 성공 시 로컬 데이터를 모두 삭제합니다.
  // 유저 정보 및 관련 데이터를 삭제하며, 통계성 데이터는 서버 측 로직에 따라 보존됩니다.
  static Future<void> withdraw() async {
    try {
      final String? accessToken = await _storage.read(key: 'accessToken');

      if (accessToken != null) {
        debugPrint("🗑️ 회원 탈퇴 요청 시작");
        // 서버에 계정 삭제 요청 (DELETE)
        // 리프레시 토큰뿐만 아니라 유저의 개인정보 등을 삭제하도록 서버에 명령합니다.
        final response = await _dio.delete(
          '/api/me',
          options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
        );
        // 📍 서버가 진짜 뭐라고 대답했는지 찍어보기
        debugPrint("📥 탈퇴 응답 데이터: ${response.data}");

        // 탈퇴 성공 후 클라이언트 데이터 정리
        await _storage.deleteAll();
        debugPrint("👋 회원 탈퇴 처리 및 로컬 데이터 정리 완료");
      }
    } on DioException catch (e) {
      debugPrint(
        '🌐 회원탈퇴 요청 실패: ${e.response?.statusCode} - ${e.response?.data}',
      );
      rethrow; // 실패 시 사용자에게 알림을 주기 위해 에러를 UI로 던짐
    } catch (e) {
      debugPrint('🚨 예상치 못한 탈퇴 에러: $e');
      rethrow;
    }
  }

  // 저장된 Access Token 가져오기
  static Future<String?> getAccessToken() async {
    return await _storage.read(key: 'accessToken');
  }
}
