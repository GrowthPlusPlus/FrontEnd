// 최초 작성자: 김채영
import 'package:flutter/material.dart';
import 'line_chart_grid.dart';

// ───────────────────────────────────────────────
// 데이터 모델
// ───────────────────────────────────────────────

/// 월간 그래프 데이터 모델
/// - [thisMonth] : 이번 달 4주 데이터 (전전전주 → 이번주)
/// - [lastMonth] : 저번 달 4주 데이터 (전전전주 → 이번주)
class WeeklyGraphData {
  final List<int> thisMonth;
  final List<int> lastMonth;

  const WeeklyGraphData({required this.thisMonth, required this.lastMonth});

  factory WeeklyGraphData.fromJson(Map<String, dynamic> json) {
    return WeeklyGraphData(
      thisMonth: List<int>.from(json['thisMonth'] ?? [0, 0, 0, 0]),
      lastMonth: List<int>.from(json['lastMonth'] ?? [0, 0, 0, 0]),
    );
  }
}

// ───────────────────────────────────────────────
// 월간 꺾은선 그래프 위젯
// ───────────────────────────────────────────────

/// 이번 달 vs 저번 달 4주 인증 추이를 꺾은선 그래프로 표시
class MonthlyLineGraph extends StatelessWidget {
  final WeeklyGraphData data;

  const MonthlyLineGraph({super.key, required this.data});

  static const _xLabels = ['첫째 주', '둘째 주', '셋째 주', '넷째 주'];

  @override
  Widget build(BuildContext context) {
    final allValues = [...data.thisMonth, ...data.lastMonth];
    final rawMax = allValues.isEmpty
        ? 30
        : allValues.reduce((a, b) => a > b ? a : b);
    final yMax = ((rawMax / 10).ceil() * 10).clamp(10, 999).toDouble();

    return LineChartGrid(
      columnCount: 4,
      xLabels: _xLabels,
      yMax: yMax,
      thisData: data.thisMonth,
      lastData: data.lastMonth,
    );
  }
}
