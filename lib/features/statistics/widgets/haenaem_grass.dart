// 최초 작성자: 김채영
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:haenaem/core/theme/app_colors.dart';
import 'package:haenaem/core/theme/app_typography.dart';
import 'statistics_card.dart';

class HaenaemGrass extends StatelessWidget {
  final int successDays;
  final int currentStreak;
  final List<int> activity; // 1년치 활동 데이터 (약 365개)

  const HaenaemGrass({
    super.key,
    required this.successDays,
    required this.currentStreak,
    required this.activity,
  });

  @override
  Widget build(BuildContext context) {
    // 2026년 월별 일수 배열 (평년 기준)
    // 나중에 연별로 알아서 바뀌게끔 로직 수정
    final List<int> daysInMonths = [
      31,
      28,
      31,
      30,
      31,
      30,
      31,
      31,
      30,
      31,
      30,
      31,
    ];

    return StatisticsCard(
      title: "해냄 잔디",
      // ✅ headerAction을 사용하여 상단 우측에 인증 횟수 배치
      headerAction: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildSummaryItem(
            'assets/images/icons/mini_success_icon.svg',
            '$successDays일',
            AppColors.primaryAble,
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
        // StatisticsCard 내부 패딩(20) + 12.5 = 카드 끝에서 총 32.5 여백
        padding: const EdgeInsets.symmetric(horizontal: 12.5),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          spacing: 6, // 잔디 한 줄(월)끼리의 간격
          children: List.generate(12, (monthIndex) {
            int dayCount = daysInMonths[monthIndex];

            return Row(
              mainAxisAlignment: MainAxisAlignment.center,
              spacing: 2, // 잔디 한 칸끼리의 간격
              children: List.generate(dayCount, (dayIndex) {
                return _buildGrassNode(); // 모든 잔디 gray5 색상
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

  // 잔디 한 알
  Widget _buildGrassNode() {
    // Color nodeColor;
    // switch (level) {
    //   case 1:
    //     nodeColor = AppColors.primaryAble.withValues(alpha: 0.25);
    //     break;
    //   case 2:
    //     nodeColor = AppColors.primaryAble.withValues(alpha: 0.5);
    //     break;
    //   case 3:
    //     nodeColor = AppColors.primaryAble.withValues(alpha: 0.75);
    //     break;
    //   case 4:
    //     nodeColor = AppColors.primaryAble;
    //     break;
    //   default:
    //     nodeColor = AppColors.gray5;
    // }

    return Container(
      width: 6,
      height: 6,
      decoration: BoxDecoration(
        color: AppColors.gray5,
        borderRadius: BorderRadius.circular(1),
      ),
    );
  }
}
