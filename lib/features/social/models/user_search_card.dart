import 'package:haenaem/shared/models/user.dart';

// 최초 작성자: 강선욱
// 친구 상태 관리
enum FriendState {
  friend, // 친구
  pending, // 대기중
  stranger, // 비친구
}

// 최초 작성자: 강선욱
// 소셜 화면 사용자 검색 카드 모델
// User에 정의된 필드(id, profileUrl, nickname)를 재사용
class UserSearchCard {
  final User user; // 사용자 정보 (id, profileUrl, nickname)
  final FriendState state; // 현재 로그인 유저와의 상태

  const UserSearchCard({required this.user, required this.state});

  factory UserSearchCard.fromJson(Map<String, dynamic> json) {
    return UserSearchCard(
      user: User.fromJson(json['user'] as Map<String, dynamic>),
      state: FriendState.values.byName(json['state'] as String),
    );
  }

  UserSearchCard copyWith({User? user, FriendState? state}) {
    return UserSearchCard(user: user ?? this.user, state: state ?? this.state);
  }
}
