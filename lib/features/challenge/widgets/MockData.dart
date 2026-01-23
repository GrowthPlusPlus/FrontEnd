// 최초 작성자 : 강선욱
import 'package:haenaem/features/challenge/widgets/UserChallengeData.dart';

String imgUrl = "assets/images/testImage.jpg";

class MockData {
  /// 특정 챌린지 이름을 기반으로 데이터를 찾아주는 함수
  static UserChallengeData getChallengeByName(String name) {
    return getAllChallenges().firstWhere(
      (element) => element.challengeName == name,
      orElse: () => getAllChallenges().first,
    );
  }

  /// 모든 챌린지 데이터를 반환
  static List<UserChallengeData> getAllChallenges() {
    return [_getRunningData(), _getStudyData(), _getCodingData()];
  }

  // --- 1. 매일 10분 러닝 (Growth: 12회 인증, 5일 연속) ---
  static UserChallengeData _getRunningData() {
    return UserChallengeData(
      challengeName: "매일 10분 러닝",
      isHost: false,
      totalCertCount: 12,
      continuousCertCount: 5,
      posts: [
        CertificationPost(
          userName: "Growth",
          content:
              "오늘로 12번째 인증 완료! 5일 연속으로 뛰니까 이제 몸이 좀 가벼워지는 것 같아요. 확실히 초반보다 숨이 덜 차네요. 다들 끝까지 포기하지 마세요! 🏃‍♂️",
          date: DateTime(2026, 1, 20, 07, 30),
          hasImage: true,
          imageUrl: imgUrl,
          likeCount: 24, // 최신글 좋아요 24개
          comments: [
            ChallengeComment(
              id: "rc_1",
              userName: "러닝메이트",
              userBadge: "열정러너",
              content: "벌써 12회차라니 대단하세요! 저도 자극받고 지금 나갑니다.",
              createdAt: DateTime(2026, 1, 20, 08, 05),
            ),
            ChallengeComment(
              id: "rc_2",
              userName: "비타민",
              userBadge: "응원대장",
              content: "연속 5일 인증 축하드려요! 불꽃 아이콘 너무 멋져요🔥",
              createdAt: DateTime(2026, 1, 20, 08, 30),
            ),
            ChallengeComment(
              id: "rc_3",
              userName: "새벽반",
              userBadge: "얼리버드",
              content: "오늘 날씨 꽤 쌀쌀한데 고생하셨습니다!",
              createdAt: DateTime(2026, 1, 20, 09, 10),
            ),
          ],
        ),
        CertificationPost(
          content: "11일차 인증. 월요일 아침 성공!",
          date: DateTime(2026, 1, 19, 07, 10),
          hasImage: true,
          imageUrl: imgUrl,
          likeCount: 15,
        ),
        CertificationPost(
          content: "10일차 인증. 주말 러닝 완료.",
          date: DateTime(2026, 1, 18, 08, 45),
          hasImage: true,
          imageUrl: imgUrl,
          likeCount: 12,
        ),
        CertificationPost(
          content: "9일차 인증. 페이스 조절 중입니다.",
          date: DateTime(2026, 1, 17, 07, 30),
          hasImage: false,
          likeCount: 8,
        ),
        CertificationPost(
          content: "8일차 인증. 새로운 코스 발견!",
          date: DateTime(2026, 1, 16, 07, 00),
          hasImage: true,
          imageUrl: imgUrl,
          likeCount: 11,
        ),
        CertificationPost(
          content: "7일차 인증. 일주일 달성 뿌듯하네요.",
          date: DateTime(2026, 1, 15, 07, 20),
          hasImage: true,
          imageUrl: imgUrl,
          likeCount: 20,
        ),
        CertificationPost(
          content: "6일차 인증. 오늘은 가볍게 조깅.",
          date: DateTime(2026, 1, 14, 07, 50),
          hasImage: false,
          likeCount: 6,
        ),
        CertificationPost(
          content: "5일차 인증. 습관이 되어가네요.",
          date: DateTime(2026, 1, 13, 06, 30),
          hasImage: true,
          imageUrl: imgUrl,
          likeCount: 14,
        ),
        CertificationPost(
          content: "4일차 인증. 근육통을 뚫고 성공!",
          date: DateTime(2026, 1, 12, 07, 15),
          hasImage: true,
          imageUrl: imgUrl,
          likeCount: 9,
        ),
        CertificationPost(
          content: "3일차 인증. 작심삼일 고비 완료.",
          date: DateTime(2026, 1, 11, 08, 00),
          hasImage: false,
          likeCount: 7,
        ),
        CertificationPost(
          content: "2일차 인증. 상쾌한 아침 공기.",
          date: DateTime(2026, 1, 10, 07, 30),
          hasImage: true,
          imageUrl: imgUrl,
          likeCount: 13,
        ),
        CertificationPost(
          content: "1일차 인증. 오늘부터 시작합니다!",
          date: DateTime(2026, 1, 9, 07, 40),
          hasImage: true,
          imageUrl: imgUrl,
          likeCount: 18,
        ),
      ],
    );
  }

  // --- 2. 모각공 (Growth: 8회 인증) ---
  static UserChallengeData _getStudyData() {
    return UserChallengeData(
      challengeName: "모각공",
      isHost: false,
      totalCertCount: 8,
      continuousCertCount: 2,
      posts: List.generate(8, (index) {
        int day = 19 - index;
        return CertificationPost(
          userName: "Growth",
          content: "${8 - index}회차 공부 인증입니다. 오늘도 집중 성공!",
          date: DateTime(2026, 1, day, 15, 00),
          hasImage: index % 2 == 0,
          imageUrl: index % 2 == 0 ? imgUrl : null,
          likeCount: 5 + (index * 3), // 좋아요 수 데이터 추가
          comments: index == 0
              ? [
                  ChallengeComment(
                    id: "sc_1",
                    userName: "공부벌레",
                    userBadge: "독서실지기",
                    content: "열공하시네요! 화이팅입니다.",
                    createdAt: DateTime(2026, 1, 19, 16, 20),
                  ),
                ]
              : [],
        );
      }),
    );
  }

  // --- 3. 모각코 (Growth: 20회 인증, 방장) ---
  static UserChallengeData _getCodingData() {
    return UserChallengeData(
      challengeName: "모각코",
      isHost: true,
      totalCertCount: 20,
      continuousCertCount: 10,
      posts: List.generate(20, (index) {
        int day = 20 - index;
        return CertificationPost(
          userName: "Growth",
          content: "${20 - index}회차 코딩 인증. 데이터 모델링 작업 중입니다.",
          date: DateTime(2026, 1, day, 23, 00),
          hasImage: index < 5, // 최근 5개만 이미지 있음
          imageUrl: index < 5 ? imgUrl : null,
          likeCount: (index == 0) ? 32 : (20 - index) * 2, // 최신글은 32개, 나머지는 계산식
          comments: [],
        );
      }),
    );
  }
}
