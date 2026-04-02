import 'package:haenaem/shared/models/user.dart';

// 최초 작성자: 강선욱
// 인증글 모델 클래스
// User에 정의된 필드(id, profileUrl, nickname)를 작성자 정보로 재사용
class Post {
  final int id; // 인증글 id
  final String title; // 인증글 제목
  final String content; // 인증글 내용
  final List<PostImage> images; // 인증글 사진
  final int likeCount; // 좋아요 수
  final bool isLiked; // 현재 로그인 유저의 좋아요 여부
  final int commentCount; // 댓글 수
  final DateTime date; // 작성 날짜
  final User writer; // 작성자 정보 (id, profileUrl, nickname)

  const Post({
    required this.id,
    required this.title,
    required this.content,
    required this.images,
    required this.likeCount,
    required this.isLiked,
    required this.commentCount,
    required this.date,
    required this.writer,
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    var imageList = json['images'] as List? ?? [];
    List<PostImage> parsedImages = imageList
        .map(
          (imageJson) => PostImage.fromJson(imageJson as Map<String, dynamic>),
        )
        .toList();

    return Post(
      id: json['postId'] as int,
      title: json['title'] as String,
      content: json['content'] as String,
      images: parsedImages,
      likeCount: json['likeNumber'] as int,
      isLiked: json['liked'] as bool,
      commentCount: json['commentNumber'] as int,
      date: DateTime.parse(json['updatedAt'] as String),
      writer: User(
        id: json['userId'] as int,
        nickname: json['userNickname'] as String? ?? '이름 없음',
        profileUrl: json['userImageUrl'] as String?,
      ),
    );
  }

  Post copyWith({
    int? id,
    String? title,
    String? content,
    List<PostImage>? images,
    int? likeCount,
    bool? isLiked,
    int? commentCount,
    DateTime? date,
    User? writer,
  }) {
    return Post(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      images: images ?? this.images,
      likeCount: likeCount ?? this.likeCount,
      isLiked: isLiked ?? this.isLiked,
      commentCount: commentCount ?? this.commentCount,
      date: date ?? this.date,
      writer: writer ?? this.writer,
    );
  }
}

// 인증글 사진 정보를 관리하는 클래스
class PostImage {
  final int imageId;
  final String imageUrl;

  PostImage({required this.imageId, required this.imageUrl});

  factory PostImage.fromJson(Map<String, dynamic> json) {
    return PostImage(
      imageId: json['imageId'] ?? 0,
      imageUrl: json['imageUrl'] ?? '',
    );
  }
}
