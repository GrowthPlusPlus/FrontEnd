// 최초 작성자 : 김채영
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';
import 'package:haenaem/features/notification/services/fcm_service.dart';

class PushNotificationSettings {
  final bool allNotifications;
  final bool likeNotifications;
  final bool commentNotifications;
  final bool friendRequestNotifications;
  final bool challengeInviteNotifications;
  final bool motivationNotifications;
  final bool dailyReminder; // 일일 리마인더 필드 추가
  final bool memberAuthNotifications;

  PushNotificationSettings({
    this.allNotifications = true,
    this.likeNotifications = true,
    this.commentNotifications = true,
    this.friendRequestNotifications = false,
    this.challengeInviteNotifications = true,
    this.motivationNotifications = true,
    this.dailyReminder = true, // 기본값 true
    this.memberAuthNotifications = false,
  });

  PushNotificationSettings copyWith({
    bool? allNotifications,
    bool? likeNotifications,
    bool? commentNotifications,
    bool? friendRequestNotifications,
    bool? challengeInviteNotifications,
    bool? motivationNotifications,
    bool? dailyReminder,
    bool? memberAuthNotifications,
  }) {
    return PushNotificationSettings(
      allNotifications: allNotifications ?? this.allNotifications,
      likeNotifications: likeNotifications ?? this.likeNotifications,
      commentNotifications: commentNotifications ?? this.commentNotifications,
      friendRequestNotifications:
          friendRequestNotifications ?? this.friendRequestNotifications,
      challengeInviteNotifications:
          challengeInviteNotifications ?? this.challengeInviteNotifications,
      motivationNotifications:
          motivationNotifications ?? this.motivationNotifications,
      dailyReminder: dailyReminder ?? this.dailyReminder,
      memberAuthNotifications:
          memberAuthNotifications ?? this.memberAuthNotifications,
    );
  }
}

class PushNotificationSettingsNotifier
    extends StateNotifier<PushNotificationSettings> {
  final Ref ref; // 1. Ref 추가 (서비스 호출을 위해)

  PushNotificationSettingsNotifier(this.ref)
    : super(PushNotificationSettings());

  void toggle(String key, bool value) async {
    if (key == 'all') {
      // ✅ 서버 API 호출
      final success = await ref
          .read(fcmServiceProvider)
          .updateAllNotificationStatus(value);

      if (success) {
        // 성공 시 모든 스위치 상태 변경
        state = PushNotificationSettings(
          allNotifications: value,
          likeNotifications: value,
          commentNotifications: value,
          friendRequestNotifications: value,
          challengeInviteNotifications: value,
          motivationNotifications: value,
          dailyReminder: value,
          memberAuthNotifications: value,
        );
      } else {
        // 실패 시 에러 처리 (필요시 토스트 메시지 등 추가)
        debugPrint("전체 알림 설정 변경에 실패했습니다.");
      }
    } else {
      // 개별 알림 로직 (나중에 개별 API 생기면 여기에 추가)
      switch (key) {
        case 'like':
          state = state.copyWith(likeNotifications: value);
          break;
        case 'comment':
          state = state.copyWith(commentNotifications: value);
          break;
        case 'friend':
          state = state.copyWith(friendRequestNotifications: value);
          break;
        case 'invite':
          state = state.copyWith(challengeInviteNotifications: value);
          break;
        case 'motivation':
          state = state.copyWith(motivationNotifications: value);
          break;
        case 'reminder':
          state = state.copyWith(dailyReminder: value);
          break;
        case 'memberAuth':
          state = state.copyWith(memberAuthNotifications: value);
          break;
      }

      if (value == false) {
        state = state.copyWith(allNotifications: false);
      }
    }
  }
}

// 2. 프로바이더 정의 수정
final pushNotificationProvider =
    StateNotifierProvider<
      PushNotificationSettingsNotifier,
      PushNotificationSettings
    >((ref) {
      return PushNotificationSettingsNotifier(ref); // ref 전달
    });
