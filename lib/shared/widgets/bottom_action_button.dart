// 최초 작성자: 강선욱
// 화면 하단에 표시되는 버튼을 커스텀할 수 있는 클래스
import 'package:flutter/material.dart';
import 'package:haenaem/core/theme/app_colors.dart';
import 'package:haenaem/core/theme/app_typography.dart';

class BottomActionButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final IconData? icon;

  // 커스텀 파라미터 추가
  final Color? backgroundColor; // 버튼 배경색
  final Color? textColor; // 글자 색상
  final Color? borderColor; // 테두리 색상 (null이면 테두리 없음)
  final bool
  showContainerDecoration; // 💡 Outer Gradient/Padding 적용 여부 (기본값: true)

  const BottomActionButton({
    super.key,
    required this.text,
    this.onPressed,
    this.icon,
    this.backgroundColor,
    this.textColor,
    this.borderColor,
    this.showContainerDecoration = true,
  });

  @override
  Widget build(BuildContext context) {
    final appColors = Theme.of(context).extension<AppColorsExtension>()!;

    // 기본값 설정: 파라미터가 없으면 기존 디자인 시스템 색상 사용
    final Color effectiveBgColor = backgroundColor ?? appColors.primaryAble;
    final Color effectiveTextColor = textColor ?? appColors.whiteToBlack;

    final Widget buttonWidget = ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: effectiveBgColor,
        minimumSize: const Size(double.infinity, 60),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: borderColor != null
              ? BorderSide(color: borderColor!, width: 2)
              : BorderSide.none,
        ),
      ),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 20, color: effectiveTextColor),
              const SizedBox(width: 8),
            ],
            Text(
              text,
              style: AppTypography.b1.copyWith(color: effectiveTextColor),
              maxLines: 1,
              softWrap: false,
            ),
          ],
        ),
      ),
    );

    if (!showContainerDecoration) {
      return buttonWidget;
    }

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            appColors.whiteToBlack.withValues(alpha: 0),
            appColors.whiteToBlack.withValues(alpha: 0.9),
            appColors.whiteToBlack,
          ],
          stops: const [0.0, 0.3, 1.0],
        ),
      ),
      child: SafeArea(
        top: false,
        child: Padding(padding: EdgeInsets.zero, child: buttonWidget),
      ),
    );
  }
}
