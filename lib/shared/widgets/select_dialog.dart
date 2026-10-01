import 'package:flutter/material.dart';
import 'package:haenaem/core/theme/app_colors.dart';
import 'package:haenaem/core/theme/app_typography.dart';

// 최초 작성자: 강선욱

class SelectDialog extends StatelessWidget {
  final String? emoji;
  final String? title;
  final String content;
  final String confirmText;
  final String cancelText;
  final VoidCallback onConfirm;
  final VoidCallback onCancel;

  final Color? titleColor;
  final Color? contentColor;
  final Color? confirmBackgroundColor;
  final Color? confirmTextColor;
  final Color? cancelBackgroundColor;
  final Color? cancelTextColor;

  // true면 확인 버튼이 왼쪽, 취소 버튼이 오른쪽 (기본값 false: 기존과 동일하게 취소-확인 순)
  final bool swapButtonOrder;

  const SelectDialog({
    super.key,
    this.emoji,
    this.title,
    required this.content,
    this.confirmText = '확인',
    this.cancelText = '취소',
    required this.onConfirm,
    required this.onCancel,
    this.titleColor,
    this.contentColor,
    this.confirmBackgroundColor,
    this.confirmTextColor,
    this.cancelBackgroundColor,
    this.cancelTextColor,
    this.swapButtonOrder = false,
  });

  @override
  Widget build(BuildContext context) {
    final appColors = Theme.of(context).extension<AppColorsExtension>()!;

    final cancelButton = Expanded(
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: cancelBackgroundColor ?? appColors.gray5,
          foregroundColor: cancelTextColor ?? appColors.gray2,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          padding: const EdgeInsets.symmetric(vertical: 14),
        ),
        onPressed: () {
          Navigator.of(context).pop();
          onCancel();
        },
        child: Text(cancelText, style: AppTypography.b1.copyWith()),
      ),
    );

    final confirmButton = Expanded(
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: confirmBackgroundColor ?? appColors.gray5,
          foregroundColor: confirmTextColor ?? appColors.gray2,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          padding: const EdgeInsets.symmetric(vertical: 14),
        ),
        onPressed: () {
          Navigator.of(context).pop();
          onConfirm();
        },
        child: Text(confirmText, style: AppTypography.b1.copyWith()),
      ),
    );

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      backgroundColor: appColors.whiteToBlack,
      child: Container(
        width: 335,
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (emoji != null) ...[
              Text(emoji!, style: const TextStyle(fontSize: 64)),
              const SizedBox(height: 8),
            ],
            if (title != null) ...[
              Text(
                title!,
                style: AppTypography.h3.copyWith(
                  color: titleColor ?? appColors.blackToWhite,
                ),
              ),
              const SizedBox(height: 8),
            ],
            Text(
              content,
              style: AppTypography.b1.copyWith(
                color: contentColor ?? appColors.gray2,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Row(
              // swapButtonOrder에 따라 배치 순서만 바꿈 (로직은 각 버튼 위젯 그대로)
              children: swapButtonOrder
                  ? [confirmButton, const SizedBox(width: 10), cancelButton]
                  : [cancelButton, const SizedBox(width: 10), confirmButton],
            ),
          ],
        ),
      ),
    );
  }
}
