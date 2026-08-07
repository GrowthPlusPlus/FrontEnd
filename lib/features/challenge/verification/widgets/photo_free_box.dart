// 최초 작성자 : 김채영
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:haenaem/core/theme/app_colors.dart';
import 'package:haenaem/core/theme/app_typography.dart';

// 사진을 추가해주세요 박스
class PhotoFreeBox extends StatelessWidget {
  const PhotoFreeBox({super.key});
  @override
  Widget build(BuildContext context) {
    final appColors = Theme.of(context).extension<AppColorsExtension>()!;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: ShapeDecoration(
        color: appColors.gray5,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SvgPicture.asset(
            'assets/images/icons/gallery_icon.svg',
            width: 24,
            height: 24,
            colorFilter: ColorFilter.mode(appColors.gray1, BlendMode.srcIn),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '사진 첨부는 선택이에요',
                  style: AppTypography.b2.copyWith(color: appColors.gray1),
                ),
                Text(
                  '사진을 함께 올리면 더 생생한 인증글이 완성돼요😎',
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
