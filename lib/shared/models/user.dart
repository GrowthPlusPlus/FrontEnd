// 최초 작성자: 강선욱
// 사용자 정보를 저장하는 모델 클래스

class User {
  final int id;
  final String? profileUrl;
  final String nickname;

  const User({required this.id, this.profileUrl, required this.nickname});

  // API 데이터와 모델 클래스 데이터 매핑
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id'].toString()) ?? 0,
      profileUrl: json['profileImageUrl'] as String?,
      nickname: (json['nickname'] ?? json['name']) as String,
    );
  }

  // 특정 필드만 변경하여 새 User 객체를 반환하는 메서드
  User copyWith({int? id, String? profileUrl, String? nickname}) {
    return User(
      id: id ?? this.id,
      profileUrl: profileUrl ?? this.profileUrl,
      nickname: nickname ?? this.nickname,
    );
  }
}
