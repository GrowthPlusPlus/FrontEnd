/// 최초 작성자: 정승빈
library;

class ChallengeMember {
  final int memberId;
  final String nickname;
  final String? profileImageUrl; // 프로필 이미지가 없을 수도 있으니 nullable
  //final String? role; // 'HOST' 또는 'MEMBER' 등

  ChallengeMember({
    required this.memberId,
    required this.nickname,
    this.profileImageUrl,
    //required this.role,
  });

  factory ChallengeMember.fromJson(Map<String, dynamic> json) {
    return ChallengeMember(
      memberId: json['userId'] as int,
      nickname: json['nickname'] as String,
      profileImageUrl: json['profileImageUrl'] as String?,
      //role: json['role'] as String,
    );
  }
}
