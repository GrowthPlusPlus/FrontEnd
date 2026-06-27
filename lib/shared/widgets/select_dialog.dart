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

  const SelectDialog({
    super.key,
    this.title,
    required this.content,
    this.confirmText = '확인',
    this.cancelText = '취소',
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      backgroundColor: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (title != null) ...[
              Text(
                title!,
                style: AppTypography.h3.copyWith(color: AppColors.black),
              ),
              const SizedBox(height: 12),
            ],
            Text(
              content,
              style: AppTypography.b1.copyWith(color: AppColors.gray3),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: MediaQuery.removePadding(
                    context: context,
                    removeBottom: true,
                    child: BottomActionButton(
                      text: cancelText,
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ),
                ),
                Expanded(
                  child: MediaQuery.removePadding(
                    context: context,
                    removeBottom: true,
                    child: BottomActionButton(
                      text: confirmText,
                      onPressed: () {
                        Navigator.of(context).pop();
                        onConfirm();
                      },
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
