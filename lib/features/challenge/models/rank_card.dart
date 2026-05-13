// import 'package:haenaem/shared/models/user.dart';

// // 최초 작성자: 강선욱
// // 랭킹 카드 모델 클래스
// // User에 정의된 필드(id, profileUrl, nickname)를 토대로 랭킹 화면에서 필요한 데이터로 구성
// class RankCard {
//   final User user; // id, profileUrl, nickname
//   final int rank; // 사용자 순위
//   final int totalSuccessCount; // 총 인증 완료 횟수
//   final int streakCount; // 최근 인증 연속 횟수

//   const RankCard({
//     required this.user,
//     required this.rank,
//     required this.totalSuccessCount,
//     required this.streakCount,
//   });

//   factory RankCard.fromJson(Map<String, dynamic> json) {
//     return RankCard(
//       user: User.fromJson(json),
//       rank: json['rank'] as int,
//       totalSuccessCount: json['total_success_count'] as int,
//       streakCount: json['streak_count'] as int,
//     );
//   }

//   RankCard copyWith({
//     User? user,
//     int? rank,
//     int? totalSuccessCount,
//     int? streakCount,
//   }) {
//     return RankCard(
//       user: user ?? this.user,
//       rank: rank ?? this.rank,
//       totalSuccessCount: totalSuccessCount ?? this.totalSuccessCount,
//       streakCount: streakCount ?? this.streakCount,
//     );
//   }
// }
