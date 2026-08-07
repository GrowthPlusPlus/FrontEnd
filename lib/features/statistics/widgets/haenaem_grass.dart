// 최초 작성자: 김채영
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:haenaem/core/theme/app_colors.dart';
import 'package:haenaem/core/theme/app_typography.dart';
import 'statistics_card.dart';

// 해냄 잔디 위젯
class HaenaemGrass extends StatelessWidget {
  final int successDays;
  final int currentStreak;
  final List<int> activity;

  const HaenaemGrass({
    super.key,
    required this.successDays,
    required this.currentStreak,
    required this.activity,
  });

  int _getLevel(int count) {
    if (count <= 0) return 0;
    if (count == 1) return 1;
    if (count == 2) return 2;
    if (count == 3) return 3;
    return 4;
  }

  @override
  Widget build(BuildContext context) {
    final appColors = Theme.of(context).extension<AppColorsExtension>()!;

    debugPrint('🌿 [HaenaemGrass] successDays: $successDays');
    debugPrint('🔥 [HaenaemGrass] currentStreak: $currentStreak');
    debugPrint('📊 [HaenaemGrass] activity length: ${activity.length}');
    debugPrint(
      '📊 [HaenaemGrass] activity (first 10): ${activity.take(10).toList()}',
    );

    final int year = DateTime.now().year;
    final List<int> daysInMonths = List.generate(12, (monthIndex) {
      // 다음 달 1일에서 하루를 빼면 이번 달 마지막 날 = 해당 월의 일수
      return DateTime(year, monthIndex + 2, 0).day;
    });
    debugPrint('📅 [HaenaemGrass] year: $year, daysInMonths: $daysInMonths');

    return StatisticsCard(
      title: "해냄 잔디",
      headerAction: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildSummaryItem(
            'assets/images/icons/mini_success_icon.svg',
            '$successDays일',
            appColors.primaryAble,
          ),
          const SizedBox(width: 10),
          _buildSummaryItem(
            'assets/images/icons/small_fire_icon.svg',
            '$currentStreak일',
            AppColors.fire,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.5),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          spacing: 6,
          // ✅ 월 루프 (12개)
          children: List.generate(12, (monthIndex) {
            int dayCount = daysInMonths[monthIndex];

            // ✅ startIndex: 이 월 이전까지의 누적 일수
            int startIndex = daysInMonths
                .sublist(0, monthIndex)
                .fold(0, (sum, d) => sum + d);

            // ✅ 일 루프 (각 월의 일수만큼)
            return Row(
              mainAxisAlignment: MainAxisAlignment.center,
              spacing: 2,
              children: List.generate(dayCount, (dayIndex) {
                int activityIndex = startIndex + dayIndex;
                int count = activityIndex < activity.length
                    ? activity[activityIndex]
                    : 0;
                return _buildGrassNode(_getLevel(count), appColors);
              }),
            );
          }),
        ),
      ),
    );
  }

  Widget _buildSummaryItem(String iconPath, String text, Color textColor) {
    return Row(
      children: [
        SvgPicture.asset(
          iconPath,
          width: 20,
          height: 20,
          colorFilter: ColorFilter.mode(textColor, BlendMode.srcIn),
        ),
        const SizedBox(width: 4),
        Text(text, style: AppTypography.b2.copyWith(color: textColor)),
      ],
    );
  }

  Widget _buildGrassNode(int level, AppColorsExtension appColors) {
    Color nodeColor;
    switch (level) {
      case 1:
        nodeColor = appColors.primaryAble.withValues(alpha: 0.30);
        break;
      case 2:
        nodeColor = appColors.primaryAble.withValues(alpha: 0.55);
        break;
      case 3:
        nodeColor = appColors.primaryAble.withValues(alpha: 0.80);
        break;
      case 4:
        nodeColor = appColors.primaryAble;
        break;
      default:
        nodeColor = appColors.gray5;
    }

    return Container(
      width: 7,
      height: 7,
      decoration: BoxDecoration(
        color: nodeColor,
        borderRadius: BorderRadius.circular(1),
      ),
    );
  }
}
