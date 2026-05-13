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
