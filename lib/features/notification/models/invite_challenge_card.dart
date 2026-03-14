// 최초작성자: 정승빈
// 챌린지 초대 목록 아이템 모델
import 'package:haenaem/shared/models/user.dart';
import 'package:haenaem/shared/models/search_challenge_card.dart';

class InviteChallengecard {
  final SearchChallengeCard challengeInfo; // 초대된 챌린지의 상세정보
  final User inviterUser; // 초대한 유저의 정보 (ID, 프로필 URL, 닉네임 포함)

  InviteChallengecard({required this.challengeInfo, required this.inviterUser});

  // 서버에서 받은 JSON 데이터를 [InviteChallengecard] 객체로 변환하는 팩토리 생성자
  factory InviteChallengecard.fromJson(Map<String, dynamic> json) {
    String? rawProfileUrl = json['profileUrl'];
    // URL이 null이 아니고, 공백을 제거했을 때 빈 문자열("")이라면 null로 간주
    // (서버에서 잘못된 빈 값이 넘어올 경우를 대비한 방어 코드)
    if (rawProfileUrl != null && rawProfileUrl.trim().isEmpty) {
      rawProfileUrl = null;
    }

    return InviteChallengecard(
      challengeInfo: SearchChallengeCard.fromJson(json),
      inviterUser: User(
        id: json['inviterId'] ?? 0,
        nickname: json['inviterNickname'] ?? '알 수 없음',
        profileUrl: rawProfileUrl, // 빈 문자열이면 null로 처리
      ),
    );
  }
}
