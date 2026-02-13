// 리팩토링: 강선욱
// 사용자 객체와 관련된 정보를 관리 모델

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
