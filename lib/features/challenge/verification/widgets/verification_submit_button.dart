// 최초 작성자 : 김채영
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:haenaem/core/theme/app_colors.dart';
import 'package:haenaem/core/theme/app_typography.dart';

// 인증하기 버튼
class VerificationSubmitButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final String label;
  final bool showShadow;
  const VerificationSubmitButton({
    super.key,
    required this.label,
    this.onPressed,
    this.showShadow = true,
  });

  @override
  Widget build(BuildContext context) {
    final bool isEnabled = onPressed != null;
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: showShadow
            ? [
                const BoxShadow(
                  color: Color(0x28000000),
                  blurRadius: 20,
                  offset: Offset(0, -1),
                ),
              ]
            : [],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: GestureDetector(
            onTap: onPressed,
            child: Container(
              width: double.infinity,
              height: 56,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: isEnabled ? AppColors.primaryAble : AppColors.disable,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                label,
                style: AppTypography.h3.copyWith(color: Colors.white),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
