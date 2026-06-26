import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/report.dart';
import '../data/report_repository.dart';

// 최초 작성자: 강선욱
// 관리자 신고 목록 상태 관리 프로바이더

// ─────────────────────────────────────────
// State 클래스
// ─────────────────────────────────────────

class ReportedArticleState {
  final List<ReportedArticleSummary> articles;
  final bool isLoading;
  final String? errorMessage;

  const ReportedArticleState({
    this.articles = const [],
    this.isLoading = false,
    this.errorMessage,
  });

  ReportedArticleState copyWith({
    List<ReportedArticleSummary>? articles,
    bool? isLoading,
    String? errorMessage,
  }) {
    return ReportedArticleState(
      articles: articles ?? this.articles,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

class ReportedCommentState {
  final List<ReportedCommentSummary> comments;
  final bool isLoading;
  final String? errorMessage;

  const ReportedCommentState({
    this.comments = const [],
    this.isLoading = false,
    this.errorMessage,
  });

  ReportedCommentState copyWith({
    List<ReportedCommentSummary>? comments,
    bool? isLoading,
    String? errorMessage,
  }) {
    return ReportedCommentState(
      comments: comments ?? this.comments,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

class ArticleReportDetailState {
  final ArticleReportDetail? detail;
  final bool isLoading;
  final String? errorMessage;

  const ArticleReportDetailState({
    this.detail,
    this.isLoading = false,
    this.errorMessage,
  });

  ArticleReportDetailState copyWith({
    ArticleReportDetail? detail,
    bool? isLoading,
    String? errorMessage,
  }) {
    return ArticleReportDetailState(
      detail: detail ?? this.detail,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

class CommentReportDetailState {
  final CommentReportDetail? detail;
  final bool isLoading;
  final String? errorMessage;

  const CommentReportDetailState({
    this.detail,
    this.isLoading = false,
    this.errorMessage,
  });

  CommentReportDetailState copyWith({
    CommentReportDetail? detail,
    bool? isLoading,
    String? errorMessage,
  }) {
    return CommentReportDetailState(
      detail: detail ?? this.detail,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

// ─────────────────────────────────────────
// Notifier - 게시글
// ─────────────────────────────────────────

class ReportedArticleNotifier extends StateNotifier<ReportedArticleState> {
  final AdminReportRepository _repository;

  ReportedArticleNotifier(this._repository)
    : super(const ReportedArticleState());

  Future<void> fetchReportedArticles() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final list = await _repository.fetchReportedArticles();
      state = state.copyWith(articles: list, isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: '게시글 목록을 불러오지 못했습니다.',
      );
    }
  }

  void removeArticleFromList(int articleId) {
    final updatedList = state.articles
        .where((item) => item.articleId != articleId)
        .toList();
    state = state.copyWith(articles: updatedList);
  }
}

// ─────────────────────────────────────────
// Notifier - 댓글
// ─────────────────────────────────────────

class ReportedCommentNotifier extends StateNotifier<ReportedCommentState> {
  final AdminReportRepository _repository;

  ReportedCommentNotifier(this._repository)
    : super(const ReportedCommentState());

  Future<void> fetchReportedComments() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final list = await _repository.fetchReportedComments();
      state = state.copyWith(comments: list, isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: '댓글 목록을 불러오지 못했습니다.',
      );
    }
  }

  void removeCommentFromList(int commentId) {
    final updatedList = state.comments
        .where((item) => item.commentId != commentId)
        .toList();
    state = state.copyWith(comments: updatedList);
  }
}

// ─────────────────────────────────────────
// Notifier - 상세 내용 조회
// ─────────────────────────────────────────

class ArticleReportDetailNotifier
    extends StateNotifier<ArticleReportDetailState> {
  final AdminReportRepository _repository;
  final Ref _ref;
  final int _articleId;

  ArticleReportDetailNotifier(this._repository, this._ref, this._articleId)
    : super(const ArticleReportDetailState()) {
    // 생성 시점에 자동으로 백엔드에 상세 데이터를 조회하도록 구현
    fetchDetail();
  }

  Future<void> fetchDetail() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final data = await _repository.fetchArticleReportDetail(_articleId);
      state = state.copyWith(detail: data, isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: '게시글 상세 정보를 불러오지 못했습니다.',
      );
    }
  }

  Future<bool> dismissReport(int reportId) async {
    state = state.copyWith(isLoading: true);
    try {
      final success = await _repository.dismissArticleReport(
        _articleId,
        reportId,
      );
      if (success) {
        // 성공 시 목록에서도 해당 아이템 필터링(삭제)
        _ref
            .read(reportedArticleProvider.notifier)
            .removeArticleFromList(_articleId);
        state = state.copyWith(detail: null, isLoading: false);
        return true;
      }
      return false;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      );
      return false;
    }
  }

  Future<bool> deleteArticle() async {
    state = state.copyWith(isLoading: true);
    try {
      final success = await _repository.deleteArticleByAdmin(_articleId);
      if (success) {
        // 성공 시 목록에서도 해당 아이템 필터링(삭제)
        _ref
            .read(reportedArticleProvider.notifier)
            .removeArticleFromList(_articleId);
        state = state.copyWith(detail: null, isLoading: false);
        return true;
      }
      return false;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      );
      return false;
    }
  }
}

class CommentReportDetailNotifier
    extends StateNotifier<CommentReportDetailState> {
  final AdminReportRepository _repository;
  final Ref _ref;
  final int _commentId;

  CommentReportDetailNotifier(this._repository, this._ref, this._commentId)
    : super(const CommentReportDetailState()) {
    fetchDetail();
  }

  Future<void> fetchDetail() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final data = await _repository.fetchCommentReportDetail(_commentId);
      state = state.copyWith(detail: data, isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: '댓글 상세 정보를 불러오지 못했습니다.',
      );
    }
  }

  Future<bool> dismissReport(int reportId) async {
    state = state.copyWith(isLoading: true);
    try {
      final success = await _repository.dismissCommentReport(
        _commentId,
        reportId,
      );
      if (success) {
        _ref
            .read(reportedCommentProvider.notifier)
            .removeCommentFromList(_commentId);
        state = state.copyWith(detail: null, isLoading: false);
        return true;
      }
      return false;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      );
      return false;
    }
  }

  Future<bool> deleteComment() async {
    state = state.copyWith(isLoading: true);
    try {
      final success = await _repository.deleteCommentByAdmin(_commentId);
      if (success) {
        _ref
            .read(reportedCommentProvider.notifier)
            .removeCommentFromList(_commentId);
        state = state.copyWith(detail: null, isLoading: false);
        return true;
      }
      return false;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      );
      return false;
    }
  }
}

// ─────────────────────────────────────────
// Provider 인스턴스
// ─────────────────────────────────────────

final reportedArticleProvider =
    StateNotifierProvider<ReportedArticleNotifier, ReportedArticleState>((ref) {
      final repository = ref.watch(adminReportRepositoryProvider);
      return ReportedArticleNotifier(repository);
    });

final reportedCommentProvider =
    StateNotifierProvider<ReportedCommentNotifier, ReportedCommentState>((ref) {
      final repository = ref.watch(adminReportRepositoryProvider);
      return ReportedCommentNotifier(repository);
    });

final articleReportDetailProvider =
    StateNotifierProvider.family<
      ArticleReportDetailNotifier,
      ArticleReportDetailState,
      int
    >((ref, articleId) {
      final repository = ref.watch(adminReportRepositoryProvider);
      return ArticleReportDetailNotifier(repository, ref, articleId);
    });

final commentReportDetailProvider =
    StateNotifierProvider.family<
      CommentReportDetailNotifier,
      CommentReportDetailState,
      int
    >((ref, commentId) {
      final repository = ref.watch(adminReportRepositoryProvider);
      return CommentReportDetailNotifier(repository, ref, commentId);
    });
