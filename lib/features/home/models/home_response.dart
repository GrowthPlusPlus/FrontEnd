import 'package:haenaem/shared/models/home_challenge_card.dart';

// 최초 작성자: 강선욱
// API 응답을 담는 홈 전용 모델
// myChallenges → List<HomeChallengeCard>로 파싱
// notificationNumber → 별도 관리
class HomeResponse {
  final List<HomeChallengeCard> myChallenges;
  final int notificationNumber;

  const HomeResponse({
    required this.myChallenges,
    required this.notificationNumber,
  });

  factory HomeResponse.fromJson(Map<String, dynamic> json) {
    final List<dynamic> challenges = json['myChallenges'] ?? [];
    return HomeResponse(
      myChallenges: challenges
          .map((e) => HomeChallengeCard.fromJson(e))
          .toList(),
      notificationNumber: json['notificationNumber'] as int,
    );
  }
}
