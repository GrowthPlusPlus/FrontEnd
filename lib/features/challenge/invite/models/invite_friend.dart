// 최초 작성자: 강선욱
import 'package:haenaem/shared/models/user.dart';

class InviteFriend extends User {
  final bool isInvited;

  const InviteFriend({
    required super.id,
    super.profileUrl,
    required super.nickname,
    required this.isInvited,
  });

  factory InviteFriend.fromJson(Map<String, dynamic> json) {
    final user = User.fromJson(json);
    return InviteFriend(
      id: user.id,
      profileUrl: user.profileUrl,
      nickname: user.nickname,
      // API 명세: 초대 상태 체크 ('INVITED' 문자열일 경우)
      isInvited: json['inviteStatus'] == 'INVITED',
    );
  }

  @override
  InviteFriend copyWith({
    int? id,
    String? profileUrl,
    String? nickname,
    bool? isInvited,
    bool clearProfileUrl = false,
  }) {
    return InviteFriend(
      id: id ?? this.id,
      profileUrl: clearProfileUrl ? null : (profileUrl ?? this.profileUrl),
      nickname: nickname ?? this.nickname,
      isInvited: isInvited ?? this.isInvited,
    );
  }
}
