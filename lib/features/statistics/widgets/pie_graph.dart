// 최초 작성자: 김채영
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:haenaem/core/theme/app_colors.dart';
import 'package:haenaem/core/theme/app_typography.dart';
import 'statistics_card.dart';

// 태그별 해냄 횟수 데이터 모델
class TagCount {
  final String tag;
  final int count;
  final Color color;

  const TagCount({required this.tag, required this.count, required this.color});
}

// 나의 해냄 분포 원형 그래프
class PieGraph extends StatelessWidget {
  final List<TagCount> top3; // 1~3위: 각각 색상으로 표시
  final List<TagCount> rest; // 4위~: 이름/횟수 각각 표시 (gray4 텍스트)
  final int restCount; // 4위~ 합산 횟수 (파이 차트 gray4 조각용)
  final int totalCount; // 총 해냄 횟수

  const PieGraph({
    super.key,
    required this.top3,
    required this.rest,
    required this.restCount,
    required this.totalCount,
  });

  @override
  Widget build(BuildContext context) {
    final appColors = Theme.of(context).extension<AppColorsExtension>()!;
    // ✅ 데이터 없을 때 빈 상태 UI
    if (top3.isEmpty) {
      return StatisticsCard(
        title: '나의 해냄 분포',
        child: SizedBox(
          height: 120,
          child: Center(
            child: Text(
              '아직 완료한 챌린지가 없어요',
              style: AppTypography.b2.copyWith(color: appColors.gray3),
            ),
          ),
        ),
      );
    }

    // 파이 차트용: top3 각각 + 나머지 합산 gray4 하나
    final pieData = [
      ...top3,
      if (restCount > 0)
        TagCount(tag: '기타', count: restCount, color: appColors.gray4),
    ];

    return StatisticsCard(
      title: '나의 해냄 분포',
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 10,
        children: [
          // 원형 파이 차트
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 60),
            child: AspectRatio(
              aspectRatio: 1,
              child: CustomPaint(
                // ✅ 파이 차트는 pieData (top3 + 기타 합산) 사용
                painter: _PieChartPainter(
                  tagCounts: pieData,
                  appColors: appColors,
                ),
              ),
            ),
          ),

          // 총 N번 해냄!
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            spacing: 2,
            children: [
              Text(
                '총',
                style: AppTypography.b3.copyWith(color: appColors.blackToWhite),
              ),
              Text(
                '$totalCount번',
                style: AppTypography.h2.copyWith(color: appColors.primaryAble),
              ),
              Text(
                '해냄!',
                style: AppTypography.b3.copyWith(color: appColors.blackToWhite),
              ),
            ],
          ),

          // 1~3위: 큰 폰트 + 각각의 색상
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 60),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              // ✅ 텍스트는 top3 그대로 사용
              children: top3
                  .map((tag) => _buildTopTagItem(tag, appColors))
                  .toList(),
            ),
          ),

          // 4위~: 작은 회색 폰트 + 이름/횟수 각각 표시
          if (rest.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 50),
              child: Column(
                spacing: 1,
                // ✅ rest는 각각 따로 표시
                children: rest
                    .map((tag) => _buildRestTagRow(tag, appColors))
                    .toList(),
              ),
            ),
        ],
      ),
    );
  }

  // 1~3위 태그 아이템
  Widget _buildTopTagItem(TagCount tag, AppColorsExtension appColors) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center, // ✅ start → center
      spacing: 2,
      children: [
        Text(
          tag.tag,
          style: AppTypography.b1.copyWith(color: appColors.gray2),
          textAlign: TextAlign.center, // ✅ 추가
        ),
        Text(
          '${tag.count}번',
          style: AppTypography.h3.copyWith(color: tag.color),
          textAlign: TextAlign.center, // ✅ 추가
        ),
      ],
    );
  }

  // 4위~ 태그 행
  Widget _buildRestTagRow(TagCount tag, AppColorsExtension appColors) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(tag.tag, style: AppTypography.b2.copyWith(color: appColors.gray2)),
        Text(
          '${tag.count}번',
          style: AppTypography.b2.copyWith(color: appColors.gray2),
        ),
      ],
    );
  }
}

// 파이 차트 CustomPainter
class _PieChartPainter extends CustomPainter {
  final List<TagCount> tagCounts;

  final AppColorsExtension appColors;

  const _PieChartPainter({required this.tagCounts, required this.appColors});

  @override
  void paint(Canvas canvas, Size size) {
    if (tagCounts.isEmpty) return;

    final total = tagCounts.fold<int>(0, (sum, t) => sum + t.count);
    if (total == 0) return;

    final center = Offset(size.width / 2, size.height / 2);
    const radius = 85.33;
    final rect = Rect.fromCircle(center: center, radius: radius);

    double startAngle = -pi / 2;
    final paint = Paint()..style = PaintingStyle.fill;

    for (final tag in tagCounts) {
      final sweepAngle = (tag.count / total) * (2 * pi);
      paint.color = tag.color;
      canvas.drawArc(rect, startAngle, sweepAngle, true, paint);
      startAngle += sweepAngle;
    }

    // 중앙 흰색 원 (도넛 효과)
    final innerPaint = Paint()
      ..color = appColors.whiteToBlack
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius * 0.50, innerPaint);
  }

  @override
  bool shouldRepaint(covariant _PieChartPainter oldDelegate) =>
      oldDelegate.tagCounts != tagCounts;
}
