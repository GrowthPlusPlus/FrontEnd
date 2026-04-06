// 최초 작성자: 김채영
import 'user.dart';

// 한줄소개, 태그 모델 + 기본 유저 정보
class UserDetail {
  final User user;
  final String introduction;
  final List<String> tags;

  UserDetail({
    required this.user,
    required this.introduction,
    required this.tags,
  });

  factory UserDetail.fromJson(Map<String, dynamic> json) {
    return UserDetail(
      user: User.fromJson(json),
      introduction: json['introduction'] ?? '',
      tags: List<String>.from(json['tags'] ?? []),
    );
  }
  // 로컬 업데이트를 위한 copyWith
  UserDetail copyWith({User? user, String? introduction, List<String>? tags}) {
    return UserDetail(
      user: user ?? this.user,
      introduction: introduction ?? this.introduction,
      tags: tags ?? this.tags,
    );
  }
}
