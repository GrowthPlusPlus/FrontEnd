// 최초 작성자: 강선욱
// 챌린지 기본 정보를 정의한 모델
class ChallengeBase {
  final int id;
  final String title;
  // final bool isLeader; // 현재 로그인 중인 유저가 해당 챌린지의 방장인지 여부

  const ChallengeBase({
    required this.id,
    required this.title,
    // required this.isLeader,
  });

  factory ChallengeBase.fromJson(Map<String, dynamic> json) {
    return ChallengeBase(
      id: json['challengeId'] as int,
      title: json['title'] as String,
      // isLeader: json['is_leader'] as bool,
    );
  }

  ChallengeBase copyWith({int? id, String? title, bool? isLeader}) {
    return ChallengeBase(
      id: id ?? this.id,
      title: title ?? this.title,
      // isLeader: isLeader ?? this.isLeader,
    );
  }
}
