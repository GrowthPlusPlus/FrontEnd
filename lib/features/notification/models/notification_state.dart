import './notification_model.dart';

// 최초 작성자: 정승빈
// 리팩토링: 강선욱

// 상태 클래스 정의
class NotificationState {
  final List<NotificationModel> notifications;
  final bool isLoading;
  final bool isFetchingMore; // 추가 페이징 로딩 중
  final bool hasMore; // 다음 페이지 존재 여부
  final int currentPage;

  NotificationState({
    required this.notifications,
    this.isLoading = false,
    this.isFetchingMore = false,
    this.hasMore = true,
    this.currentPage = 0,
  });

  NotificationState copyWith({
    List<NotificationModel>? notifications,
    bool? isLoading,
    bool? isFetchingMore,
    bool? hasMore,
    int? currentPage,
  }) {
    return NotificationState(
      notifications: notifications ?? this.notifications,
      isLoading: isLoading ?? this.isLoading,
      isFetchingMore: isFetchingMore ?? this.isFetchingMore,
      hasMore: hasMore ?? this.hasMore,
      currentPage: currentPage ?? this.currentPage,
    );
  }
}
