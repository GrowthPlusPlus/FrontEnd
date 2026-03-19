import 'package:haenaem/shared/models/user.dart';

// 최초 작성자: 강선욱
// 친구 요청 카드 모델
// User에 정의된 필드(id, profileUrl, nickname)를 재사용
class FriendRequestCard {
  final User user; // 요청자 정보 (id, profileUrl, nickname)
  final int requestId; // 친구 요청 id
  final DateTime requestDate; // 친구 요청 날짜

  const FriendRequestCard({
    required this.user,
    required this.requestId,
    required this.requestDate,
  });

  factory FriendRequestCard.fromJson(Map<String, dynamic> json) {
    return FriendRequestCard(
      user: User.fromJson(json['user'] as Map<String, dynamic>),
      requestId: json['request_id'] as int,
      requestDate: DateTime.parse(json['request_date'] as String),
    );
  }

  FriendRequestCard copyWith({
    User? user,
    int? requestId,
    DateTime? requestDate,
  }) {
    return FriendRequestCard(
      user: user ?? this.user,
      requestId: requestId ?? this.requestId,
      requestDate: requestDate ?? this.requestDate,
    );
  }
}
