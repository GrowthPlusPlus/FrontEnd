// 최초 작성자: 김채영
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:haenaem/core/network/dio_provider.dart';
import 'package:haenaem/features/notification/models/push_notification_settings_dto.dart';

part 'push_notification_repository.g.dart';

@riverpod
PushNotificationRepository pushNotificationRepository(
  PushNotificationRepositoryRef ref,
) {
  final dio = ref.watch(dioProvider);
  return PushNotificationRepository(dio);
}

class PushNotificationRepository {
  final Dio _dio;
  PushNotificationRepository(this._dio);

  // ── 설정 조회 ───────────────────────────────────────────

  /// GET /api/fcm/notification/settings
  Future<PushNotificationSettingsDto> getNotificationSettings() async {
    try {
      final response = await _dio.get('/api/fcm/notification/settings');
      return PushNotificationSettingsDto.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception('알림 설정 조회 실패: ${e.response?.statusCode}');
    }
  }

  // ── 전체 알림 ────────────────────────────────────────────

  /// PUT /api/fcm/notification/all
  Future<bool> setAllNotification(bool enabled) async {
    try {
      await _dio.put('/api/fcm/notification/all', data: {'enabled': enabled});
      return true;
    } on DioException catch (e) {
      debugPrint('전체 알림 설정 실패: ${e.response?.data}');
      return false;
    }
  }

  // ── 소셜 알림 ────────────────────────────────────────────

  /// PUT /api/fcm/notification/all-likes
  Future<bool> setAllLikesNotification(bool enabled) async {
    try {
      await _dio.put(
        '/api/fcm/notification/all-likes',
        data: {'enabled': enabled},
      );
      return true;
    } on DioException catch (e) {
      debugPrint('전체 좋아요 알림 설정 실패: ${e.response?.data}');
      return false;
    }
  }

  /// PUT /api/fcm/notification/all-comments
  Future<bool> setAllCommentsNotification(bool enabled) async {
    try {
      await _dio.put(
        '/api/fcm/notification/all-comments',
        data: {'enabled': enabled},
      );
      return true;
    } on DioException catch (e) {
      debugPrint('전체 댓글 알림 설정 실패: ${e.response?.data}');
      return false;
    }
  }

  /// PUT /api/fcm/notification/friend
  Future<bool> setFriendNotification(bool enabled) async {
    try {
      await _dio.put(
        '/api/fcm/notification/friend',
        data: {'enabled': enabled},
      );
      return true;
    } on DioException catch (e) {
      debugPrint('친구 알림 설정 실패: ${e.response?.data}');
      return false;
    }
  }

  /// PUT /api/fcm/notification/all-member-certification
  Future<bool> setAllMemberCertificationNotification(bool enabled) async {
    try {
      await _dio.put(
        '/api/fcm/notification/all-member-certification',
        data: {'enabled': enabled},
      );
      return true;
    } on DioException catch (e) {
      debugPrint('전체 멤버 인증 알림 설정 실패: ${e.response?.data}');
      return false;
    }
  }

  // ── 챌린지 섹션 알림 ─────────────────────────────────────

  /// PUT /api/fcm/notification/challenge-invite
  Future<bool> setChallengeInviteNotification(bool enabled) async {
    try {
      await _dio.put(
        '/api/fcm/notification/challenge-invite',
        data: {'enabled': enabled},
      );
      return true;
    } on DioException catch (e) {
      debugPrint('챌린지 초대 알림 설정 실패: ${e.response?.data}');
      return false;
    }
  }

  /// PUT /api/fcm/notification/motivation-message
  Future<bool> setMotivationNotification(bool enabled) async {
    try {
      await _dio.put(
        '/api/fcm/notification/motivation-message',
        data: {'enabled': enabled},
      );
      return true;
    } on DioException catch (e) {
      debugPrint('동기부여 알림 설정 실패: ${e.response?.data}');
      return false;
    }
  }

  /// PUT /api/fcm/notification/daily-reminder
  Future<bool> setDailyReminderNotification(bool enabled) async {
    try {
      await _dio.put(
        '/api/fcm/notification/daily-reminder',
        data: {'enabled': enabled},
      );
      return true;
    } on DioException catch (e) {
      debugPrint('일일 리마인더 알림 설정 실패: ${e.response?.data}');
      return false;
    }
  }

  // ── 실패 방지 리마인더 시간 ──────────────────────────────

  /// GET /api/notification/reminder/time
  Future<String?> getWeeklyReminderTime() async {
    try {
      final response = await _dio.get('/api/notification/reminder/time');
      final time = response.data['notificationTime'];
      if (time == null) return null;

      if (time is String) {
        return time.substring(0, 5); // "21:00:00" → "21:00"
      } else if (time is Map) {
        final hour = time['hour'] as int;
        final minute = time['minute'] as int;
        return '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
      }
      return null;
    } on DioException catch (e) {
      throw Exception('실패 방지 리마인더 시간 조회 실패: ${e.response?.statusCode}');
    }
  }

  /// PUT /api/notification/reminder/time
  Future<bool> setWeeklyReminderTime(String timeString) async {
    try {
      debugPrint('📤 실패 방지 리마인더 시간 전송: $timeString'); // ✅ 추가
      await _dio.put(
        '/api/notification/reminder/time',
        data: {'notificationTime': timeString},
      );
      debugPrint('✅ 실패 방지 리마인더 시간 설정 성공'); // ✅ 추가
      return true;
    } on DioException catch (e) {
      debugPrint('❌ 실패 방지 리마인더 시간 설정 실패: ${e.response?.data}');
      debugPrint('❌ 상태 코드: ${e.response?.statusCode}');
      return false;
    }
  }
}
