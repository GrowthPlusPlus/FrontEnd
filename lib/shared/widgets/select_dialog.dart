import 'package:flutter/material.dart';
import 'package:haenaem/core/theme/app_colors.dart';
import 'package:haenaem/core/theme/app_typography.dart';
import './bottom_action_button.dart';

// 최초 작성자: 강선욱

class SelectDialog extends StatelessWidget {
  final String? title;
  final String content;
  final String confirmText;
  final String cancelText;
  final VoidCallback onConfirm; // 승인 버튼 눌렀을 때 실행할 로직

  final Color? confirmBackgroundColor;
  final Color? confirmTextColor;
  final Color? cancelBackgroundColor;
  final Color? cancelTextColor;

  const SelectDialog({
    super.key,
    this.title,
    required this.content,
    this.confirmText = '확인',
    this.cancelText = '취소',
    required this.onConfirm,
    this.confirmBackgroundColor =
        AppColors.gray5, // 기본값은 BottomActionButton 내부 설정을 따름
    this.confirmTextColor = AppColors.gray2,
    this.cancelBackgroundColor = AppColors.gray5,
    this.cancelTextColor = AppColors.gray2,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      backgroundColor: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (title != null) ...[
              Text(
                title!,
                style: AppTypography.h3.copyWith(color: AppColors.black),
              ),
              const SizedBox(height: 8),
            ],
            Text(
              content,
              style: AppTypography.b1.copyWith(color: AppColors.gray2),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                // 취소 버튼
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: cancelBackgroundColor,
                      foregroundColor: cancelTextColor,
                      elevation: 0, // 다이얼로그 내부 버튼이므로 입체감 제거
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10), // 부드러운 라운딩 처리
                      ),
                      padding: const EdgeInsets.symmetric(
                        vertical: 14,
                      ), // 터치 영역 확보
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text(cancelText, style: AppTypography.b1.copyWith()),
                  ),
                ),
                const SizedBox(width: 10), // 버튼 사이의 간격 추가
                // 확인 버튼
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: confirmBackgroundColor,
                      foregroundColor: confirmTextColor,
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
                    child: Text(
                      confirmText,
                      style: AppTypography.b1.copyWith(),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
