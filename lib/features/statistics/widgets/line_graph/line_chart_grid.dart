// 최초 작성자: 김채영
import 'package:flutter/material.dart';
import 'package:haenaem/core/theme/app_colors.dart';
import 'package:haenaem/core/theme/app_typography.dart';

// ───────────────────────────────────────────────
// 공통 라인 차트 위젯
// ───────────────────────────────────────────────

/// 월간/주간 공통 꺾은선 그래프 위젯
///
/// - [columnCount] : 데이터 포인트 수 (월간: 4, 주간: 7)
/// - [rowCount]    : 가로 구간 수 (월간: 3, 주간: 5) → 가로선은 rowCount+1개
/// - [xLabels]     : X축 레이블 목록 (columnCount와 길이 일치)
/// - [yMax]        : Y축 최댓값 (데이터 기반으로 계산된 값)
/// - [thisData]    : 이번 달/주 데이터
/// - [lastData]    : 저번 달/주 데이터
/// - [labelColor]  : 축 레이블 색상 (기본: AppColors.gray1)
class LineChartGrid extends StatelessWidget {
  final int columnCount;
  final int rowCount;
  final List<String> xLabels;
  final double yMax;
  final List<int> thisData;
  final List<int> lastData;
  final Color? labelColor;

  const LineChartGrid({
    super.key,
    required this.columnCount,
    this.rowCount = 3,
    required this.xLabels,
    required this.yMax,
    required this.thisData,
    required this.lastData,
    this.labelColor,
  }) : assert(
         xLabels.length == columnCount,
         'xLabels 길이는 columnCount와 같아야 합니다.',
       );

  @override
  Widget build(BuildContext context) {
    final appColors = Theme.of(context).extension<AppColorsExtension>()!;
    final axisColor = labelColor ?? appColors.gray1;

    // Y축 레이블: yMax에서 0까지 rowCount+1개 균등 분할
    final yLabels = List.generate(
      rowCount + 1,
      (i) => (yMax * (rowCount - i) / rowCount).round(),
    );

    return SizedBox(
      width: double.infinity,
      height: 164,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── 그래프 본체 (Y축 레이블 + 캔버스) ──
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Y축 레이블
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: yLabels
                        .map(
                          (label) => Text(
                            '$label',
                            style: AppTypography.c1.copyWith(color: axisColor),
                          ),
                        )
                        .toList(),
                  ),
                ),

                // 그래프 캔버스
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: CustomPaint(
                      painter: _LineChartPainter(
                        columnCount: columnCount,
                        rowCount: rowCount,
                        yMax: yMax,
                        thisData: thisData,
                        lastData: lastData,
                        appColors: appColors,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── X축 레이블 ──
          // 그래프 본체와 동일한 Row 구조 사용:
          //   [Y축 더미 공간] + [캔버스 영역을 columnCount로 균등 분할]
          // → Y축 너비를 하드코딩 없이 정확히 맞춤
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Y축 레이블과 동일한 패딩/텍스트 스타일로 더미 공간 확보
                IntrinsicWidth(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Text(
                      '${yMax.toInt()}',
                      style: AppTypography.c1.copyWith(
                        color: Colors.transparent,
                      ),
                    ),
                  ),
                ),

                // 캔버스 영역: columnCount 구간으로 균등 분할
                // 각 Expanded가 세로 점선 사이 한 구간에 대응
                Expanded(
                  child: Row(
                    children: List.generate(
                      columnCount,
                      (i) => Expanded(
                        child: Text(
                          xLabels[i],
                          textAlign: TextAlign.center,
                          style: AppTypography.c1.copyWith(color: axisColor),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ───────────────────────────────────────────────
// CustomPainter
// ───────────────────────────────────────────────

class _LineChartPainter extends CustomPainter {
  final int columnCount;
  final int rowCount;
  final double yMax;
  final List<int> thisData;
  final List<int> lastData;
  final AppColorsExtension appColors;

  const _LineChartPainter({
    required this.columnCount,
    required this.rowCount,
    required this.yMax,
    required this.thisData,
    required this.lastData,
    required this.appColors,
  });

  @override
  void paint(Canvas canvas, Size size) {
    _drawGrid(canvas, size, appColors);
    if (lastData.length >= columnCount) {
      _drawLine(canvas, size, lastData, appColors.gray3);
      _drawDots(canvas, size, lastData, appColors.gray3, appColors);
    }
    if (thisData.length >= columnCount) {
      _drawLine(canvas, size, thisData, appColors.primaryAble);
      _drawDots(canvas, size, thisData, appColors.primaryAble, appColors);
    }
  }

  /// 격자선
  /// - 가로: rowCount+1개, 맨 아래만 실선 나머지는 점선
  /// - 세로: columnCount+1개 점선 (양끝 포함)
  void _drawGrid(Canvas canvas, Size size, AppColorsExtension appColors) {
    final solidPaint = Paint()
      ..color = appColors.gray4
      ..strokeWidth = 1;

    final dashedPaint = Paint()
      ..color = appColors.gray4
      ..strokeWidth = 1;

    // 가로선: rowCount+1개 (i=0: top, i=rowCount: bottom)
    for (int i = 0; i <= rowCount; i++) {
      final y = size.height * i / rowCount;
      if (i == rowCount) {
        // 맨 아래만 실선
        canvas.drawLine(Offset(0, y), Offset(size.width, y), solidPaint);
      } else {
        // 나머지 점선
        _drawDashedHorizontalLine(canvas, y, 0, size.width, dashedPaint);
      }
    }

    // 세로 점선: columnCount+1개 (양끝 포함)
    for (int i = 0; i <= columnCount; i++) {
      final x = size.width * i / columnCount;
      _drawDashedVerticalLine(canvas, x, 0, size.height, dashedPaint);
    }
  }

  // 점선 가로선 헬퍼
  void _drawDashedHorizontalLine(
    Canvas canvas,
    double y,
    double startX,
    double endX,
    Paint paint,
  ) {
    const dashWidth = 4.0;
    const dashGap = 3.0;
    double currentX = startX;
    while (currentX < endX) {
      final nextX = (currentX + dashWidth).clamp(0.0, endX);
      canvas.drawLine(Offset(currentX, y), Offset(nextX, y), paint);
      currentX += dashWidth + dashGap;
    }
  }

  // 점선 세로선 헬퍼
  void _drawDashedVerticalLine(
    Canvas canvas,
    double x,
    double startY,
    double endY,
    Paint paint,
  ) {
    const dashHeight = 4.0;
    const dashGap = 3.0;
    double currentY = startY;
    while (currentY < endY) {
      final nextY = (currentY + dashHeight).clamp(0.0, endY);
      canvas.drawLine(Offset(x, currentY), Offset(x, nextY), paint);
      currentY += dashHeight + dashGap;
    }
  }

  /// 꺾은선 그리기
  /// x 위치: 각 구간 중앙 → (2i + 1) / (2 * columnCount)
  void _drawLine(Canvas canvas, Size size, List<int> values, Color color) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final path = Path();
    for (int i = 0; i < columnCount; i++) {
      final x = size.width * (2 * i + 1) / (2 * columnCount);
      final y = size.height - (values[i] / yMax) * size.height;
      i == 0 ? path.moveTo(x, y) : path.lineTo(x, y);
    }
    canvas.drawPath(path, paint);
  }

  /// 데이터 포인트 점 그리기 (흰색 채우기 + 컬러 테두리)
  void _drawDots(
    Canvas canvas,
    Size size,
    List<int> values,
    Color color,
    AppColorsExtension appColors,
  ) {
    final fillPaint = Paint()
      ..color = appColors.whiteToBlack
      ..style = PaintingStyle.fill;
    final borderPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    for (int i = 0; i < columnCount; i++) {
      final x = size.width * (2 * i + 1) / (2 * columnCount);
      final y = size.height - (values[i] / yMax) * size.height;
      canvas.drawCircle(Offset(x, y), 4, fillPaint);
      canvas.drawCircle(Offset(x, y), 4, borderPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _LineChartPainter old) =>
      old.columnCount != columnCount ||
      old.rowCount != rowCount ||
      old.yMax != yMax ||
      old.thisData != thisData ||
      old.lastData != lastData;
}
