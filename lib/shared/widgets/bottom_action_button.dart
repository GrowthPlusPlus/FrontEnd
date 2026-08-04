// 최초 작성자: 강선욱
// 화면 하단에 표시되는 버튼을 커스텀할 수 있는 클래스
import 'package:flutter/material.dart';
import 'package:haenaem/core/theme/app_colors.dart';
import 'package:haenaem/core/theme/app_typography.dart';

class BottomActionButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final IconData? icon;

  // 커스텀 파라미터 추가
  final Color? backgroundColor; // 버튼 배경색
  final Color? textColor; // 글자 색상
  final Color? borderColor; // 테두리 색상 (null이면 테두리 없음)
  final bool
  showContainerDecoration; // 💡 Outer Gradient/Padding 적용 여부 (기본값: true)
  final Duration debounceDuration; // 연속 클릭 방지 쿨타임

  const BottomActionButton({
    super.key,
    required this.text,
    this.onPressed,
    this.icon,
    this.backgroundColor,
    this.textColor,
    this.borderColor,
    this.showContainerDecoration = true,
    this.debounceDuration = const Duration(seconds: 1),
  });

  @override
  State<BottomActionButton> createState() => _BottomActionButtonState();
}

class _BottomActionButtonState extends State<BottomActionButton> {
  bool _isProcessing = false;

  void _handlePressed() async {
    // 버튼 클릭 콜백이 없거나 이미 처리 중이면 클릭 무시
    if (widget.onPressed == null || _isProcessing) return;

    setState(() {
      _isProcessing = true;
    });

    try {
      widget.onPressed!();
    } finally {
      // 설정한 딜레이 시간이 지난 후 다시 클릭 가능 상태로 전환
      await Future.delayed(widget.debounceDuration);
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // 기본값 설정: 파라미터가 없으면 기존 디자인 시스템 색상 사용
    final Color effectiveBgColor =
        widget.backgroundColor ?? AppColors.primaryAble;
    final Color effectiveTextColor = widget.textColor ?? Colors.white;

    final Widget buttonWidget = ElevatedButton(
      onPressed: widget.onPressed == null ? null : _handlePressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: effectiveBgColor,
        minimumSize: const Size(double.infinity, 60),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: widget.borderColor != null
              ? BorderSide(color: widget.borderColor!, width: 2)
              : BorderSide.none,
        ),
      ),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (widget.icon != null) ...[
              Icon(widget.icon, size: 20, color: effectiveTextColor),
              const SizedBox(width: 8),
            ],
            Text(
              widget.text,
              style: AppTypography.h3.copyWith(color: effectiveTextColor),
              maxLines: 1,
              softWrap: false,
            ),
          ],
        ),
      ),
    );

    if (!widget.showContainerDecoration) {
      return buttonWidget;
    }

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
        top: false,
        child: Padding(padding: EdgeInsets.zero, child: buttonWidget),
      ),
    );
  }
}
