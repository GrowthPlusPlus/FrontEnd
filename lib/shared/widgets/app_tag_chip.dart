// 최초 작성자 : 김채영
import 'package:flutter/material.dart';
import 'package:haenaem/core/theme/app_colors.dart';
import 'package:haenaem/core/theme/app_typography.dart';

// 앱 내 태그를 선택할 때 사용하는 위젯
class AppTagChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback? onTap;

  const AppTagChip({
    super.key,
    required this.label,
    required this.isSelected,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final appColors = Theme.of(context).extension<AppColorsExtension>()!;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 28,
        padding: const EdgeInsets.symmetric(horizontal: 11),
        decoration: ShapeDecoration(
          // 선택 시 selected 색상 및 primaryAble 테두리, 미선택 시 gray5
          color: isSelected ? appColors.selected : appColors.gray5,
          shape: RoundedRectangleBorder(
            side: isSelected
                ? const BorderSide(width: 2, color: AppColors.primaryAble)
                : BorderSide.none,
            borderRadius: BorderRadius.circular(15),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min, // 텍스트 길이에 맞춰 태그 타원 크기 조절
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              label,
              style: AppTypography.b2.copyWith(
                color: isSelected
                    ? appColors.primaryAble
                    : appColors.blackToWhite,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
                height: 1.0, // 텍스트 중앙 정렬
              ),
            ),
          ],
        ),
      ),
    );
  }
}
