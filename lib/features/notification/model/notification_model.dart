// 최초 작성자: 정승빈
// 알림 데이터 모델 (enum으로 알림 타입 구분)
class NotificationModel {
  final String message;
  final String type;
  final String created; // "YYYY-MM-DD" 형태
  final bool read;
  final String? profileImageUrl;

  NotificationModel({
    required this.message,
    required this.type,
    required this.created,
    required this.read,
    this.profileImageUrl,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      message: json['message'] ?? '',
      type: json['type'] ?? 'UNKNOWN',
      created: json['created'] ?? '',
      read: json['read'] ?? false,
      profileImageUrl: json['imageUrl'],
    );
  }

  NotificationModel copyWith({
    String? message,
    String? type,
    String? created,
    bool? read,
    String? profileImageUrl,
  }) {
    return NotificationModel(
      message: message ?? this.message,
      type: type ?? this.type,
      created: created ?? this.created,
      read: read ?? this.read,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
    );
  }
}

// 챌린지 초대 목록 아이템 모델
class ChallengeInviteModel {
  final int challengeId;
  final String inviterNickname;
  final String? inviterProfileImageUrl;
  final String challengeTitle;
  final int participantCount;
  final int remainingDays;
  final List<String> tags;

  ChallengeInviteModel({
    required this.challengeId,
    required this.inviterNickname,
    this.inviterProfileImageUrl,
    required this.challengeTitle,
    required this.participantCount,
    required this.remainingDays,
    required this.tags,
  });

  factory ChallengeInviteModel.fromJson(Map<String, dynamic> json) {
    return ChallengeInviteModel(
      challengeId: json['challengeId'] ?? 0,
      inviterNickname: json['inviterNickname'] ?? '알 수 없음',
      inviterProfileImageUrl: json['profileUrl'],
      challengeTitle: json['challengeTitle'] ?? '',
      participantCount: json['participantCount'] ?? 0,
      remainingDays: json['remainingDays'] ?? 0,
      tags: List<String>.from(json['tags'] ?? []),
    );
  }
}
