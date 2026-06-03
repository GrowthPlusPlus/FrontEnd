import 'package:haenaem/shared/models/user.dart';

// 최초 작성자: 강선욱
// 댓글 모델 클래스
// User에 정의된 필드(id, profileUrl, nickname)를 작성자 정보로 재사용
class Comment {
  final int id; // 댓글 id
  final String content; // 댓글 내용
  final DateTime date; // 댓글 작성(또는 수정) 날짜
  final bool isEdited; // 댓글 수정 여부
  final User writer; // 작성자 정보 (id, profileUrl, nickname)
  final bool isMine; // 현재 로그인 유저의 댓글 여부

  const Comment({
    required this.id,
    required this.content,
    required this.date,
    required this.isEdited,
    required this.writer,
    required this.isMine,
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    // 1. 날짜 파싱: 기존 모델의 로직을 참고하여 updatedAt 우선, 없으면 createdAt 사용
    DateTime parsedDate = DateTime.now();
    if (json['updatedAt'] != null) {
      parsedDate = DateTime.parse(json['updatedAt'].toString()).toLocal();
    } else if (json['createdAt'] != null) {
      parsedDate = DateTime.parse(json['createdAt'].toString()).toLocal();
    }

    // 2. 작성자 정보 조립: 서버의 평면적 데이터를 Nested User 객체로 매핑
    final writer = User(
      id: json['userId'] ?? 0,
      nickname: json['userNickname'] ?? '익명', // 기존 로직 참고하여 기본값 '익명' 부여
      profileUrl: json['userPicture'],
    );

    return Comment(
      id: json['commentId'] ?? 0, // id -> commentId
      content: json['contents'] ?? '', // content -> contents
      date: parsedDate,
      isEdited: json['edited'] ?? false, // is_edited -> edited
      writer: writer,
      isMine: json['mine'] ?? false, // is_mine -> mine
    );
  }

  Comment copyWith({
    int? id,
    String? content,
    DateTime? date,
    bool? isEdited,
    User? writer,
    bool? isMine,
  }) {
    return Comment(
      id: id ?? this.id,
      content: content ?? this.content,
      date: date ?? this.date,
      isEdited: isEdited ?? this.isEdited,
      writer: writer ?? this.writer,
      isMine: isMine ?? this.isMine,
    );
  }
}
