// 최초 작성자: 김채영

// 한줄소개, 태그 모델
class UserDetail {
  final String introduction;
  final List<String> tags;

  UserDetail({required this.introduction, required this.tags});

  factory UserDetail.fromJson(Map<String, dynamic> json) {
    return UserDetail(
      introduction: json['introduction'] ?? '',
      tags: List<String>.from(json['tags'] ?? []),
    );
  }
}
