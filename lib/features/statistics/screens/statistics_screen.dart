// 최초 작성자: 김채영
import 'package:flutter/material.dart';
import 'package:haenaem/core/theme/app_colors.dart';
import 'package:haenaem/core/theme/app_typography.dart';
import '../widgets/haenaem_grass.dart';
import '../widgets/pie_graph.dart';
import '../widgets/line_graph/line_graph.dart';

class StatisticsScreen extends StatelessWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // 임시 데이터 (나중에 API 응답값으로 대체)
    final List<int> mockActivity = List.generate(365, (index) => (index % 5));

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
            // 잔디 위젯 배치
            HaenaemGrass(
              successDays: 00,
              currentStreak: 00,
              activity: mockActivity,
            ),

            const SizedBox(height: 20),
            const PieGraph(
              totalCount: 48,
              tagCounts: [
                TagCount(tag: '자격증', count: 24, color: Color(0xFF8979FF)),
                TagCount(tag: '다이어트', count: 15, color: Color(0xFFFF928A)),
                TagCount(tag: '독서', count: 8, color: Color(0xff3cc3df)),
                TagCount(tag: 'tag', count: 00, color: AppColors.gray4),
                TagCount(tag: 'tag', count: 00, color: Color(0xFFFFD166)),
                TagCount(tag: 'tag', count: 00, color: AppColors.primaryAble),
              ],
            ),
            const SizedBox(height: 20),
            const LineGraph(),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
