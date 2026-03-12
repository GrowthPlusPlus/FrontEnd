import 'package:haenaem/features/challenge/models/challenge_model.dart';

// 피드 상태를 관리하는 클래스
// 로딩 상태, 에러 상태 관리
class FeedState {
  final List<CertificationPostModel> posts;
  final bool isLoading;
  final String? errorMessage;
  final int currentPage; // 현재 페이지 번호
  final bool isLastPage; // 마지막 페이지 여부

  FeedState({
    this.posts = const [],
    this.isLoading = false,
    this.errorMessage,
    this.currentPage = 0, // 0부터 시작
    this.isLastPage = false,
  });

  FeedState copyWith({
    List<CertificationPostModel>? posts,
    bool? isLoading,
    String? errorMessage,
    int? currentPage,
    bool? isLastPage,
  }) {
    return FeedState(
      posts: posts ?? this.posts,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
      currentPage: currentPage ?? this.currentPage,
      isLastPage: isLastPage ?? this.isLastPage,
    );
  }
}
