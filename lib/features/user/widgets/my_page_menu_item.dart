// 최초 작성자 : 김채영
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';

// 반복되는 메뉴 버튼들을 독립적인 위젯으로 분리
class MyPageMenuItem extends StatelessWidget {
  final String title;
  final Color textColor;
  final VoidCallback onTap;
  final bool showArrow;

  const MyPageMenuItem({
    super.key,
    required this.title,
    this.textColor = AppColors.black,
    required this.onTap,
    this.showArrow = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.gray5,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: AppTypography.b1.copyWith(color: textColor)),
          ],
        ),
      ),
    );
  }
}
