import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:haenaem/core/theme/app_colors.dart';
import 'package:haenaem/core/theme/app_typography.dart';
import '../provider/report_provider.dart';
import '../widgets/report_card.dart';
import '../screens/report_detail_screen.dart';

// 최초 작성자: 강선욱
// 관리자 신고 목록 탭 뷰 (게시글 / 댓글 공용)

// ─────────────────────────────────────────
// 게시글 탭 뷰
// ─────────────────────────────────────────

class ArticleView extends ConsumerStatefulWidget {
  final ScrollController scrollController;

  const ArticleView({super.key, required this.scrollController});

  @override
  ConsumerState<ArticleView> createState() => _ReportedArticleViewState();
}

class _ReportedArticleViewState extends ConsumerState<ArticleView>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final currentState = ref.read(reportedArticleProvider);
      if (currentState.articles.isEmpty) {
        ref.read(reportedArticleProvider.notifier).fetchReportedArticles();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final state = ref.watch(reportedArticleProvider);

    if (state.isLoading && state.articles.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.errorMessage != null) {
      return _ErrorView(
        message: state.errorMessage!,
        onRetry: () =>
            ref.read(reportedArticleProvider.notifier).fetchReportedArticles(),
      );
    }

    if (state.articles.isEmpty) {
      return _EmptyView(
        message: '신고된 게시글이 없습니다.',
        onRefresh: () =>
            ref.read(reportedArticleProvider.notifier).fetchReportedArticles(),
      );
    }

    return RefreshIndicator(
      onRefresh: () =>
          ref.read(reportedArticleProvider.notifier).fetchReportedArticles(),
      child: ListView.separated(
        controller: widget.scrollController,
        // 카드 위아래 패딩 공간 확보를 위한 상하단 패딩 추가
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: state.articles.length,
        // 카드 자체 여백이 있으므로 투명 여백으로 간격 조절
        separatorBuilder: (_, __) => const SizedBox(height: 4),
        itemBuilder: (context, index) {
          final article = state.articles[index];
          return ReportCard(
            report: article,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => Consumer(
                    builder: (context, ref, _) {
                      final detailState = ref.watch(
                        articleReportDetailProvider(article.articleId),
                      );

                      if (detailState.isLoading) {
                        return const Scaffold(
                          body: Center(child: CircularProgressIndicator()),
                        );
                      }
                      if (detailState.errorMessage != null ||
                          detailState.detail == null) {
                        return Scaffold(
                          body: Center(
                            child: Text(detailState.errorMessage ?? '에러 발생'),
                          ),
                        );
                      }
                      return ReportDetailScreen(detail: detailState.detail!);
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

// -- 댓글 탭 뷰 --

class CommentView extends ConsumerStatefulWidget {
  final ScrollController scrollController;

  const CommentView({super.key, required this.scrollController});

  @override
  ConsumerState<CommentView> createState() => _ReportedCommentViewState();
}

class _ReportedCommentViewState extends ConsumerState<CommentView>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final currentState = ref.read(reportedCommentProvider);
      if (currentState.comments.isEmpty) {
        ref.read(reportedCommentProvider.notifier).fetchReportedComments();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final state = ref.watch(reportedCommentProvider);

    if (state.isLoading && state.comments.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.errorMessage != null) {
      return _ErrorView(
        message: state.errorMessage!,
        onRetry: () =>
            ref.read(reportedCommentProvider.notifier).fetchReportedComments(),
      );
    }

    if (state.comments.isEmpty) {
      return _EmptyView(
        message: '신고된 댓글이 없습니다.',
        onRefresh: () =>
            ref.read(reportedCommentProvider.notifier).fetchReportedComments(),
      );
    }

    return RefreshIndicator(
      onRefresh: () =>
          ref.read(reportedCommentProvider.notifier).fetchReportedComments(),
      child: ListView.separated(
        controller: widget.scrollController,
        padding: const EdgeInsets.symmetric(vertical: 8),
        // 🛠 버그 수정: state.articles.length -> state.comments.length
        itemCount: state.comments.length,
        separatorBuilder: (_, __) => const SizedBox(height: 4),
        itemBuilder: (context, index) {
          // 🛠 버그 수정: state.articles[index] -> state.comments[index]
          final comment = state.comments[index];
          return ReportCard(
            report: comment,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => Consumer(
                    builder: (context, ref, _) {
                      final detailState = ref.watch(
                        commentReportDetailProvider(comment.commentId),
                      );

                      if (detailState.isLoading) {
                        return const Scaffold(
                          body: Center(
                            child: CircularProgressIndicator(
                              color: AppColors.black,
                            ),
                          ),
                        );
                      }

                      if (detailState.errorMessage != null ||
                          detailState.detail == null) {
                        return Scaffold(
                          appBar: AppBar(
                            backgroundColor: Colors.white,
                            elevation: 0,
                          ),
                          body: Center(
                            child: Text(
                              detailState.errorMessage ?? '상세 정보를 가져올 수 없습니다.',
                            ),
                          ),
                        );
                      }

                      return ReportDetailScreen(detail: detailState.detail!);
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

// ─────────────────────────────────────────
// 공용 위젯
// ─────────────────────────────────────────

/// 빈 목록 뷰
class _EmptyView extends StatelessWidget {
  final String message;
  final Future<void> Function() onRefresh;

  const _EmptyView({required this.message, required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(height: MediaQuery.of(context).size.height * 0.3),
          Center(
            child: Text(
              message,
              style: AppTypography.b1.copyWith(color: AppColors.gray4),
            ),
          ),
        ],
      ),
    );
  }
}

/// 에러 뷰
class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            message,
            style: AppTypography.b1.copyWith(color: AppColors.gray4),
          ),
          const SizedBox(height: 16),
          TextButton(
            onPressed: onRetry,
            child: Text(
              '다시 시도',
              style: AppTypography.b1.copyWith(color: AppColors.primaryAble),
            ),
          ),
        ],
      ),
    );
  }
}
