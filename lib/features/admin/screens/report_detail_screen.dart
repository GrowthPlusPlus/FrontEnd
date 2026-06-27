import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:haenaem/core/theme/app_colors.dart';
import 'package:haenaem/core/theme/app_typography.dart';
import '../models/report.dart';
import '../provider/report_provider.dart';

class ReportDetailScreen extends ConsumerStatefulWidget {
  /// ArticleReportDetail 또는 CommentReportDetail 타입을 받습니다.
  final dynamic detail;

  const ReportDetailScreen({super.key, required this.detail})
    : assert(
        detail is ArticleReportDetail || detail is CommentReportDetail,
        'detail 매개변수는 ArticleReportDetail 또는 CommentReportDetail 타입이어야 합니다.',
      );

  @override
  ConsumerState<ReportDetailScreen> createState() => _ReportDetailScreenState();
}

class _ReportDetailScreenState extends ConsumerState<ReportDetailScreen> {
  int _currentImagePage = 0;
  bool _isProcessing = false;

  @override
  Widget build(BuildContext context) {
    final bool isArticle = widget.detail is ArticleReportDetail;

    final int reportId = isArticle
        ? (widget.detail as ArticleReportDetail).reportId
        : (widget.detail as CommentReportDetail).reportId;
    final String reporterName = isArticle
        ? (widget.detail as ArticleReportDetail).reporterName
        : (widget.detail as CommentReportDetail).reporterName;
    final String reportReason = isArticle
        ? (widget.detail as ArticleReportDetail).reportReason
        : (widget.detail as CommentReportDetail).reportReason;
    final String? detailReason = isArticle
        ? (widget.detail as ArticleReportDetail).detailReason
        : (widget.detail as CommentReportDetail).detailReason;

    final String? challengeName = isArticle
        ? (widget.detail as ArticleReportDetail).challengeName
        : (widget.detail as CommentReportDetail).challengeName;
    final int targetId = isArticle
        ? (widget.detail as ArticleReportDetail).articleId
        : (widget.detail as CommentReportDetail).commentId;
    final String content = isArticle
        ? (widget.detail as ArticleReportDetail).articleContent
        : (widget.detail as CommentReportDetail).commentContent;

    final String? singleImageUrl = isArticle
        ? (widget.detail as ArticleReportDetail).imageUrl
        : null;
    final List<String> imageUrls =
        (singleImageUrl != null && singleImageUrl.isNotEmpty)
        ? [singleImageUrl]
        : [];

    final dynamic currentProvider = isArticle
        ? articleReportDetailProvider(targetId)
        : commentReportDetailProvider(targetId);
    final dynamic detailState = ref.watch(currentProvider);
    final bool isLoading = detailState.isLoading;

    final TextStyle blackBoldStyle = AppTypography.b1.copyWith(
      color: AppColors.black,
      fontWeight: FontWeight.bold,
    );
    final TextStyle blackLabelStyle = AppTypography.b2.copyWith(
      color: AppColors.black,
      // fontWeight: FontWeight.w600,
    );
    final TextStyle blackBodyStyle = AppTypography.b2.copyWith(
      color: AppColors.black,
    );

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: Text(
          isArticle ? '게시글 신고 상세' : '댓글 신고 상세',
          style: AppTypography.h3.copyWith(color: AppColors.black),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: SvgPicture.asset(
            'assets/images/icons/arrow_left.svg',
            width: 24,
            height: 24,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionCard(
                title: '신고 정보',
                titleStyle: AppTypography.b1.copyWith(color: AppColors.black),
                children: [
                  _buildInfoRow(
                    '신고자 이름',
                    reporterName,
                    blackLabelStyle,
                    blackBodyStyle,
                  ),
                  _buildInfoRow(
                    '신고 유형',
                    _translateReason(reportReason),
                    blackLabelStyle,
                    blackBodyStyle,
                  ),
                  if (detailReason != null && detailReason.isNotEmpty) ...[
                    const SizedBox(height: 14),
                    Text('상세 신고 사유', style: blackLabelStyle),
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F3F5),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        detailReason,
                        style: blackBodyStyle.copyWith(height: 1.4),
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 16),

              _buildSectionCard(
                title: isArticle ? '게시글 정보' : '댓글 정보',
                titleStyle: AppTypography.b1.copyWith(color: AppColors.black),
                children: [
                  _buildInfoRow(
                    '챌린지 이름',
                    challengeName ?? '지정되지 않음',
                    blackLabelStyle,
                    blackBodyStyle,
                  ),
                  _buildInfoRow(
                    isArticle ? '게시글 ID' : '댓글 ID',
                    '# $targetId',
                    blackLabelStyle,
                    blackBodyStyle,
                  ),
                  if (!isArticle) // 댓글일 경우 원문 게시글 ID 추가 표시
                    _buildInfoRow(
                      '원문 게시글 ID',
                      '# ${(widget.detail as CommentReportDetail).articleId}',
                      blackLabelStyle,
                      blackBodyStyle,
                    ),

                  const SizedBox(height: 14),
                  Text(isArticle ? '게시글 내용' : '댓글 내용', style: blackLabelStyle),
                  const SizedBox(height: 8),

                  // 본문 텍스트 박스
                  Container(
                    width: double.infinity,
                    constraints: const BoxConstraints(minHeight: 80),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: const Color(0xFFE9ECEF)),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      content.isNotEmpty ? content : '내용이 비어있습니다.',
                      style: blackBodyStyle.copyWith(height: 1.4),
                    ),
                  ),

                  if (imageUrls.isNotEmpty) ...[
                    const SizedBox(height: 14),
                    Text('첨부 사진', style: blackLabelStyle),
                    const SizedBox(height: 8),

                    // 기존 FeedPostCard 가로 규격 핏 매칭
                    SizedBox(
                      height: 340,
                      width: double.infinity,
                      child: PageView.builder(
                        itemCount: imageUrls.length,
                        onPageChanged: (index) {
                          setState(() {
                            _currentImagePage = index;
                          });
                        },
                        itemBuilder: (context, index) {
                          final String fullUrl = imageUrls[index];

                          return ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              fullUrl,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              loadingBuilder:
                                  (context, child, loadingProgress) {
                                    if (loadingProgress == null) return child;
                                    return Container(
                                      color: const Color(0xFFE9ECEF),
                                      child: const Center(
                                        child: CircularProgressIndicator(
                                          color: AppColors.black,
                                        ),
                                      ),
                                    );
                                  },
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  color: const Color(0xFFE9ECEF),
                                  child: Center(
                                    child: Text(
                                      '이미지를 불러올 수 없습니다.',
                                      style: blackBodyStyle.copyWith(
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      ),
                    ),

                    if (imageUrls.length > 1)
                      Padding(
                        padding: const EdgeInsets.only(top: 10, bottom: 5),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(imageUrls.length, (index) {
                            return Container(
                              width: 6,
                              height: 6,
                              margin: const EdgeInsets.symmetric(horizontal: 3),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                // 글씨톤에 맞춰 활성화 점은 검은색, 비활성화 점은 부드러운 회색 매칭
                                color: _currentImagePage == index
                                    ? AppColors.black
                                    : const Color(0xFFDDE2E5),
                              ),
                            );
                          }),
                        ),
                      ),
                  ],
                ],
              ),
              const SizedBox(height: 32),

              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: (_isProcessing || isLoading)
                          ? null // 💡 통신 중 조작 방지 기본 락
                          : () async {
                              setState(() {
                                _isProcessing = true;
                              });

                              ref
                                  .read(currentProvider.notifier)
                                  .dismissReport(reportId)
                                  .catchError((_) => false);

                              ref.invalidate(currentProvider);

                              if (isArticle) {
                                ref
                                    .read(reportedArticleProvider.notifier)
                                    .fetchReportedArticles();
                              } else {
                                ref
                                    .read(reportedCommentProvider.notifier)
                                    .fetchReportedComments();
                              }

                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('신고가 기각되었습니다.')),
                              );
                              Navigator.of(context).pop();
                            },
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: const BorderSide(color: AppColors.black),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        '신고 기각',
                        style: blackBoldStyle.copyWith(fontSize: 14),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: (_isProcessing || isLoading)
                          ? null
                          : () async {
                              setState(() {
                                _isProcessing = true;
                              });

                              final notifier = ref.read(
                                currentProvider.notifier,
                              );
                              if (isArticle) {
                                notifier.deleteArticle().catchError(
                                  (_) => false,
                                );
                              } else {
                                notifier.deleteComment().catchError(
                                  (_) => false,
                                );
                              }

                              ref.invalidate(currentProvider);

                              if (isArticle) {
                                ref
                                    .read(reportedArticleProvider.notifier)
                                    .fetchReportedArticles();
                              } else {
                                ref
                                    .read(reportedCommentProvider.notifier)
                                    .fetchReportedComments();
                              }

                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('컨텐츠가 차단 및 삭제되었습니다.'),
                                ),
                              );
                              Navigator.of(context).pop();
                            },
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: const BorderSide(color: AppColors.black),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        '삭제 / 블라인드',
                        style: blackBoldStyle.copyWith(fontSize: 14),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 섹션 컴포넌트 위젯 빌더
  Widget _buildSectionCard({
    required String title,
    required TextStyle titleStyle,
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE9ECEF)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: titleStyle),
          const SizedBox(height: 12),
          const Divider(height: 1, thickness: 1, color: Color(0xFFF1F3F5)),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }

  // 정보 한 줄 위젯 빌더 (레이블과 밸류 모두 검은색 텍스트 지정)
  Widget _buildInfoRow(
    String label,
    String value,
    TextStyle labelStyle,
    TextStyle valueStyle, {
    bool isBadge = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 100, child: Text(label, style: labelStyle)),
          Expanded(
            child: isBadge
                ? Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F3F5),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: AppColors.black, width: 1),
                        ),
                        child: Text(
                          value,
                          style: valueStyle.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  )
                : Text(value, style: valueStyle),
          ),
        ],
      ),
    );
  }

  // 신고 사유 변환 메소드
  String _translateReason(String reason) {
    switch (reason.toUpperCase()) {
      case 'SPAM':
        return '스팸 / 도배성';
      case 'INSULT':
        return '욕설 및 비방';
      case 'INAPPROPRIATE':
        return '부적절한 콘텐츠';
      default:
        return reason;
    }
  }
}
