// 최초 작성자 : 김채영
import 'package:flutter/material.dart';
import 'package:haenaem/core/theme/app_colors.dart';
import 'package:haenaem/core/theme/app_typography.dart';
import 'package:flutter_svg/flutter_svg.dart';

// 챌린지 인증 방식의 버튼
class ChallengeSelectButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const ChallengeSelectButton({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 48,
          decoration: BoxDecoration(
            // 활성화 시 selected 색상, 비활성 시 gray5
            color: isSelected ? AppColors.selected : AppColors.gray5,
            borderRadius: BorderRadius.circular(8),
            // 활성화 시에만 primaryAble 외곽선 추가
            border: isSelected
                ? Border.all(color: AppColors.primaryAble, width: 2)
                : null,
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: AppTypography.b2.copyWith(
              // 활성화 시 Bold + primaryAble 색상
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected ? AppColors.primaryAble : AppColors.black,
            ),
          ),
        ),
      ),
    );
  }
}
