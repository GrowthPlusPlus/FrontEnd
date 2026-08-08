// 최초 작성자 : 김채영
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:haenaem/core/theme/app_colors.dart';
import 'package:haenaem/core/theme/app_typography.dart';

// 재인증 가이드 문구
class ReverificationGuideBox extends StatelessWidget {
  const ReverificationGuideBox({super.key});

  @override
  Widget build(BuildContext context) {
    final appColors = Theme.of(context).extension<AppColorsExtension>()!;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: ShapeDecoration(
        color: appColors.warning,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SvgPicture.asset(
            'assets/images/icons/tip_bulb.svg',
            width: 18,
            height: 18,
            colorFilter: ColorFilter.mode(
              appColors.notification,
              BlendMode.srcIn,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // 타이틀: 재인증 가이드
                Text(
                  '재인증 가이드',
                  style: AppTypography.b2.copyWith(
                    color: appColors.notification,
                  ),
                ),
                const SizedBox(height: 4),
                // 가이드 상세 내용
                Text(
                  '• 챌린지 활동이 명확히 보이는 사진을 촬영해주세요.\n• 흐릿하거나 어두운 사진은 인식되지 않을 수 있습니다.\n• 다른 각도나 조명에서 다시 시도해보세요.',
                  style: AppTypography.c1.copyWith(color: appColors.gray2),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
