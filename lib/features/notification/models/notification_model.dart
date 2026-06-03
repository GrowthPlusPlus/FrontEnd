// 최초 작성자: 정승빈
// 알림 데이터 모델
class NotificationModel {
  final String message;
  final String type;
  final String created; // "YYYY-MM-DD" 형태
  final bool read;
  final String? profileImageUrl;
  final int? targetId; // 목적지 ID

  NotificationModel({
    required this.message,
    required this.type,
    required this.created,
    required this.read,
    this.profileImageUrl,
    this.targetId,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    // 백엔드에서 빈 문자열("")이 오면 null로 변환하는 안전 장치
    String? rawImageUrl = json['imageUrl'];
    if (rawImageUrl != null && rawImageUrl.trim().isEmpty) {
      rawImageUrl = null;
    }

    return NotificationModel(
      message: json['message'] ?? '',
      type: json['type'] ?? 'UNKNOWN',
      created: json['created'] ?? '',
      read: json['read'] ?? false,
      profileImageUrl: rawImageUrl, // 빈 문자열이면 null로 처리
      targetId: json['targetId'],
    );
  }

  NotificationModel copyWith({
    String? message,
    String? type,
    String? created,
    bool? read,
    String? profileImageUrl,
    int? targetId,
  }) {
    return NotificationModel(
      message: message ?? this.message,
      type: type ?? this.type,
      created: created ?? this.created,
      read: read ?? this.read,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      targetId: targetId ?? this.targetId,
    );
  }
}

/*
@Deprecated(
  'notification/models/challenge_invite_card내에 ChallengeInviteCard 대신 사용',
)
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
    String? rawProfileUrl = json['profileUrl'];
    if (rawProfileUrl != null && rawProfileUrl.trim().isEmpty) {
      rawProfileUrl = null;
    }

    return ChallengeInviteModel(
      challengeId: json['challengeId'] ?? 0,
      inviterNickname: json['inviterNickname'] ?? '알 수 없음',
      inviterProfileImageUrl: rawProfileUrl, // 빈 문자열이면 null로 처리
      challengeTitle: json['challengeTitle'] ?? '',
      participantCount: json['participantCount'] ?? 0,
      remainingDays: json['remainingDays'] ?? 0,
      tags: List<String>.from(json['tags'] ?? []),
    );
  }
}
*/
