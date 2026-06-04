// 최초 작성자: 김채영
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:haenaem/core/network/dio_provider.dart';
import 'package:haenaem/features/notification/models/challenge_notification_settings_dto.dart';

part 'challenge_notification_repository.g.dart';

@riverpod
ChallengeNotificationRepository challengeNotificationRepository(
  ChallengeNotificationRepositoryRef ref,
) {
  final dio = ref.watch(dioProvider);
  return ChallengeNotificationRepository(dio);
}

class ChallengeNotificationRepository {
  final Dio _dio;
  ChallengeNotificationRepository(this._dio);

  // ── 설정 조회 ───────────────────────────────────────────

  /// GET /api/fcm/notification/challenge/{challengeId}/settings
  Future<ChallengeNotificationSettingsDto> getChallengeNotificationSettings(
    int challengeId,
  ) async {
    try {
      final response = await _dio.get(
        '/api/fcm/notification/challenge/$challengeId/settings',
      );
      return ChallengeNotificationSettingsDto.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception('챌린지 알림 설정 조회 실패: ${e.response?.statusCode}');
    }
  }

  // ── 설정 변경 ───────────────────────────────────────────

  /// PUT /api/fcm/notification/challenge/{challengeId}/all
  Future<bool> setChallengeAllNotification(
    int challengeId,
    bool enabled,
  ) async {
    try {
      await _dio.put(
        '/api/fcm/notification/challenge/$challengeId/all',
        data: {'enabled': enabled},
      );
      return true;
    } on DioException catch (e) {
      debugPrint('챌린지 전체 알림 설정 실패: ${e.response?.data}');
      return false;
    }
  }

  /// PUT /api/fcm/notification/challenge/{challengeId}/daily-reminder
  Future<bool> setChallengeReminderNotification(
    int challengeId,
    bool enabled,
  ) async {
    try {
      await _dio.put(
        '/api/fcm/notification/challenge/$challengeId/daily-reminder',
        data: {'enabled': enabled},
      );
      return true;
    } on DioException catch (e) {
      debugPrint('챌린지 리마인더 알림 설정 실패: ${e.response?.data}');
      return false;
    }
  }

  /// PUT /api/fcm/notification/challenge/{challengeId}/likes
  Future<bool> setChallengeLikesNotification(
    int challengeId,
    bool enabled,
  ) async {
    try {
      await _dio.put(
        '/api/fcm/notification/challenge/$challengeId/likes',
        data: {'enabled': enabled},
      );
      return true;
    } on DioException catch (e) {
      debugPrint('챌린지 좋아요 알림 설정 실패: ${e.response?.data}');
      return false;
    }
  }

  /// PUT /api/fcm/notification/challenge/{challengeId}/comments
  Future<bool> setChallengeCommentsNotification(
    int challengeId,
    bool enabled,
  ) async {
    try {
      await _dio.put(
        '/api/fcm/notification/challenge/$challengeId/comments',
        data: {'enabled': enabled},
      );
      return true;
    } on DioException catch (e) {
      debugPrint('챌린지 댓글 알림 설정 실패: ${e.response?.data}');
      return false;
    }
  }

  /// PUT /api/fcm/notification/challenge/{challengeId}/member-certification
  Future<bool> setChallengeVerificationNotification(
    int challengeId,
    bool enabled,
  ) async {
    try {
      await _dio.put(
        '/api/fcm/notification/challenge/$challengeId/member-certification',
        data: {'enabled': enabled},
      );
      return true;
    } on DioException catch (e) {
      debugPrint('챌린지 멤버 인증 알림 설정 실패: ${e.response?.data}');
      return false;
    }
  }
}
