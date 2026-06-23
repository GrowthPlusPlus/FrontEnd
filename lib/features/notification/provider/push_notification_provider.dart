// 최초 작성자: 강선욱
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:haenaem/features/notification/data/push_notification_repository.dart';
import 'package:haenaem/features/notification/models/push_notification_settings_dto.dart';

// ── 상태 모델 ─────────────────────────────────────────────

class PushNotificationSettings {
  final bool allNotifications;
  final bool friendRequestNotifications;
  final bool likeNotifications;
  final bool commentNotifications;
  final bool memberAuthNotifications;
  final bool challengeInviteNotifications;
  final bool motivationNotifications;
  final bool dailyReminder;
  final String weeklyReminderTime;

  const PushNotificationSettings({
    this.allNotifications = false,
    this.friendRequestNotifications = false,
    this.likeNotifications = false,
    this.commentNotifications = false,
    this.memberAuthNotifications = false,
    this.challengeInviteNotifications = false,
    this.motivationNotifications = false,
    this.dailyReminder = false,
    this.weeklyReminderTime = '21:00',
  });

  PushNotificationSettings copyWith({
    bool? allNotifications,
    bool? friendRequestNotifications,
    bool? likeNotifications,
    bool? commentNotifications,
    bool? memberAuthNotifications,
    bool? challengeInviteNotifications,
    bool? motivationNotifications,
    bool? dailyReminder,
    String? reminderTime,
    bool? weeklyReminder,
    String? weeklyReminderTime,
  }) {
    return PushNotificationSettings(
      allNotifications: allNotifications ?? this.allNotifications,
      friendRequestNotifications:
          friendRequestNotifications ?? this.friendRequestNotifications,
      likeNotifications: likeNotifications ?? this.likeNotifications,
      commentNotifications: commentNotifications ?? this.commentNotifications,
      memberAuthNotifications:
          memberAuthNotifications ?? this.memberAuthNotifications,
      challengeInviteNotifications:
          challengeInviteNotifications ?? this.challengeInviteNotifications,
      motivationNotifications:
          motivationNotifications ?? this.motivationNotifications,
      dailyReminder: dailyReminder ?? this.dailyReminder,
      weeklyReminderTime: weeklyReminderTime ?? this.weeklyReminderTime,
    );
  }
}

// ── Notifier ──────────────────────────────────────────────

class PushNotificationSettingsNotifier
    extends StateNotifier<PushNotificationSettings> {
  final Ref _ref;

  PushNotificationSettingsNotifier(this._ref)
    : super(const PushNotificationSettings()) {
    _loadInitialSettings();
  }

  PushNotificationRepository get _repo =>
      _ref.read(pushNotificationRepositoryProvider);

  // ── 초기 로드 ─────────────────────────────────────────

  Future<void> _loadInitialSettings() async {
    try {
      final results = await Future.wait([
        _repo.getNotificationSettings(),
        _repo.getWeeklyReminderTime(), // 실패 방지 리마인더 시간
      ]);

      final dto = results[0] as PushNotificationSettingsDto;
      final weeklyReminderTimeStr = results[1] as String?;

      // ✅ 임시 로그
      debugPrint('===== 🔔 푸시 알림 설정 조회 결과 =====');
      debugPrint('🔔 전체 알림: ${dto.allPushNotificationEnabled}');
      debugPrint('🔔 친구 알림: ${dto.friendPushNotificationEnabled}');
      debugPrint('🔔 좋아요: ${dto.allLikesPushNotificationEnabled}');
      debugPrint('🔔 댓글: ${dto.allCommentsPushNotificationEnabled}');
      debugPrint(
        '🔔 멤버 인증: ${dto.allMemberCertificationPushNotificationEnabled}',
      );
      debugPrint('🔔 챌린지 초대: ${dto.challengeInvitePushNotificationEnabled}');
      debugPrint('🔔 동기부여: ${dto.motivationPushNotificationEnabled}');
      debugPrint('🔔 일일 리마인더: ${dto.dailyReminderPushNotificationEnabled}');
      debugPrint('🔔 실패 방지 리마인더 시간: $weeklyReminderTimeStr');
      debugPrint('=======================================');

      state = PushNotificationSettings(
        allNotifications: dto.allPushNotificationEnabled,
        friendRequestNotifications: dto.friendPushNotificationEnabled,
        likeNotifications: dto.allLikesPushNotificationEnabled,
        commentNotifications: dto.allCommentsPushNotificationEnabled,
        memberAuthNotifications:
            dto.allMemberCertificationPushNotificationEnabled,
        challengeInviteNotifications:
            dto.challengeInvitePushNotificationEnabled,
        motivationNotifications: dto.motivationPushNotificationEnabled,
        dailyReminder: dto.dailyReminderPushNotificationEnabled,
        weeklyReminderTime: weeklyReminderTimeStr ?? '21:00',
      );
    } catch (e) {
      debugPrint('알림 설정 초기 로드 실패: $e');
    }
  }

  /// DTO → 상태 반영 (전체 알림 토글 시에도 재사용)
  void _applyDto(PushNotificationSettingsDto dto) {
    state = state.copyWith(
      allNotifications: dto.allPushNotificationEnabled,
      friendRequestNotifications: dto.friendPushNotificationEnabled,
      likeNotifications: dto.allLikesPushNotificationEnabled,
      commentNotifications: dto.allCommentsPushNotificationEnabled,
      memberAuthNotifications:
          dto.allMemberCertificationPushNotificationEnabled,
      challengeInviteNotifications: dto.challengeInvitePushNotificationEnabled,
      motivationNotifications: dto.motivationPushNotificationEnabled,
      dailyReminder: dto.dailyReminderPushNotificationEnabled,
    );
  }

  // ── 전체 알림 토글 ────────────────────────────────────

  Future<void> toggleAll(bool value) async {
    final success = await _repo.setAllNotification(value);
    if (!success) return;

    // 서버가 모든 항목을 일괄 변경하므로 재조회해서 상태 동기화
    try {
      final dto = await _repo.getNotificationSettings();
      _applyDto(dto);
    } catch (e) {
      // 재조회 실패 시 로컬에서 일괄 적용
      debugPrint('전체 알림 설정 후 재조회 실패, 로컬 반영: $e');
      state = state.copyWith(
        allNotifications: value,
        friendRequestNotifications: value,
        likeNotifications: value,
        commentNotifications: value,
        memberAuthNotifications: value,
        challengeInviteNotifications: value,
        motivationNotifications: value,
        dailyReminder: value,
      );
    }
  }

  // ────────────── 소셜 알림 토글  ───────────────
  /// 좋아요 알림 토글
  Future<void> toggleLikes(bool value) async {
    final success = await _repo.setAllLikesNotification(value);
    if (success) {
      state = state.copyWith(
        likeNotifications: value,
        allNotifications: value ? state.allNotifications : false,
      );
    }
  }

  /// 댓글 알림 토글
  Future<void> toggleComments(bool value) async {
    final success = await _repo.setAllCommentsNotification(value);
    if (success) {
      state = state.copyWith(
        commentNotifications: value,
        allNotifications: value ? state.allNotifications : false,
      );
    }
  }

  /// 친구 알림 토글
  Future<void> toggleFriend(bool value) async {
    final success = await _repo.setFriendNotification(value);
    if (success) {
      state = state.copyWith(
        friendRequestNotifications: value,
        allNotifications: value ? state.allNotifications : false,
      );
    }
  }

  /// 멤버 인증 알림 토글
  Future<void> toggleMemberAuth(bool value) async {
    final success = await _repo.setAllMemberCertificationNotification(value);
    if (success) {
      state = state.copyWith(
        memberAuthNotifications: value,
        allNotifications: value ? state.allNotifications : false,
      );
    }
  }

  // ────────────── 챌린지 알림 토글  ───────────────

  /// 챌린지 초대 알림 토글
  Future<void> toggleChallengeInvite(bool value) async {
    final success = await _repo.setChallengeInviteNotification(value);
    if (success) {
      state = state.copyWith(
        challengeInviteNotifications: value,
        allNotifications: value ? state.allNotifications : false,
      );
    }
  }

  /// 동기부여 메시지 알림 토글
  Future<void> toggleMotivation(bool value) async {
    final success = await _repo.setMotivationNotification(value);
    if (success) {
      state = state.copyWith(
        motivationNotifications: value,
        allNotifications: value ? state.allNotifications : false,
      );
    }
  }

  /// 일일 리마인더 토글 (시간 설정 API 없음)
  Future<void> toggleDailyReminder(bool value) async {
    final success = await _repo.setDailyReminderNotification(value);
    if (success) {
      state = state.copyWith(
        dailyReminder: value,
        allNotifications: value ? state.allNotifications : false,
      );
    }
  }

  /// 실패 방지 리마인더 시간 변경
  Future<void> updateWeeklyReminderTime(String timeString) async {
    state = state.copyWith(weeklyReminderTime: timeString);
    final success = await _repo.setWeeklyReminderTime(timeString);
    if (!success) debugPrint('실패 방지 리마인더 시간 서버 저장 실패');
  }
}

// ── Provider ──────────────────────────────────────────────

final pushNotificationProvider =
    StateNotifierProvider<
      PushNotificationSettingsNotifier,
      PushNotificationSettings
    >((ref) => PushNotificationSettingsNotifier(ref));
