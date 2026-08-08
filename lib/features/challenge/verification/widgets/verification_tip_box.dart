// 최초 작성자 : 김채영
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:haenaem/core/theme/app_colors.dart';
import 'package:haenaem/core/theme/app_typography.dart';

// 인증 팁 박스
class VerificationTipBox extends StatelessWidget {
  const VerificationTipBox({super.key});
  @override
  Widget build(BuildContext context) {
    final appColors = Theme.of(context).extension<AppColorsExtension>()!;
    Color tipboxYellow = Theme.of(context).brightness == Brightness.light
        ? const Color(0xFFFFF4D1)
        : const Color(0xFF575046);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: ShapeDecoration(
        color: tipboxYellow,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SvgPicture.asset(
            'assets/images/icons/tip_bulb.svg',
            width: 18,
            height: 18,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '인증 팁',
                  style: AppTypography.b2.copyWith(
                    color: const Color(0xFFF57C00),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '• 날짜/시간이 보이는 사진이 더 좋아요.\n• 구체적인 내용을 작성하면 동기부여에 도움이 됩니다.\n• 긍정적인 에너지를 공유해보세요!',
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
