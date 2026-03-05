// 리팩토링: 강선욱
// 사용자 객체와 관련된 정보를 관리 모델

// 마이페이지 사용자 프로필 부분
class UserProfileModel {
  final String nickname;
  final String introduction;
  final String profileImageUrl;
  final List<String> tags;

  UserProfileModel({
    required this.nickname,
    required this.introduction,
    required this.profileImageUrl,
    required this.tags,
  });

  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    return UserProfileModel(
      nickname: json['nickname'] ?? '',
      introduction: json['introduction'] ?? '',
      profileImageUrl: json['profileImageUrl'] ?? '',
      tags: List<String>.from(json['tags'] ?? []),
    );
  }
}

// 방장 정보를 관리하는 클래스
class HostModel {
  final String name;
  final String profileImageUrl;

  HostModel({required this.name, required this.profileImageUrl});

  factory HostModel.fromJson(Map<String, dynamic> json) {
    return HostModel(
      name: json['name'] ?? '익명',
      profileImageUrl: json['profileImageUrl'] ?? '',
    );
  }
}

// 챌린지 참여 멤버 정보를 관리하는 클래스
class ParticipantModel {
  final String name;
  final String profileImageUrl;

  ParticipantModel({required this.name, required this.profileImageUrl});

  factory ParticipantModel.fromJson(Map<String, dynamic> json) {
    return ParticipantModel(
      name: json['name'] ?? '',
      profileImageUrl: json['profileImageUrl'] ?? '',
    );
  }
}

// 친구 정보를 관리하는 클래스
class FriendModel {
  final int id;
  final String email;
  final String nickname;
  final String? profileImageUrl;

  FriendModel({
    required this.id,
    required this.email,
    required this.nickname,
    this.profileImageUrl,
  });

  factory FriendModel.fromJson(Map<String, dynamic> json) {
    return FriendModel(
      id: json['id'] ?? 0,
      email: json['email'] ?? '',
      nickname: json['nickname'] ?? '',
      profileImageUrl: json['profileImageUrl'],
    );
  }
}

// 챌린지 멤버 정보를 관리하는 클래스 (memberId 포함)
// 챌린지 멤버 관리 기능에 쓰임
// challenge_member_provider.dart
// challenge_repository.dart
// challenge_members_screen.dart
class ChallengeMember {
  final int memberId;
  final String nickname;
  final String? profileImageUrl;

  ChallengeMember({
    required this.memberId,
    required this.nickname,
    this.profileImageUrl,
  });

  factory ChallengeMember.fromJson(Map<String, dynamic> json) {
    return ChallengeMember(
      memberId: json['userId'] as int,
      nickname: json['nickname'] as String,
      profileImageUrl: json['profileImageUrl'] as String?,
    );
  }
}
