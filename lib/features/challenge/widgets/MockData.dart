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

  // --- 1. 매일 10분 러닝 (김해냄: 12회 인증, 5일 연속) ---
  static UserChallengeData _getRunningData() {
    return UserChallengeData(
      challengeName: "졸업 프로젝트 코딩",
      isHost: false,
      totalCertCount: 12,
      continuousCertCount: 5,
      posts: [
        CertificationPost(
          userName: "김해냄",
          content: "sprint2가 끝났네요. 확실히 초반보다 코딩 속도가 붙는 것 같아요.",
          date: DateTime(2026, 1, 20, 07, 30),
          hasImage: true,
          imageUrl: imgUrl,
          likeCount: 24, // 최신글 좋아요 24개
          comments: [
            ChallengeComment(
              id: "rc_1",
              userName: "러닝메이트",
              userBadge: "열정러너",
              content: "팀원들 모두 끝까지 포기하지 마세요! 💻",
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
          content: "10일차 인증. 인증하기 기능 구현 완료.",
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
          content: "8일차 인증. 새로운 버그 발견!",
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
          content: "6일차 인증. 오늘은 가볍게 2시간만 코딩.",
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
          content: "4일차 인증. 추위을 뚫고 카페에서 코딩!",
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

  // --- 2. 모각공 (김해냄: 8회 인증) ---
  static UserChallengeData _getStudyData() {
    return UserChallengeData(
      challengeName: "모각공",
      isHost: false,
      totalCertCount: 8,
      continuousCertCount: 2,
      posts: List.generate(8, (index) {
        int day = 19 - index;
        return CertificationPost(
          userName: "김해냄",
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

  // --- 3. 모각코 (김해냄 : 20회 인증, 방장) ---
  static UserChallengeData _getCodingData() {
    return UserChallengeData(
      challengeName: "모각코",
      isHost: true,
      totalCertCount: 20,
      continuousCertCount: 10,
      posts: List.generate(20, (index) {
        int day = 20 - index;
        return CertificationPost(
          userName: "김해냄",
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
