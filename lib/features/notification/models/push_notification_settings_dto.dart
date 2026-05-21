// 최초 작성자: 김채영

class PushNotificationSettingsDto {
  final bool allPushNotificationEnabled;
  final bool friendPushNotificationEnabled;
  final bool allLikesPushNotificationEnabled;
  final bool allCommentsPushNotificationEnabled;
  final bool allMemberCertificationPushNotificationEnabled;
  final bool challengeInvitePushNotificationEnabled;
  final bool motivationPushNotificationEnabled;
  final bool dailyReminderPushNotificationEnabled;

  const PushNotificationSettingsDto({
    required this.allPushNotificationEnabled,
    required this.friendPushNotificationEnabled,
    required this.allLikesPushNotificationEnabled,
    required this.allCommentsPushNotificationEnabled,
    required this.allMemberCertificationPushNotificationEnabled,
    required this.challengeInvitePushNotificationEnabled,
    required this.motivationPushNotificationEnabled,
    required this.dailyReminderPushNotificationEnabled,
  });

  factory PushNotificationSettingsDto.fromJson(Map<String, dynamic> json) {
    return PushNotificationSettingsDto(
      allPushNotificationEnabled: json['allPushNotificationEnabled'] ?? false,
      friendPushNotificationEnabled:
          json['friendPushNotificationEnabled'] ?? false,
      allLikesPushNotificationEnabled:
          json['allLikesPushNotificationEnabled'] ?? false,
      allCommentsPushNotificationEnabled:
          json['allCommentsPushNotificationEnabled'] ?? false,
      allMemberCertificationPushNotificationEnabled:
          json['allMemberCertificationPushNotificationEnabled'] ?? false,
      challengeInvitePushNotificationEnabled:
          json['challengeInvitePushNotificationEnabled'] ?? false,
      motivationPushNotificationEnabled:
          json['motivationPushNotificationEnabled'] ?? false,
      dailyReminderPushNotificationEnabled:
          json['dailyReminderPushNotificationEnabled'] ?? false,
    );
  }
}
