// 최초 작성자 : 강선욱
/// 사용자의 챌린지 전체 현황 및 인증글 데이터를 담는 모델
class UserChallengeData {
  final String challengeName; // 챌린지 이름
  final bool isHost;
  final int totalCertCount; // 인증 완료 일수
  final int continuousCertCount; // 인증 연속 일수
  final List<CertificationPost> posts; // 인증글 리스트

  UserChallengeData({
    required this.challengeName,
    required this.isHost,
    required this.totalCertCount,
    required this.continuousCertCount,
    required this.posts,
  });

  /// 1. 최신순으로 정렬된 인증글 리스트 반환
  List<CertificationPost> get sortedPosts {
    // 원본 리스트를 보존하기 위해 복사본을 정렬하여 반환합니다.
    return List.from(posts)..sort((a, b) => b.date.compareTo(a.date));
  }

  /// 2. 특정 연도와 월에 해당하는 인증글만 필터링 (캘린더용)
  List<CertificationPost> getPostsByMonth(int year, int month) {
    return posts.where((post) {
      return post.date.year == year && post.date.month == month;
    }).toList();
  }

  /// 3. 특정 날짜(일)에 딱 맞는 인증글 찾기 (캘린더 클릭용)
  /// 해당 날짜에 글이 없으면 null을 반환합니다.
  CertificationPost? getPostByDay(DateTime day) {
    try {
      return posts.firstWhere(
        (post) =>
            post.date.year == day.year &&
            post.date.month == day.month &&
            post.date.day == day.day,
      );
    } catch (e) {
      return null;
    }
  }
}

/// 개별 인증글 상세 정보 모델
class CertificationPost {
  final String? userName; // 작성자 이름 (피드 화면에서 필요)
  final String content; // 인증글 내용
  final DateTime date; // 인증글 날짜
  final bool hasImage; // 인증글 사진 유무
  final String? imageUrl; // (선택) 사진이 있다면 이미지 경로
  final int likeCount; // 인증글 좋아요 수
  final List<ChallengeComment> comments; // 해당 글에 달린 댓글 리스트

  CertificationPost({
    this.userName = "Growth", // 기본값 설정 가능
    required this.content,
    required this.date,
    required this.hasImage,
    this.imageUrl,
    required this.likeCount,
    this.comments = const [], // 초기값은 빈 리스트
  });
}

/// 댓글 정보 모델
class ChallengeComment {
  final String id; // 댓글 고유 ID
  final String userName; // 작성자 이름 (예: 김코딩)
  final String userBadge; // 작성자 칭호/배지 (예: 올빼미)
  final String? profileUrl; // 프로필 이미지 경로 (Asset)
  final String content; // 댓글 내용
  final DateTime createdAt; // 작성일시
  final bool isMyComment; // 본인 댓글 여부 (수정/삭제 권한 분기용)

  ChallengeComment({
    required this.id,
    required this.userName,
    required this.userBadge,
    this.profileUrl,
    required this.content,
    required this.createdAt,
    this.isMyComment = false,
  });
}
