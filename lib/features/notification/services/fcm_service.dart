// 최초 작성자 : 김채영
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:dio/dio.dart';
import 'package:haenaem/core/network/dio_provider.dart'; // dioProvider 경로
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter/foundation.dart';
part 'fcm_service.g.dart'; // build_runner 실행 후 생성됨

// 푸시 알림을 위한 fcm 토큰 전송 로직
class FcmService {
  final Dio _dio;
  FcmService(this._dio);

  Future<void> requestNotificationPermission() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;

    // FCM 권한 요청 코드
    Future<void> setupInteractedMessage() async {
      FirebaseMessaging messaging = FirebaseMessaging.instance;

      // 권한 요청 팝업 띄우기
      NotificationSettings settings = await messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      debugPrint('User granted permission: ${settings.authorizationStatus}');
    }

    // and 알림 권한 요청
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      debugPrint('✅ 사용자가 알림 권한을 허용했습니다.');
    } else if (settings.authorizationStatus ==
        AuthorizationStatus.provisional) {
      debugPrint('✅ 사용자가 임시 알림 권한을 허용했습니다.');
    } else {
      debugPrint('❌ 사용자가 알림 권한을 거절했습니다.');
    }
  }

  // ios 권한 요청
  // TODO: xcode 설정 필요, apple 개발자 포털 설정 필요 (유료 개발자 계정 필요함)
  Future<void> requestIOSPermission() async {
    final messaging = FirebaseMessaging.instance;

    final settings = await messaging.requestPermission(
      alert: true, // 화면에 알림 배너 표시
      announcement: false,
      badge: true, // 앱 아이콘에 숫자(배지) 표시
      carPlay: false,
      criticalAlert: false,
      provisional: false, // 임시 권한 (사용자에게 묻지 않고 조용히 보냄)
      sound: true, // 알림 소리 재생
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      debugPrint('🍏 [iOS] 알림 권한 허용됨');
    } else {
      debugPrint('🍎 [iOS] 알림 권한 거절됨');
    }
  }

  Future<bool> updateAllNotificationStatus(bool enabled) async {
    try {
      debugPrint("📤 [FCM] 전체 알림 설정 변경 요청: $enabled");

      final response = await _dio.put(
        '/api/fcm/notification/all',
        data: {'enabled': enabled},
      );

      if (response.statusCode == 200) {
        debugPrint("✅ [FCM] 전체 알림 설정 변경 성공");
        return true;
      }
      return false;
    } catch (e) {
      debugPrint("🚨 [FCM] 전체 알림 설정 변경 실패: $e");
      return false;
    }
  }

  // 1. FCM 토큰 등록 및 업데이트 (PUT)
  Future<void> updateFcmToken() async {
    try {
      debugPrint("🚀 [FCM] 토큰 업데이트 시작...");

      // Firebase SDK에서 토큰 가져오기
      String? token = await FirebaseMessaging.instance.getToken();

      if (token == null) {
        debugPrint("❌ [FCM] 토큰 생성 실패 (null)");
        return;
      }

      debugPrint("📡 [FCM] 생성된 토큰: $token");
      debugPrint("📤 [FCM] 전송 경로: PUT /api/fcm/token");

      // 백엔드 API 호출
      final response = await _dio.put(
        '/api/fcm/token',
        data: {'fcmToken': token},
      );

      // 성공 응답 확인
      if (response.statusCode == 200) {
        debugPrint("✅ [FCM] 서버 등록 성공! (Status: ${response.statusCode})");
      } else {
        debugPrint("⚠️ [FCM] 서버 응답 이상 (Status: ${response.statusCode})");
      }
    } on DioException catch (e) {
      debugPrint("🚨 [FCM] Dio 에러 발생!");
      debugPrint("에러 코드: ${e.response?.statusCode}");
      debugPrint("에러 메시지: ${e.message}");
      debugPrint("서버 응답 내용: ${e.response?.data}");
    } catch (e) {
      debugPrint("🚨 [FCM] 예상치 못한 에러: $e");
    }
  }

  // 2. FCM 토큰 삭제 (DELETE)
  Future<void> deleteFcmToken() async {
    try {
      debugPrint("🗑️ [FCM] 서버 토큰 삭제 요청 중...");
      final response = await _dio.delete('/api/fcm/token');

      if (response.statusCode == 204 || response.statusCode == 200) {
        debugPrint("✅ [FCM] 서버 토큰 삭제 완료");
      }
    } catch (e) {
      debugPrint("🚨 [FCM] 토큰 삭제 실패: $e");
    }
  }

  // 3. 토큰 갱신 리스너
  void setTokenRefreshListener() {
    FirebaseMessaging.instance.onTokenRefresh.listen((newToken) async {
      debugPrint("🔄 [FCM] 토큰 갱신됨: $newToken");
      await _dio.put('/api/fcm/token', data: {'fcmToken': newToken});
    });
  }
}

@riverpod
FcmService fcmService(FcmServiceRef ref) {
  final dio = ref.watch(dioProvider);
  return FcmService(dio);
}
