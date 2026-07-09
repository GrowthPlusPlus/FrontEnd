import 'package:flutter/material.dart';
import 'package:haenaem/core/theme/app_colors.dart';
import 'package:haenaem/core/theme/app_typography.dart';

// 최초 작성자: 강선욱

class ConfirmDialog extends StatelessWidget {
  final Widget? icon;
  final String? title;
  final String content;
  final String buttonText;
  final VoidCallback? onConfirm; // 버튼 눌렀을 때 닫기 외에 추가 행동이 필요할 때만 주입

  const ConfirmDialog({
    super.key,
    this.icon,
    this.title,
    required this.content,
    this.buttonText = '확인',
    this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      backgroundColor: Colors.white,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[icon!, const SizedBox(height: 12)],
            if (title != null) ...[
              Text(
                title!,
                style: AppTypography.h2.copyWith(color: AppColors.black),
              ),
            ],
            Text(
              content,
              style: AppTypography.b3.copyWith(color: AppColors.gray1),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 36),

            GestureDetector(
              onTap: () {
                Navigator.of(context).pop();
                if (onConfirm != null) onConfirm!();
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: AppColors.primaryAble, // 해냄 메인 활성화 색상
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Text(
                    buttonText,
                    style: AppTypography.b1.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
