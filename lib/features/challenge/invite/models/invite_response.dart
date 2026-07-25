import './invite_friend.dart';

// 최초 작성자: 강선욱
// 챌린지 초대 탭 응답 모델 (GET /api/challenges/{challengeId}/invite)
class ChallengeInviteResponse {
  final String challengeLink; // 초대 링크
  final List<InviteFriend> friends; // 친구 목록 (초대 상태 포함)

  ChallengeInviteResponse({required this.challengeLink, required this.friends});

  factory ChallengeInviteResponse.fromJson(Map<String, dynamic> json) {
    return ChallengeInviteResponse(
      // 초대 링크 매핑
      challengeLink: json['inviteLink'] ?? '',

      friends: ((json['responseList'] ?? []) as List)
          .map((e) => InviteFriend.fromJson(e))
          .toList(),
    );
  }
}

class ChallengeDeepLinkResponse {
  final int challengeId; // 챌린지 ID
  final String challengeTitle; // 챌린지 제목
  final bool alreadyParticipant; // 이미 참여 중인 유저인지 여부

  ChallengeDeepLinkResponse({
    required this.challengeId,
    required this.challengeTitle,
    required this.alreadyParticipant,
  });

  factory ChallengeDeepLinkResponse.fromJson(Map<String, dynamic> json) {
    return ChallengeDeepLinkResponse(
      challengeId: json['challengeId'] as int? ?? 0,
      challengeTitle: json['challengeTitle'] as String? ?? '',
      alreadyParticipant: json['alreadyParticipant'] as bool? ?? false,
    );
  }
}
