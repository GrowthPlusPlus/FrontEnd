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
  final List<TagCount> tagCounts; // 태그별 데이터
  final int totalCount; // 총 해냄 횟수

  // 그래프 색상 팔레트
  static const List<Color> defaultColors = [
    Color(0xFF8979FF),
    Color(0xFFFF928A),
    Color(0xFF3BC3DE),
    Color(0xFFFFD166),
    Color(0xFF06D6A0),
    Color(0xFFEF476F),
  ];

  const PieGraph({
    super.key,
    required this.tagCounts,
    required this.totalCount,
  });
  @override
  Widget build(BuildContext context) {
    if (tagCounts.isEmpty) return const SizedBox.shrink();

    // 상위 3개 + 나머지
    final top3 = tagCounts.take(3).toList();
    final rest = tagCounts.skip(3).toList();

    return StatisticsCard(
      title: '나의 해냄 분포',
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 12,
        children: [
          // 2. 차트 + 태그 영역
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 10,
            children: [
              // 파이 차트 + 총 해냄 텍스트
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 10,
                children: [
                  // 원형 파이 차트 영역
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 60),
                    child: AspectRatio(
                      aspectRatio: 1, // 정사각형 유지 (원형 그래프용)
                      child: CustomPaint(
                        painter: _PieChartPainter(tagCounts: tagCounts),
                      ),
                    ),
                  ),

                  // 총 N번 해냄!
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    spacing: 2,
                    children: [
                      Text(
                        '총',
                        style: AppTypography.b3.copyWith(
                          color: AppColors.black,
                        ),
                      ),
                      Text(
                        '$totalCount번',
                        style: AppTypography.h3.copyWith(
                          color: AppColors.primaryAble,
                        ),
                      ),
                      Text(
                        '해냄!',
                        style: AppTypography.b3.copyWith(
                          color: AppColors.black,
                        ),
                      ),
                    ],
                  ),

                  // 상위 3개 태그 (큰 폰트)
                  if (top3.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 60),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: top3
                            .map((tag) => _buildTopTagItem(tag))
                            .toList(),
                      ),
                    ),

                  // 나머지 태그 (작은 폰트)
                  if (rest.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 50),
                      child: Column(
                        spacing: 1,
                        children: rest
                            .map((tag) => _buildRestTagRow(tag))
                            .toList(),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 상위 3개 태그 아이템
  Widget _buildTopTagItem(TagCount tag) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 2,
      children: [
        Text(tag.tag, style: AppTypography.b1.copyWith(color: AppColors.gray2)),
        Text(
          '${tag.count}번',
          style: AppTypography.h3.copyWith(color: tag.color),
        ),
      ],
    );
  }

  // 나머지 태그 행
  Widget _buildRestTagRow(TagCount tag) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(tag.tag, style: AppTypography.b2.copyWith(color: AppColors.gray2)),
        Text(
          '${tag.count}번',
          style: AppTypography.b2.copyWith(color: AppColors.gray2),
        ),
      ],
    );
  }
}

// 파이 차트 CustomPainter
class _PieChartPainter extends CustomPainter {
  final List<TagCount> tagCounts;

  const _PieChartPainter({required this.tagCounts});

  @override
  void paint(Canvas canvas, Size size) {
    if (tagCounts.isEmpty) return;

    final total = tagCounts.fold<int>(0, (sum, t) => sum + t.count);
    if (total == 0) return;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = 85.33;
    final rect = Rect.fromCircle(center: center, radius: radius);

    double startAngle = -pi / 2;
    final paint = Paint()..style = PaintingStyle.fill;

    for (final tag in tagCounts) {
      final sweepAngle = (tag.count / total) * (2 * pi); // 원
      paint.color = tag.color;
      canvas.drawArc(rect, startAngle, sweepAngle, true, paint);
      startAngle += sweepAngle;
    }

    // 중앙 흰색 원 (도넛 효과)
    final innerPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius * 0.50, innerPaint);
  }

  @override
  bool shouldRepaint(covariant _PieChartPainter oldDelegate) =>
      oldDelegate.tagCounts != tagCounts;
}
