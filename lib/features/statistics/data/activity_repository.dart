// 최초 작성자: 김채영
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:haenaem/core/network/dio_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'activity_repository.g.dart';

// 해냄 잔디 레포지토리
class ActivityData {
  final int successDays;
  final int currentStreak;
  final List<int> activity;

  ActivityData({
    required this.successDays,
    required this.currentStreak,
    required this.activity,
  });

  factory ActivityData.fromJson(Map<String, dynamic> json) {
    return ActivityData(
      successDays: json['successDays'],
      currentStreak: json['currentStreak'],
      activity: List<int>.from(json['activity']),
    );
  }
}

@riverpod
class ActivityRepository extends _$ActivityRepository {
  @override
  Future<ActivityData> build() async {
    final dio = ref.watch(dioProvider);
    return _fetchActivity(dio);
  }

  Future<ActivityData> _fetchActivity(Dio dio) async {
    final year = DateTime.now().year;
    final response = await dio.get(
      '/api/users/activity',
      queryParameters: {'year': year},
    );
    // ✅ API 응답 원본 확인
    debugPrint('🌐 [ActivityRepository] status: ${response.statusCode}');
    debugPrint('🌐 [ActivityRepository] raw data: ${response.data}');

    return ActivityData.fromJson(response.data);
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final dio = ref.read(dioProvider);
      return _fetchActivity(dio);
    });
  }
}
