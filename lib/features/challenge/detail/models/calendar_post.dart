// 최초 작성자 : 강선욱
// 캘린더 달력 셀 및 인증글 목록 렌더링에 필요한 최소 데이터 모델
// 상세 페이지 진입 시에는 postId만 넘기고 Post 모델을 별도로 조회

class CalendarPost {
  final int postId;
  final String postDate;
  final String? imageUrl;
  final String content;

  const CalendarPost({
    required this.postId,
    required this.postDate,
    this.imageUrl,
    required this.content,
  });

  factory CalendarPost.fromJson(Map<String, dynamic> json) {
    return CalendarPost(
      postId: json['postId'] as int,
      postDate: json['postDate'] as String,
      imageUrl: json['imageUrl'] as String?,
      content: json['content'] as String,
    );
  }
}
