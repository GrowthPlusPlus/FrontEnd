// 최초 작성자 : 김채영
import 'package:flutter/material.dart';
import 'package:haenaem/core/theme/app_colors.dart';
import 'package:haenaem/core/theme/app_typography.dart';

// 작성하다가 뒤로가기 누를 경우 나오는 다이얼로그 (인증글 작성할 경우와 인증글 수정할 경우로 나뉨)
class VerificationCancelDialog extends StatelessWidget {
  final String title; // 제목
  final String message; // 본문 설명
  final String cancelLabel;

  const VerificationCancelDialog({
    super.key,
    required this.title,
    required this.message,
    required this.cancelLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 4),
            Text(
              title,
              style: AppTypography.h3.copyWith(color: AppColors.black),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: AppTypography.b1.copyWith(color: AppColors.gray2),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                // 계속 진행 버튼
                Expanded(
                  child: GestureDetector(
                    onTap: () =>
                        Navigator.pop(context, false), // 취소 안 함 (계속 작성)
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: AppColors.gray5,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '계속 작성하기',
                        textAlign: TextAlign.center,
                        style: AppTypography.b1.copyWith(
                          color: AppColors.gray2,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                // 나가기 버튼
                Expanded(
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context, true), // 나감
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: AppColors.gray5,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        cancelLabel,
                        textAlign: TextAlign.center,
                        style: AppTypography.b1.copyWith(
                          color: AppColors.notification,
                        ),
                      ),
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
