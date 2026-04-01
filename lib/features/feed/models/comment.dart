import 'package:haenaem/shared/models/user.dart';

// 최초 작성자: 강선욱
// 댓글 모델 클래스
// User에 정의된 필드(id, profileUrl, nickname)를 작성자 정보로 재사용
class Comment {
  final int id; // 댓글 id
  final String content; // 댓글 내용
  final DateTime date; // 초기 댓글 작성 날짜
  final bool isEdited; // 댓글 수정 여부
  final User writer; // 작성자 정보 (id, profileUrl, nickname)

  const Comment({
    required this.id,
    required this.content,
    required this.date,
    required this.isEdited,
    required this.writer,
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      id: json['id'] as int,
      content: json['content'] as String,
      date: DateTime.parse(json['date'] as String),
      isEdited: json['is_edited'] as bool,
      writer: User.fromJson(json['writer'] as Map<String, dynamic>),
    );
  }

  Comment copyWith({
    int? id,
    String? content,
    DateTime? date,
    bool? isEdited,
    User? writer,
  }) {
    return Comment(
      id: id ?? this.id,
      content: content ?? this.content,
      date: date ?? this.date,
      isEdited: isEdited ?? this.isEdited,
      writer: writer ?? this.writer,
    );
  }
}
