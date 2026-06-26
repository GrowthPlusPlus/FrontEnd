import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:haenaem/core/theme/app_colors.dart';
import 'package:haenaem/core/theme/app_typography.dart';
import '../models/report.dart'; // 💡 모델 파일이 위치한 실제 경로로 수정하세요.

// 최초 작성자: 강선욱
// 신고 게시글 / 댓글 리스트 타일

class ReportCard extends StatelessWidget {
  /// ReportedArticleSummary 또는 ReportedCommentSummary 인스턴스를 받습니다.
  final dynamic report;
  final VoidCallback onTap;

  const ReportCard({super.key, required this.report, required this.onTap})
    : assert(
        report is ReportedArticleSummary || report is ReportedCommentSummary,
        'report 매개변수는 ReportedArticleSummary 또는 ReportedCommentSummary 타입이어야 합니다.',
      );

  @override
  Widget build(BuildContext context) {
    // 1. 런타임 타입 체크를 통해 데이터 및 레이블 분기 처리
    final bool isArticle = report is ReportedArticleSummary;

    final int id = isArticle
        ? (report as ReportedArticleSummary).articleId
        : (report as ReportedCommentSummary).commentId;

    final String? challengeName = isArticle
        ? (report as ReportedArticleSummary).challengeName
        : (report as ReportedCommentSummary).challengeName;

    final int totalCount = isArticle
        ? (report as ReportedArticleSummary).totalCount
        : (report as ReportedCommentSummary).totalCount;

    final String idLabel = isArticle ? '게시글 ID' : '댓글 ID';
    final String fallbackTitle = '이름 없음(삭제된 챌린지)';

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      padding: const EdgeInsets.fromLTRB(16, 14, 0, 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(20), // 은은하고 깔끔한 그림자
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // 챌린지 이름 제목
                  Text(
                    challengeName ?? fallbackTitle,
                    style: AppTypography.b1.copyWith(color: AppColors.black),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 10),

                  // 메타 데이터 영역 (ID 정보 + 신고 카운트 뱃지)
                  Row(
                    children: [
                      Text(
                        '$idLabel: $id',
                        style: AppTypography.b2.copyWith(
                          color: AppColors.black,
                        ),
                      ),
                      const SizedBox(width: 12),
                      _buildReportTag(totalCount),
                    ],
                  ),
                ],
              ),
            ),

            // 우측 화살표 아이콘 버튼
            IconButton(
              onPressed: onTap,
              icon: SvgPicture.asset(
                'assets/images/icons/thick_right_arrow_icon.svg',
                colorFilter: const ColorFilter.mode(
                  AppColors.gray2,
                  BlendMode.srcIn,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 내부 커스텀 신고 뱃지 태그
  Widget _buildReportTag(int count) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      child: Text(
        '신고 $count건',
        style: AppTypography.b2.copyWith(color: AppColors.notification),
      ),
    );
  }
}
