// 최초 작성자: 김채영
import 'package:flutter/material.dart';
import 'package:haenaem/core/theme/app_colors.dart';
import 'line_chart_grid.dart';

// ───────────────────────────────────────────────
// 데이터 모델
// ───────────────────────────────────────────────

/// 주간 그래프 데이터 모델
/// - [thisWeek] : 이번 주 요일별 데이터 (월~일, 7개)
/// - [lastWeek] : 저번 주 요일별 데이터 (월~일, 7개)
class DailyGraphData {
  final List<int> thisWeek;
  final List<int> lastWeek;

  const DailyGraphData({required this.thisWeek, required this.lastWeek});

  factory DailyGraphData.fromJson(Map<String, dynamic> json) {
    return DailyGraphData(
      thisWeek: List<int>.from(json['thisWeek'] ?? List.filled(7, 0)),
      lastWeek: List<int>.from(json['lastWeek'] ?? List.filled(7, 0)),
    );
  }
}

// ───────────────────────────────────────────────
// 주간 꺾은선 그래프 위젯
// ───────────────────────────────────────────────

/// 이번 주 vs 저번 주 요일별 인증 추이를 꺾은선 그래프로 표시
class WeeklyLineGraph extends StatelessWidget {
  final DailyGraphData data;

  const WeeklyLineGraph({super.key, required this.data});

  static const _xLabels = ['월', '화', '수', '목', '금', '토', '일'];

  @override
  Widget build(BuildContext context) {
    final allValues = [...data.thisWeek, ...data.lastWeek];
    final rawMax = allValues.isEmpty
        ? 5
        : allValues.reduce((a, b) => a > b ? a : b);
    // 주간은 하루 최대 인증 수가 소수이므로 1 단위로 올림
    final yMax = ((rawMax / 5).ceil() * 5).clamp(5, 999).toDouble();

    return LineChartGrid(
      columnCount: 7,
      rowCount: 5,
      xLabels: _xLabels,
      yMax: yMax,
      thisData: data.thisWeek,
      lastData: data.lastWeek,
      labelColor: AppColors.gray1,
    );
  }
}
