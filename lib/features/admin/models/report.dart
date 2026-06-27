// 최초 작성자: 강선욱
// 관리자 페이지 신고 모델 (게시글 / 댓글)

class ReportedArticleSummary {
  final int articleId;
  final String? challengeName;
  final int totalCount;

  const ReportedArticleSummary({
    required this.articleId,
    required this.challengeName,
    required this.totalCount,
  });

  factory ReportedArticleSummary.fromJson(Map<String, dynamic> json) {
    return ReportedArticleSummary(
      articleId: json['articleId'] as int,
      challengeName: json['challengeName'] as String?,
      totalCount: json['totalReport'] as int,
    );
  }
}

class ReportedCommentSummary {
  final int commentId;
  final String? challengeName;
  final int totalCount;

  const ReportedCommentSummary({
    required this.commentId,
    required this.challengeName,
    required this.totalCount,
  });

  factory ReportedCommentSummary.fromJson(Map<String, dynamic> json) {
    return ReportedCommentSummary(
      commentId: json['commentId'] as int,
      challengeName: json['challengeName'] as String?,
      totalCount: json['totalReport'] as int,
    );
  }
}

class ArticleReportDetail {
  final int reportId;
  final int reporterId;
  final String reporterName;
  final String? challengeName;
  final int articleId;
  final String articleContent;
  final String? imageUrl;
  final String reportReason;
  final String? detailReason;

  const ArticleReportDetail({
    required this.reportId,
    required this.reporterId,
    required this.reporterName,
    required this.challengeName,
    required this.articleId,
    required this.articleContent,
    required this.imageUrl,
    required this.reportReason,
    required this.detailReason,
  });

  factory ArticleReportDetail.fromJson(Map<String, dynamic> json) {
    return ArticleReportDetail(
      reportId: json['reportId'] as int,
      reporterId: json['reporterId'] as int,
      reporterName: json['reporterName'] as String? ?? '알 수 없음',
      challengeName: json['challengeName'] as String?,
      articleId: json['articleId'] as int,
      // 내용이 null이거나 누락될 경우를 대비한 방어 코드 적용
      articleContent: json['articleContent'] as String? ?? '',
      imageUrl: json['imageUrl'] as String?,
      reportReason: json['reportReason'] as String? ?? 'SPAM',
      detailReason: json['detailReason'] as String?,
    );
  }
}

class CommentReportDetail {
  final int reportId;
  final int reporterId;
  final String reporterName;
  final int commentId;
  final String commentContent;
  final int articleId;
  final String? challengeName;
  final String reportReason;
  final String? detailReason;

  const CommentReportDetail({
    required this.reportId,
    required this.reporterId,
    required this.reporterName,
    required this.commentId,
    required this.commentContent,
    required this.articleId,
    required this.challengeName,
    required this.reportReason,
    required this.detailReason,
  });

  factory CommentReportDetail.fromJson(Map<String, dynamic> json) {
    return CommentReportDetail(
      reportId: json['reportId'] as int,
      reporterId: json['reporterId'] as int,
      reporterName: json['reporterName'] as String? ?? '알 수 없음',
      commentId: json['commentId'] as int,
      commentContent: json['commentContent'] as String? ?? '',
      articleId: json['articleId'] as int,
      challengeName: json['challengeName'] as String?,
      reportReason: json['reportReason'] as String? ?? 'SPAM',
      detailReason: json['detailReason'] as String?,
    );
  }
}
