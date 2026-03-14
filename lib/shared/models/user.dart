// 최초 작성자: 강선욱
// 사용자 정보를 저장하는 모델 클래스

class User {
  final String id;
  final String? profileUrl;
  final String nickname;

  const User({required this.id, this.profileUrl, required this.nickname});

  // API 데이터와 모델 클래스 데이터 매핑
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      profileUrl: json['profile_url'] as String?,
      nickname: json['nickname'] as String,
    );
  }

  // 특정 필드만 변경하여 새 User 객체를 반환하는 메서드
  User copyWith({String? id, String? profileUrl, String? nickname}) {
    return User(
      id: id ?? this.id,
      profileUrl: profileUrl ?? this.profileUrl,
      nickname: nickname ?? this.nickname,
    );
  }
}
