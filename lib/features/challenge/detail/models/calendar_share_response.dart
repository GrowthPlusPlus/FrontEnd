enum ShareStatus { processing, completed, failed }

class CalendarShareResponse {
  final int challengeId;
  final String? imageUrl;
  final DateTime? updateAt;
  final ShareStatus status;

  CalendarShareResponse({
    required this.challengeId,
    this.imageUrl,
    this.updateAt,
    required this.status,
  });

  factory CalendarShareResponse.fromJson(Map<String, dynamic> json) {
    return CalendarShareResponse(
      challengeId: json['challengeId'] ?? 0,
      imageUrl: json['imageUrl'],
      updateAt: json['updateAt'] != null
          ? DateTime.tryParse(json['updateAt'].toString())
          : null,
      status: _parseStatus(json['status']),
    );
  }

  static ShareStatus _parseStatus(String? status) {
    switch (status?.toUpperCase()) {
      case 'COMPLETED':
        return ShareStatus.completed;
      case 'FAILED':
        return ShareStatus.failed;
      case 'PROCESSING':
      default:
        return ShareStatus.processing;
    }
  }
}
