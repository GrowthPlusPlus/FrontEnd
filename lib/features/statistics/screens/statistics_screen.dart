// 최초 작성자: 김채영
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:haenaem/core/theme/app_colors.dart';
import 'package:haenaem/core/theme/app_typography.dart';
import '../data/activity_repository.dart';
import '../data/distribution_repository.dart';
import '../data/monthly_weekly_repository.dart';
import '../widgets/haenaem_grass.dart';
import '../widgets/pie_graph.dart';
import '../widgets/line_graph/line_graph.dart';

// 통계화면 프레임 (안에다 위젯을 넣는 구조)
class StatisticsScreen extends ConsumerWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activityAsync = ref.watch(activityRepositoryProvider);
    final distributionAsync = ref.watch(distributionRepositoryProvider);
    final monthlyWeeklyAsync = ref.watch(monthlyWeeklyRepositoryProvider);

    return Scaffold(
      backgroundColor: AppColors.gray5,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text(
          '통계',
          style: AppTypography.h3.copyWith(color: AppColors.black),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 10),
            // 해냄 잔디
            activityAsync.when(
              loading: () => const SizedBox(
                height: 200,
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (e, _) => SizedBox(
                height: 200,
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '데이터를 불러오지 못했어요',
                        style: AppTypography.b2.copyWith(
                          color: AppColors.gray4,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextButton(
                        onPressed: () => ref
                            .read(activityRepositoryProvider.notifier)
                            .refresh(),
                        child: const Text('다시 시도'),
                      ),
                    ],
                  ),
                ),
              ),
              data: (data) => HaenaemGrass(
                successDays: data.successDays,
                currentStreak: data.currentStreak,
                activity: data.activity,
              ),
            ),
            const SizedBox(height: 20),
            // 나의 해냄 분포
            distributionAsync.when(
              loading: () => const SizedBox(
                height: 200,
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (e, _) => SizedBox(
                height: 200,
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '데이터를 불러오지 못했어요',
                        style: AppTypography.b2.copyWith(
                          color: AppColors.gray4,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextButton(
                        onPressed: () => ref
                            .read(distributionRepositoryProvider.notifier)
                            .refresh(),
                        child: const Text('다시 시도'),
                      ),
                    ],
                  ),
                ),
              ),
              data: (data) => PieGraph(
                top3: data.top3,
                rest: data.rest,
                restCount: data.restCount,
                totalCount: data.totalCount,
              ),
            ),
            const SizedBox(height: 20),
            // 나의 해냄 추이
            monthlyWeeklyAsync.when(
              loading: () => const SizedBox(
                height: 200,
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (e, _) => SizedBox(
                height: 200,
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '데이터를 불러오지 못했어요',
                        style: AppTypography.b2.copyWith(
                          color: AppColors.gray4,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextButton(
                        onPressed: () => ref
                            .read(monthlyWeeklyRepositoryProvider.notifier)
                            .refresh(),
                        child: const Text('다시 시도'),
                      ),
                    ],
                  ),
                ),
              ),
              data: (data) =>
                  LineGraph(monthlyData: data.monthly, weeklyData: data.weekly),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
