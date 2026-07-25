import 'package:haenaem/shared/models/home_challenge_card.dart';

// 주간 상태 데이터
class WeekStatus {
  final String date;
  final String status;

  const WeekStatus({required this.date, required this.status});

  factory WeekStatus.fromJson(Map<String, dynamic> json) {
    return WeekStatus(
      date: json['date'] as String,
      status: json['status'] as String,
    );
  }
}

// 최초 작성자: 강선욱
// API 응답을 담는 홈 전용 모델
// myChallenges → List<HomeChallengeCard>로 파싱
// notificationNumber → 별도 관리
class HomeResponse {
  final List<HomeChallengeCard> myChallenges;
  final int notificationNumber;
  final List<WeekStatus> weekStatus;

  const HomeResponse({
    required this.myChallenges,
    required this.notificationNumber,
    required this.weekStatus,
  });

  factory HomeResponse.fromJson(Map<String, dynamic> json) {
    final List<dynamic> challenges = json['myChallenges'] ?? [];
    final List<dynamic> statusList = json['weekStatus'] ?? [];
    return HomeResponse(
      myChallenges: challenges
          .map((e) => HomeChallengeCard.fromJson(e))
          .toList(),
      notificationNumber: json['notificationNumber'] as int,
      weekStatus: statusList.map((e) => WeekStatus.fromJson(e)).toList(),
    );
  }
}
