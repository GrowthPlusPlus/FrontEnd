// 최초 작성자: 김채영
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:haenaem/core/network/dio_provider.dart';
import 'package:haenaem/core/theme/app_colors.dart';
import 'package:haenaem/features/statistics/widgets/pie_graph.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'distribution_repository.g.dart';

// 나의 해냄 분포 데이터 매핑
class DistributionData {
  final int totalCount;
  final List<TagCount> top3; // 1~3위: 각각 색상
  final List<TagCount> rest; // 4위~: 각각 따로 (이름, 횟수 표시용)
  final int restCount; // 4위~ 합산 (파이 차트용)

  DistributionData({
    required this.totalCount,
    required this.top3,
    required this.rest,
    required this.restCount,
  });
}

@riverpod
class DistributionRepository extends _$DistributionRepository {
  @override
  Future<DistributionData> build() async {
    final dio = ref.watch(dioProvider);
    return _fetchDistribution(dio);
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final dio = ref.read(dioProvider);
      return _fetchDistribution(dio);
    });
  }

  Future<DistributionData> _fetchDistribution(Dio dio) async {
    final response = await dio.get('/api/users/graph/tag');

    final List<dynamic> raw = response.data;

    raw.sort((a, b) => (b['count'] as int).compareTo(a['count'] as int));

    const top3Colors = [
      Color(0xFF8979FF), // 1위 보라
      Color(0xFFFF928A), // 2위 핑크
      Color(0xFF3CC3DF), // 3위 파랑
    ];

    // 1~3위: 각각 색상 유지
    final top3 = raw.take(3).toList().asMap().entries.map((entry) {
      return TagCount(
        tag: entry.value['tagName'],
        count: entry.value['count'],
        color: top3Colors[entry.key],
      );
    }).toList();

    // 4위~: 이름/횟수 각각 유지 (UI 표시용), 색상은 gray4
    final restList = raw.skip(3).toList();
    final rest = restList
        .take(3)
        .map(
          (item) => TagCount(
            tag: item['tagName'],
            count: item['count'],
            color: AppColors.gray4,
          ),
        )
        .toList();

    // 4위~ 합산 (파이 차트에서 gray4 하나로 표시용)
    final restCount = restList.fold<int>(
      0,
      (sum, item) => sum + (item['count'] as int),
    );

    final totalCount = raw.fold<int>(
      0,
      (sum, item) => sum + (item['count'] as int),
    );

    return DistributionData(
      totalCount: totalCount,
      top3: top3,
      rest: rest,
      restCount: restCount,
    );
  }
}
