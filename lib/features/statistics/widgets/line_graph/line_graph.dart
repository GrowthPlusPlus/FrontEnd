// 최초 작성자: 김채영
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../provider/line_graph_provider.dart';
import 'package:haenaem/core/theme/app_colors.dart';
import 'package:haenaem/core/theme/app_typography.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../statistics_card.dart';
import 'monthly_line_graph.dart';
import 'weekly_line_graph.dart';

// 나의 해냄 추이 위젯 틀
class LineGraph extends ConsumerWidget {
  final WeeklyGraphData monthlyData;
  final DailyGraphData weeklyData;

  const LineGraph({
    super.key,
    required this.monthlyData,
    required this.weeklyData,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appColors = Theme.of(context).extension<AppColorsExtension>()!;
    final isMonthly = ref.watch(graphTypeProvider);

    return StatisticsCard(
      title: "나의 해냄 추이",
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Column(
            children: [
              _buildToggleButtons(ref, isMonthly, appColors),
              const SizedBox(height: 20),
              _buildLegend(context, isMonthly, appColors),
              const SizedBox(height: 12),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: KeyedSubtree(
                  key: ValueKey<bool>(isMonthly),
                  child: isMonthly
                      ? MonthlyLineGraph(data: monthlyData)
                      : WeeklyLineGraph(data: weeklyData),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegend(
    BuildContext context,
    bool isMonthly,
    AppColorsExtension appColors,
  ) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      spacing: 8,
      children: [
        _buildLegendItem(
          appColors,
          iconPath: isDarkMode
              ? 'assets/images/icons/green_line_graph_icon_dark.svg'
              : 'assets/images/icons/green_line_graph_icon.svg',
          label: isMonthly ? '이번 달' : '이번 주',
        ),
        _buildLegendItem(
          appColors,
          iconPath: isDarkMode
              ? 'assets/images/icons/gray_line_graph_icon_dark.svg'
              : 'assets/images/icons/gray_line_graph_icon.svg',
          label: isMonthly ? '저번 달' : '저번 주',
        ),
      ],
    );
  }

  Widget _buildLegendItem(
    AppColorsExtension appColors, {
    required String iconPath,
    required String label,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      spacing: 4,
      children: [
        SvgPicture.asset(iconPath, width: 16, height: 16),
        Text(label, style: AppTypography.b2.copyWith(color: appColors.gray1)),
      ],
    );
  }

  Widget _buildToggleButtons(
    WidgetRef ref,
    bool isMonthly,
    AppColorsExtension appColors,
  ) {
    return Container(
      width: double.infinity,
      height: 35.99,
      decoration: ShapeDecoration(
        color: appColors.gray5,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
      ),
      child: Row(
        children: [
          _buildTab(
            appColors,
            ref: ref,
            label: '월간',
            isSelected: isMonthly,
            onTap: () => ref.read(graphTypeProvider.notifier).state = true,
          ),
          _buildTab(
            appColors,
            ref: ref,
            label: '주간',
            isSelected: !isMonthly,
            onTap: () => ref.read(graphTypeProvider.notifier).state = false,
          ),
        ],
      ),
    );
  }

  Widget _buildTab(
    AppColorsExtension appColors, {
    required WidgetRef ref,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Container(
          height: double.infinity,
          alignment: Alignment.center,
          decoration: ShapeDecoration(
            color: isSelected ? appColors.primaryAble : Colors.transparent,
            shape: const StadiumBorder(),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: AppTypography.b1.copyWith(
              color: isSelected
                  ? appColors.whiteToBlack
                  : appColors.blackToWhite,
            ),
          ),
        ),
      ),
    );
  }
}
