import 'package:flutter/material.dart';
import 'package:haenaem/core/theme/app_colors.dart';
import 'package:haenaem/core/theme/app_typography.dart';
import './bottom_action_button.dart';

// 최초 작성자: 강선욱

class ConfirmDialog extends StatelessWidget {
  final String? title;
  final String content;
  final String buttonText;
  final VoidCallback? onConfirm; // 버튼 눌렀을 때 닫기 외에 추가 행동이 필요할 때만 주입

  const ConfirmDialog({
    super.key,
    this.title,
    required this.content,
    this.buttonText = '확인',
    this.onConfirm,
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

            BottomActionButton(
              text: buttonText,
              onPressed: () {
                Navigator.of(context).pop();
                if (onConfirm != null) onConfirm!();
              },
            ),
          ],
        ),
      ),
    );
  }
}
