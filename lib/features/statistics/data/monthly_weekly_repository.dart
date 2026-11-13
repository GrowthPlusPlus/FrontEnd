// 최초 작성자: 김채영
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:haenaem/core/network/dio_provider.dart';
import 'package:haenaem/features/statistics/widgets/line_graph/monthly_line_graph.dart';
import 'package:haenaem/features/statistics/widgets/line_graph/weekly_line_graph.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'monthly_weekly_repository.g.dart';

// 나의 해냄 추이 레포지토리
class MonthlyWeeklyData {
  final WeeklyGraphData monthly;
  final DailyGraphData weekly;

  MonthlyWeeklyData({required this.monthly, required this.weekly});
}

@riverpod
class MonthlyWeeklyRepository extends _$MonthlyWeeklyRepository {
  // ✅ _$TrendRepository → _$MonthlyWeeklyRepository
  @override
  Future<MonthlyWeeklyData> build() async {
    final dio = ref.watch(dioProvider);
    return _fetch(dio);
  }

  Future<MonthlyWeeklyData> _fetch(Dio dio) async {
    final responses = await Future.wait([
      dio.get('/api/users/graph/4weeks'),
      dio.get('/api/users/graph/weekly'), // ✅ daily → weekly
    ]);

    final monthly = WeeklyGraphData.fromJson(responses[0].data);
    final weekly = DailyGraphData.fromJson(responses[1].data);

    return MonthlyWeeklyData(monthly: monthly, weekly: weekly);
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final dio = ref.read(dioProvider);
      return _fetch(dio);
    });
  }
}
