import 'package:flutter/material.dart';
import 'package:haenaem/core/theme/app_colors.dart';
import 'package:haenaem/core/theme/app_typography.dart';

class BottomActionButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;

  // 커스텀 파라미터 추가
  final Color? backgroundColor; // 버튼 배경색
  final Color? textColor; // 글자 색상
  final Color? borderColor; // 테두리 색상 (null이면 테두리 없음)

  const BottomActionButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.backgroundColor,
    this.textColor,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    // 기본값 설정: 파라미터가 없으면 기존 디자인 시스템 색상 사용
    final Color effectiveBgColor = backgroundColor ?? AppColors.primaryAble;
    final Color effectiveTextColor = textColor ?? Colors.white;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 30),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.white.withOpacity(0),
            Colors.white.withOpacity(0.9),
            Colors.white,
          ],
          stops: const [0.0, 0.3, 1.0],
        ),
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: effectiveBgColor,
          minimumSize: const Size(double.infinity, 60),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
            // 테두리 조건부 렌더링
            side: borderColor != null
                ? BorderSide(color: borderColor!, width: 1)
                : BorderSide.none,
          ),
        ),
        child: Text(
          text,
          style: AppTypography.h3.copyWith(color: effectiveTextColor),
        ),
      ),
    );
  }
}
