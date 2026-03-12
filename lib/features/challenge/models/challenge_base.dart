class ChallengeBase {
  final String id;
  final String title;
  final bool isLeader;

  const ChallengeBase({
    required this.id,
    required this.title,
    required this.isLeader,
  });

  factory ChallengeBase.fromJson(Map<String, dynamic> json) {
    return ChallengeBase(
      id: json['id'] as String,
      title: json['title'] as String,
      isLeader: json['is_leader'] as bool,
    );
  }

  ChallengeBase copyWith({String? id, String? title, bool? isLeader}) {
    return ChallengeBase(
      id: id ?? this.id,
      title: title ?? this.title,
      isLeader: isLeader ?? this.isLeader,
    );
  }
}
