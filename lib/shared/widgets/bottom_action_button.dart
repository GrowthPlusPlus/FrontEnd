// 최초 작성자: 강선욱
// 화면 하단에 표시되는 버튼을 커스텀할 수 있는 클래스
import 'package:flutter/material.dart';
import 'package:haenaem/core/theme/app_colors.dart';
import 'package:haenaem/core/theme/app_typography.dart';

class BottomActionButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;

  // 커스텀 파라미터 추가
  final Color? backgroundColor; // 버튼 배경색
  final Color? textColor; // 글자 색상
  final Color? borderColor; // 테두리 색상 (null이면 테두리 없음)

  const BottomActionButton({
    super.key,
    required this.text,
    this.onPressed,
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
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.white.withValues(alpha: 0),
            Colors.white.withValues(alpha: 0.9),
            Colors.white,
          ],
          stops: const [0.0, 0.3, 1.0],
        ),
      ),
      child: SafeArea(
        top: false, // 상단 여백은 필요 없으므로 하단만 보호
        child: Padding(
          // 💡 하단 여백 30을 유지하되 시스템 바가 있는 경우 자동으로 합산됨
          padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
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
                    ? BorderSide(color: borderColor!, width: 2)
                    : BorderSide.none,
              ),
            ),
            child: FittedBox(
              fit: BoxFit.scaleDown, // 상위 박스를 넘어가면 비율을 유지하며 축소
              child: Text(
                text,
                style: AppTypography.h3.copyWith(color: effectiveTextColor),
                maxLines: 1, // 절대 줄바꿈이 일어나서 깨지지 않도록 방어
                softWrap: false,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
