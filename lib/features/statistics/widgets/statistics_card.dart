// 최초 작성자: 김채영
import 'package:flutter/material.dart';
import 'package:haenaem/core/theme/app_colors.dart';
import 'package:haenaem/core/theme/app_typography.dart';

// 통계 화면 위젯들의 공통 흰색 카드
class StatisticsCard extends StatelessWidget {
  final String title;
  final Widget child;
  final Widget? headerAction; // 오른쪽 상단에 들어갈 인증 횟수 등

  const StatisticsCard({
    super.key,
    required this.title,
    required this.child,
    this.headerAction,
  });

  @override
  Widget build(BuildContext context) {
    final appColors = Theme.of(context).extension<AppColorsExtension>()!;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20), // 화면 양끝과 20 차이
      child: Container(
        padding: const EdgeInsets.all(20), // 카드 내부 기본 패딩 (상단 20 포함)
        decoration: ShapeDecoration(
          color: appColors.whiteToBlack,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          shadows: const [
            BoxShadow(
              color: Color(0x3F000000),
              blurRadius: 16,
              offset: Offset(0, 4),
              spreadRadius: 0,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 헤더 영역 (제목 + 선택적 액션)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: AppTypography.h3.copyWith(
                    color: appColors.blackToWhite,
                  ),
                ),
                if (headerAction != null) headerAction!,
              ],
            ),
            const SizedBox(height: 20), // 헤더와 콘텐츠 사이 20 차이
            child,
          ],
        ),
      ),
    );
  }
}
