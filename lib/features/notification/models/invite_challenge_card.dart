// 최초작성자: 정승빈
// 챌린지 초대 목록 아이템 모델
import 'package:haenaem/shared/models/user.dart';
import 'package:haenaem/shared/models/search_challenge_card.dart';
import 'package:haenaem/shared/models/challenge_base.dart';
import 'package:haenaem/shared/models/tag_model.dart';

// API 응답 원본 데이터를 담는 모델
class InviteResponse {
  final int inviterId;
  final String inviterNickname;
  final String? profileImageUrl;
  final int challengeId;
  final String challengeTitle;
  final int participantCount;
  final int remainingDays;
  final List<ChallengeTagModel> tags;

  InviteResponse({
    required this.inviterId,
    required this.inviterNickname,
    this.profileImageUrl,
    required this.challengeId,
    required this.challengeTitle,
    required this.participantCount,
    required this.remainingDays,
    required this.tags,
  });

  factory InviteResponse.fromJson(Map<String, dynamic> json) {
    String? rawProfileUrl = json['profileImageUrl'] as String?;
    // URL이 null이 아니고, 공백을 제거했을 때 빈 문자열("")이라면 null로 간주
    // (서버에서 잘못된 빈 값이 넘어올 경우를 대비한 방어 코드)
    if (rawProfileUrl != null && rawProfileUrl.trim().isEmpty) {
      rawProfileUrl = null;
    }

    return InviteResponse(
      inviterId: json['inviterId'] as int,
      inviterNickname: json['inviterNickname'] as String,
      profileImageUrl: rawProfileUrl,
      challengeId: json['challengeId'] as int,
      challengeTitle: json['challengeTitle'] as String,
      participantCount: json['participantCount'] as int,
      remainingDays: json['remainingDays'] as int,
      tags: (json['tags'] as List? ?? [])
          .map((t) => ChallengeTagModel.fromJson(t as Map<String, dynamic>))
          .toList(),
    );
  }

  // InviteResponse → User 변환
  // User.fromJson() 대신 직접 생성: 초대 API 필드명이 User.fromJson()의 기대 키('id', 'nickname')와 다르기 때문
  User toUser() {
    return User(
      id: inviterId, // 'inviterId' → User.id
      nickname: inviterNickname, // 'inviterNickname' → User.nickname
      profileUrl: profileImageUrl, // 'profileImageUrl' → User.profileUrl
    );
  }

  // InviteResponse → SearchChallengeCard 변환
  // SearchChallengeCard.fromJson() 대신 직접 생성: 초대 API 필드명이
  // SearchChallengeCard.fromJson()의 기대 키('participant_count', 'end_date', 'tag')와 다르기 때문
  SearchChallengeCard toChallengeCard() {
    return SearchChallengeCard(
      base: ChallengeBase(
        id: challengeId, // 'challengeId' → ChallengeBase.id
        title: challengeTitle, // 'challengeTitle' → ChallengeBase.title
      ),
      participantCount:
          participantCount, // 'participantCount' → SearchChallengeCard.participantCount
      dDay: remainingDays,
      tags: tags, // 'tags' → SearchChallengeCard.tags
    );
  }
}

// 챌린지 초대 카드 모델 (User + SearchChallengeCard)
class InviteChallengecard {
  final SearchChallengeCard challengeInfo; // 초대된 챌린지의 상세정보
  final User inviterUser; // 초대한 유저의 정보 (ID, 프로필 URL, 닉네임 포함)

  InviteChallengecard({required this.challengeInfo, required this.inviterUser});

  /// InviteResponse를 InviteChallengecard로 변환하는 팩토리 생성자
  factory InviteChallengecard.fromResponse(InviteResponse response) {
    return InviteChallengecard(
      inviterUser: response.toUser(),
      challengeInfo: response.toChallengeCard(),
    );
  }

  // JSON에서 바로 변환하는 팩토리 생성자 (InviteResponse를 거쳐 변환)
  factory InviteChallengecard.fromJson(Map<String, dynamic> json) {
    return InviteChallengecard.fromResponse(InviteResponse.fromJson(json));
  }
}
