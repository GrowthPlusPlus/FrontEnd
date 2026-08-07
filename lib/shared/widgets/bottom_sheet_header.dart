// 최초 작성자 : 김채영
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:haenaem/core/theme/app_colors.dart';
import 'package:haenaem/core/theme/app_typography.dart';

// 챌린지 생성 화면의 탭화면의 공통 헤더
class BottomSheetHeader extends StatelessWidget {
  final String title;

  const BottomSheetHeader({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    final appColors = Theme.of(context).extension<AppColorsExtension>()!;

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const SizedBox(width: 48), // 왼쪽 균형용 (닫기 버튼 너비와 동일하게)
            Expanded(
              child: Center(
                child: Text(
                  title,
                  style: AppTypography.h3.copyWith(
                    color: appColors.blackToWhite,
                  ),
                ),
              ),
            ),
            SizedBox(
              width: 48,
              child: IconButton(
                padding: EdgeInsets.zero,
                onPressed: () => Navigator.pop(context),
                icon: SvgPicture.asset(
                  'assets/images/icons/tab_close.svg',
                  width: 14,
                  height: 14,
                  colorFilter: ColorFilter.mode(
                    appColors.gray2,
                    BlendMode.srcIn,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
      ],
    );
  }
}
