import 'package:haenaem/shared/models/user.dart';
// import 'package:haenaem/features/challenge/models/image_model.dart';

// 최초 작성자: 강선욱
// 인증글 모델 클래스
// User에 정의된 필드(id, profileUrl, nickname)를 작성자 정보로 재사용
class Post {
  final int id; // 인증글 id
  final String title; // 인증글 제목
  final String content; // 인증글 내용
  final List<PostImage> pictureUrl; // 인증글 사진 URL 리스트
  final int likeCount; // 좋아요 수
  final bool isLiked; // 현재 로그인 유저의 좋아요 여부
  final int commentCount; // 댓글 수
  final DateTime date; // 작성 날짜
  final User writer; // 작성자 정보 (id, profileUrl, nickname)
  final int challengeId; // 챌린지 id
  final String challengeTitle; // 챌린지 제목
  final int totalSuccessDays; // 챌린지 총 성공 일수

  final bool isAuthor; // 작성자 본인 여부 (수정/삭제 권한)
  final bool isEdited; // 수정된 게시글 여부

  // 편의 메서드: 사진이 있는지 여부와 첫 번째 사진 URL을 쉽게 접근할 수 있도록 합니다.
  bool get hasImage => pictureUrl.isNotEmpty;
  // 첫 번째 사진 URL을 반환하는 편의 메서드입니다. 사진이 없으면 null을 반환합니다.
  String? get imageUrl =>
      pictureUrl.isNotEmpty ? pictureUrl.first.imageUrl : null;

  const Post({
    required this.id,
    required this.title,
    required this.content,
    required this.pictureUrl,
    required this.likeCount,
    required this.isLiked,
    required this.commentCount,
    required this.date,
    required this.writer,
    required this.challengeId,
    required this.challengeTitle,
    required this.totalSuccessDays,
    required this.isAuthor,
    required this.isEdited,
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    // 1. 날짜 파싱: updatedAt이 있으면 우선 사용하고, 없으면 createdAt 사용
    DateTime parsedDate = DateTime.now();
    if (json['updatedAt'] != null) {
      parsedDate = DateTime.parse(json['updatedAt'].toString()).toLocal();
    } else if (json['createdAt'] != null) {
      parsedDate = DateTime.parse(json['createdAt'].toString()).toLocal();
    }

    // 2. 작성자 정보 조립: 서버의 평면적 데이터를 Nested User 객체로 매핑
    final writer = User(
      id: json['userId'] ?? 0,
      nickname: json['userNickname'] ?? '익명',
      profileUrl: json['userImageUrl'],
    );

    return Post(
      id: json['postId'] ?? 0,
      challengeId: json['challengeId'] ?? 0,
      challengeTitle: json['challengeTitle'] ?? '',
      totalSuccessDays: json['totalSuccessDays'] ?? 0,
      title: json['title'] ?? '',
      content: json['content'] ?? '',
      pictureUrl:
          (json['images'] as List<dynamic>?)
              ?.map((e) => PostImage.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      likeCount: json['likeNumber'] ?? 0,
      isLiked: json['liked'] ?? false,
      commentCount: json['commentNumber'] ?? 0,
      date: parsedDate,
      writer: writer,
      isAuthor: json['author'] ?? false,
      isEdited: json['edited'] ?? false,
    );
  }

  Post copyWith({
    int? id,
    String? title,
    String? content,
    List<PostImage>? pictureUrl,
    int? likeCount,
    bool? isLiked,
    int? commentCount,
    DateTime? date,
    User? writer,
    int? challengeId,
    String? challengeTitle,
    int? totalSuccessDays,
    bool? isAuthor,
    bool? isEdited,
  }) {
    return Post(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      pictureUrl: pictureUrl ?? this.pictureUrl,
      likeCount: likeCount ?? this.likeCount,
      isLiked: isLiked ?? this.isLiked,
      commentCount: commentCount ?? this.commentCount,
      date: date ?? this.date,
      writer: writer ?? this.writer,
      challengeId: challengeId ?? this.challengeId,
      challengeTitle: challengeTitle ?? this.challengeTitle,
      totalSuccessDays: totalSuccessDays ?? this.totalSuccessDays,
      isAuthor: isAuthor ?? this.isAuthor,
      isEdited: isEdited ?? this.isEdited,
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
