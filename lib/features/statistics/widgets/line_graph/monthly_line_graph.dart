// 최초 작성자: 김채영
import 'package:flutter/material.dart';
import 'package:haenaem/core/theme/app_colors.dart';
import 'package:haenaem/core/theme/app_typography.dart';

// 4주간 챌린지 성공 추이 모델
class WeeklyGraphData {
  final List<int> thisMonth; // 이번달 4주 데이터
  final List<int> lastMonth; // 지난달 4주 데이터

  const WeeklyGraphData({required this.thisMonth, required this.lastMonth});

  factory WeeklyGraphData.fromJson(Map<String, dynamic> json) {
    return WeeklyGraphData(
      thisMonth: List<int>.from(json['thisMonth'] ?? [0, 0, 0, 0]),
      lastMonth: List<int>.from(json['lastMonth'] ?? [0, 0, 0, 0]),
    );
  }
}

// 4주 라인 그래프 위젯
class MonthlyLineGraph extends StatelessWidget {
  final WeeklyGraphData data;

  const MonthlyLineGraph({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    // Y축 최댓값 계산 (10 단위로 올림)
    final allValues = [...data.thisMonth, ...data.lastMonth];
    final maxValue = allValues.isEmpty
        ? 30
        : ((allValues.reduce((a, b) => a > b ? a : b) / 10).ceil() * 10).clamp(
            10,
            999,
          );

    final yLabels = [maxValue, (maxValue * 2 ~/ 3), (maxValue * 1 ~/ 3), 0];

    const xLabels = ['전전전주', '전전주', '전주', '이번주'];

    return SizedBox(
      width: double.infinity,
      height: 164,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 그래프 영역
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
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
                            style: const TextStyle(
                              color: Color(0xFF444444),
                              fontSize: 12,
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ),

                // 그래프 본체
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: CustomPaint(
                      painter: _LineGraphPainter(
                        thisMonth: data.thisMonth,
                        lastMonth: data.lastMonth,
                        maxValue: maxValue.toDouble(),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // X축 레이블
          Padding(
            padding: const EdgeInsets.only(left: 24, bottom: 8),
            child: Row(
              children: xLabels
                  .map(
                    (label) => Expanded(
                      child: Text(
                        label,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Color(0xFF444444),
                          fontSize: 12,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _LineGraphPainter extends CustomPainter {
  final List<int> thisMonth;
  final List<int> lastMonth;
  final double maxValue;

  const _LineGraphPainter({
    required this.thisMonth,
    required this.lastMonth,
    required this.maxValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    _drawGrid(canvas, size);
    if (lastMonth.length >= 4)
      _drawLine(canvas, size, lastMonth, const Color(0xFFD9D9D9));
    if (thisMonth.length >= 4)
      _drawLine(canvas, size, thisMonth, AppColors.primaryAble);
    if (lastMonth.length >= 4)
      _drawDots(canvas, size, lastMonth, const Color(0xFFD9D9D9));
    if (thisMonth.length >= 4)
      _drawDots(canvas, size, thisMonth, AppColors.primaryAble);
  }

  // 격자선 그리기
  void _drawGrid(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFD9D9D9)
      ..strokeWidth = 1;

    // 가로 격자선 4개
    for (int i = 0; i < 4; i++) {
      final y = size.height * i / 3;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }

    // 세로 격자선 5개
    for (int i = 0; i < 5; i++) {
      final x = size.width * i / 4;
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
  }

  // 라인 그리기
  void _drawLine(Canvas canvas, Size size, List<int> values, Color color) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final path = Path();
    for (int i = 0; i < 4; i++) {
      final x = size.width * i / 3;
      final y = size.height - (values[i] / maxValue) * size.height;
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    canvas.drawPath(path, paint);
  }

  // 데이터 포인트 점 그리기
  void _drawDots(Canvas canvas, Size size, List<int> values, Color color) {
    final outerPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    final borderPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    for (int i = 0; i < 4; i++) {
      final x = size.width * i / 3;
      final y = size.height - (values[i] / maxValue) * size.height;
      canvas.drawCircle(Offset(x, y), 4, outerPaint);
      canvas.drawCircle(Offset(x, y), 4, borderPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _LineGraphPainter oldDelegate) =>
      oldDelegate.thisMonth != thisMonth ||
      oldDelegate.lastMonth != lastMonth ||
      oldDelegate.maxValue != maxValue;
}
