// 최초 작성자: 김채영
class ChallengeNotificationSettingsDto {
  final bool challengeAllPushEnabled;
  final bool dailyReminderPushEnabled;
  final String dailyReminderTime; // "HH:mm" 형식
  final bool dailyReminderDisabledByGlobalSetting;
  final bool likesPushEnabled;
  final bool likesDisabledByGlobalSetting;
  final bool commentsPushEnabled;
  final bool commentsDisabledByGlobalSetting;
  final bool memberCertificationPushEnabled;
  final bool memberCertificationDisabledByGlobalSetting;

  const ChallengeNotificationSettingsDto({
    required this.challengeAllPushEnabled,
    required this.dailyReminderPushEnabled,
    required this.dailyReminderTime,
    required this.dailyReminderDisabledByGlobalSetting,
    required this.likesPushEnabled,
    required this.likesDisabledByGlobalSetting,
    required this.commentsPushEnabled,
    required this.commentsDisabledByGlobalSetting,
    required this.memberCertificationPushEnabled,
    required this.memberCertificationDisabledByGlobalSetting,
  });

  factory ChallengeNotificationSettingsDto.fromJson(Map<String, dynamic> json) {
    // String("21:00:00") 또는 Map({ hour: 21, ... }) 둘 다 처리
    String timeStr = '21:00';
    final time = json['dailyReminderTime'];
    if (time != null) {
      if (time is String) {
        timeStr = time.substring(0, 5);
      } else if (time is Map) {
        timeStr = '${(time['hour'] as int).toString().padLeft(2, '0')}:00';
      }
    }

    return ChallengeNotificationSettingsDto(
      challengeAllPushEnabled: json['challengeAllPushEnabled'] ?? false,
      dailyReminderPushEnabled: json['dailyReminderPushEnabled'] ?? false,
      dailyReminderTime: timeStr,
      dailyReminderDisabledByGlobalSetting:
          json['dailyReminderDisabledByGlobalSetting'] ?? false,
      likesPushEnabled: json['likesPushEnabled'] ?? false,
      likesDisabledByGlobalSetting:
          json['likesDisabledByGlobalSetting'] ?? false,
      commentsPushEnabled: json['commentsPushEnabled'] ?? false,
      commentsDisabledByGlobalSetting:
          json['commentsDisabledByGlobalSetting'] ?? false,
      memberCertificationPushEnabled:
          json['memberCertificationPushEnabled'] ?? false,
      memberCertificationDisabledByGlobalSetting:
          json['memberCertificationDisabledByGlobalSetting'] ?? false,
    );
  }
}
