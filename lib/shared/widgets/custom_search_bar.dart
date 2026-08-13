// 최초 작성자: 정승빈
// 검색창 위젯

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:haenaem/core/theme/app_colors.dart';
import 'package:haenaem/core/theme/app_typography.dart';

class CustomSearchBar extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final TextInputAction textInputAction;

  const CustomSearchBar({
    super.key,
    required this.controller,
    this.hintText = '검색',
    this.onChanged,
    this.onSubmitted,
    this.textInputAction = TextInputAction.search,
  });

  @override
  Widget build(BuildContext context) {
    final appColors = Theme.of(context).extension<AppColorsExtension>()!;

    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: appColors.whiteToBlack,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: appColors.gray4),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          SvgPicture.asset(
            'assets/images/icons/search_icon.svg',
            width: 18,
            colorFilter: ColorFilter.mode(appColors.gray3, BlendMode.srcIn),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              onSubmitted: onSubmitted,
              textInputAction: textInputAction,
              decoration: InputDecoration(
                hintText: hintText,
                hintStyle: AppTypography.b1.copyWith(color: appColors.gray3),
                border: InputBorder.none,
                isDense: true,
              ),
              style: AppTypography.b1, // 텍스트 크기 통일
            ),
          ),
        ],
      ),
    );
  }
}
