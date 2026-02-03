// 최초 작성자: 강선욱
// 챌린지 데이터 관리 모델 클래스

// 챌린지의 상태(완료, 실패 위기, 일반)를 정의하는 열거형
enum ChallengeStatus {
  completed, // 초록색 카드
  urgent, // 빨간색 카드
  normal, // 회색 카드
}

// 1. 개별 챌린지 데이터만 관리하는 클래스
class ChallengeModel {
  final int challengeId; // 챌린지 id
  final String title; // 챌린지 제목
  final String content; // 챌린지 소개
  final int maxParticipantNumber; // 최대 인원수
  final int participantNumber; // 참여 인원수
  final int duringDate; // 시작 경과일
  final bool isDoneToday; // API의 'doIt' 매핑
  final bool isUrgent; // API의 'warning' 매핑

  ChallengeModel({
    required this.challengeId,
    required this.title,
    required this.content,
    required this.maxParticipantNumber,
    required this.participantNumber,
    required this.duringDate,
    required this.isDoneToday,
    required this.isUrgent,
  });

  // API(Map) 데이터를 모델 객체로 변환하는 생성자
  factory ChallengeModel.fromJson(Map<String, dynamic> json) {
    return ChallengeModel(
      challengeId: json['challengeId'] ?? 0,
      title: json['title'] ?? '',
      content: json['content'] ?? '',
      maxParticipantNumber: json['maxParticipantNumber'] ?? 0,
      participantNumber: json['participantNumber'] ?? 0,
      duringDate: json['duringDate'] ?? 0,
      isDoneToday: json['doIt'] ?? false,
      isUrgent: json['warning'] ?? false,
    );
  }

  // 함수의 용도: 모델의 데이터를 기반으로 UI에 표시할 상태값을 계산함
  ChallengeStatus getStatus() {
    if (isDoneToday) {
      return ChallengeStatus.completed; // 완료 상태 (초록색)
    } else if (isUrgent) {
      return ChallengeStatus.urgent; // 긴급 상태 (빨간색)
    }
    return ChallengeStatus.normal; // 일반 상태 (회색)
  }
}

// 2. 알림 데이터를 포함한 전체 데이터 관리 클래스 -> 메인(홈)화면에서 사용
class ChallengeMainModel {
  final List<ChallengeModel> myChallenges;
  final int notificationNumber;

  ChallengeMainModel({
    required this.myChallenges,
    required this.notificationNumber,
  });

  factory ChallengeMainModel.fromJson(Map<String, dynamic> json) {
    return ChallengeMainModel(
      myChallenges: (json['myChallenges'] as List)
          .map((item) => ChallengeModel.fromJson(item))
          .toList(),
      notificationNumber: json['notificationNumber'] ?? 0,
    );
  }
}

// 친구 정보
class FriendModel {
  final int id;
  final String email;
  final String nickname;
  final String? profileImageUrl;

  FriendModel({
    required this.id,
    required this.email,
    required this.nickname,
    this.profileImageUrl,
  });

  factory FriendModel.fromJson(Map<String, dynamic> json) {
    return FriendModel(
      id: json['id'] ?? 0,
      email: json['email'] ?? '',
      nickname: json['nickname'] ?? '',
      profileImageUrl: json['profileImageUrl'],
    );
  }
}

// 챌린지 생성 데이터 관리 클래스
class ChallengeCreateResponse {
  final int id;
  final String challengeLink;
  final List<FriendModel> friends;

  ChallengeCreateResponse({
    required this.id,
    required this.challengeLink,
    required this.friends,
  });

  factory ChallengeCreateResponse.fromJson(Map<String, dynamic> json) {
    final String link = json['challengeLink'] ?? '';
    int finalId = 0;

    // 💡 서버가 'id'를 주면 그걸 쓰고, 없거나 null이면 링크에서 숫자를 추출합니다.
    if (json['id'] != null && json['id'] != 0) {
      finalId = json['id'];
    } else if (link.isNotEmpty) {
      // 링크 예시: http://localhost:3000/challenges/14
      try {
        finalId = int.parse(Uri.parse(link).pathSegments.last);
        print(
          '🎯 링크에서 ID 추출 성공: $finalId',
        ); // TODO: 링크에서 id 추출하지 않고 백엔드한테 받아야 함.
      } catch (e) {
        // Uri 파싱이 안 될 경우를 대비한 split 백업 로직
        finalId = int.tryParse(link.split('/').last) ?? 0;
      }
    }

    return ChallengeCreateResponse(
      id: finalId,
      challengeLink: link,
      friends: (json['friends'] as List? ?? [])
          .map((f) => FriendModel.fromJson(f))
          .toList(),
    );
  }
}

// 챌린지 내 현황 탭 데이터 관리 클래스
class ChallengeCalendarModel {
  final int totalSuccessDays;
  final int currentStreakDays;
  final bool challengeOwner;

  ChallengeCalendarModel({
    required this.totalSuccessDays,
    required this.currentStreakDays,
    required this.challengeOwner,
  });

  factory ChallengeCalendarModel.fromJson(Map<String, dynamic> json) {
    return ChallengeCalendarModel(
      totalSuccessDays: json['totalSuccessDays'] ?? 0,
      currentStreakDays: json['currentStreakDays'] ?? 0,
      challengeOwner: json['challengeOwner'] ?? false,
    );
  }
}

// 1. 댓글 데이터를 담당할 클래스를 새로 정의합니다.
class ChallengeComment {
  final String userName;
  final String userBadge;
  final String content;
  final DateTime createdAt;

  ChallengeComment({
    required this.userName,
    required this.userBadge,
    required this.content,
    required this.createdAt,
  });

  // 서버 응답 데이터를 변환하기 위한 생성자
  factory ChallengeComment.fromJson(Map<String, dynamic> json) {
    return ChallengeComment(
      userName: json['userName'] ?? '익명',
      userBadge: json['userBadge'] ?? '일반',
      content: json['content'] ?? '',
      // 서버에서 온 날짜 문자열을 DateTime 객체로 변환
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
    );
  }
}

// 개별 인증글 모델
class CertificationPostModel {
  final int postId;
  final String postDate;
  final String? imageUrl;
  final String content;
  final String? userName;
  final int likeCount;
  final List<ChallengeComment> comments;

  CertificationPostModel({
    required this.postId,
    required this.postDate,
    this.imageUrl,
    required this.content,
    this.userName, // 선택 사항
    this.likeCount = 0, // 기본값
    this.comments = const [], // 빈 리스트 기본값
  });

  bool get hasImage => imageUrl != null && imageUrl!.isNotEmpty;

  factory CertificationPostModel.fromJson(Map<String, dynamic> json) {
    return CertificationPostModel(
      postId: json['postId'] ?? 0,
      postDate: json['postDate'] ?? '',
      imageUrl: json['imageUrl'],
      content: json['content'] ?? '',
      userName: json['userName'], // 서버 응답에 없다면 null
      likeCount: json['likeCount'] ?? 0,
      // 댓글 파싱 로직 (필요 시 추가)
      comments: (json['comments'] as List? ?? [])
          .map((c) => ChallengeComment.fromJson(c))
          .toList(),
    );
  }
}
