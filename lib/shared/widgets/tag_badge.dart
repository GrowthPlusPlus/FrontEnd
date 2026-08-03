// 최초 작성자 : 김채영
import 'package:flutter/material.dart';
import 'package:haenaem/core/theme/app_colors.dart';
import 'package:haenaem/core/theme/app_typography.dart';

// 챌린지 상세정보와 내 페이지의 공통 태그 디자인
class TagBadge extends StatelessWidget {
  final String label;

  const TagBadge({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    final appColors = Theme.of(context).extension<AppColorsExtension>()!;

    return Container(
      height: 28, // 고정 높이
      padding: const EdgeInsets.symmetric(horizontal: 11),
      decoration: ShapeDecoration(
        color: appColors.selected,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      ),
      child: Center(
        widthFactor: 1.0,
        child: Text(
          label,
          style: AppTypography.b2.copyWith(color: appColors.primaryAble),
        ),
      ),
    );
  }
}
