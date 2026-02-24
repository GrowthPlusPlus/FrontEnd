// 최초 작성자: 정승빈
// 알림 데이터 모델 (enum으로 알림 타입 구분)
class NotificationModel {
  final String message;
  final String type;
  final String created; // "YYYY-MM-DD" 형태
  final bool read;
  final String? profileImageUrl;

  NotificationModel({
    required this.message,
    required this.type,
    required this.created,
    required this.read,
    this.profileImageUrl,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      message: json['message'] ?? '',
      type: json['type'] ?? 'UNKNOWN',
      created: json['created'] ?? '',
      read: json['read'] ?? false,
      profileImageUrl: json['imageUrl'], // 백엔드에서 이 필드를 제공한다고 가정
    );
  }

  NotificationModel copyWith({
    String? message,
    String? type,
    String? created,
    bool? read,
    String? profileImageUrl,
  }) {
    return NotificationModel(
      message: message ?? this.message,
      type: type ?? this.type,
      created: created ?? this.created,
      read: read ?? this.read,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
    );
  }
}
