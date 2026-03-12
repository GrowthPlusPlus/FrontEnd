import 'package:haenaem/shared/models/user.dart';

// 최초 작성자: 강선욱
// 인증글 모델 클래스
// User에 정의된 필드(id, profileUrl, nickname)를 작성자 정보로 재사용
class Post {
  final String title; // 인증글 제목
  final String content; // 인증글 내용
  final String? pictureUrl; // 인증글 사진 주소
  final int likeCount; // 좋아요 수
  final bool isLiked; // 현재 로그인 유저의 좋아요 여부
  final int commentCount; // 댓글 수
  final DateTime date; // 작성 날짜
  final User writer; // 작성자 정보 (id, profileUrl, nickname)

  const Post({
    required this.title,
    required this.content,
    this.pictureUrl,
    required this.likeCount,
    required this.isLiked,
    required this.commentCount,
    required this.date,
    required this.writer,
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      title: json['title'] as String,
      content: json['content'] as String,
      pictureUrl: json['picture_url'] as String?,
      likeCount: json['like_count'] as int,
      isLiked: json['is_liked'] as bool,
      commentCount: json['comment_count'] as int,
      date: DateTime.parse(json['date'] as String),
      writer: User.fromJson(json['writer'] as Map<String, dynamic>),
    );
  }

  Post copyWith({
    String? title,
    String? content,
    String? pictureUrl,
    int? likeCount,
    bool? isLiked,
    int? commentCount,
    DateTime? date,
    User? writer,
  }) {
    return Post(
      title: title ?? this.title,
      content: content ?? this.content,
      pictureUrl: pictureUrl ?? this.pictureUrl,
      likeCount: likeCount ?? this.likeCount,
      isLiked: isLiked ?? this.isLiked,
      commentCount: commentCount ?? this.commentCount,
      date: date ?? this.date,
      writer: writer ?? this.writer,
    );
  }
}
