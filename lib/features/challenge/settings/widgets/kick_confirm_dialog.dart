import 'package:flutter/material.dart';
import 'package:haenaem/core/theme/app_colors.dart';
import 'package:haenaem/core/theme/app_typography.dart';

class KickConfirmDialog extends StatelessWidget {
  final String nickname;
  final VoidCallback onConfirm;

  const KickConfirmDialog({
    super.key,
    required this.nickname,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20), // 좌우 여백
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(16),
        width: double.infinity, // 다이얼로그 너비를 insetPadding에 맞춤
        child: Column(
          mainAxisSize: MainAxisSize.min, // 내용물만큼만 높이 차지
          children: [
            const SizedBox(height: 4),
            // 타이틀
            Text(
              '강제 퇴장',
              style: AppTypography.h3.copyWith(color: AppColors.black),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            // 설명 텍스트 (닉네임 동적 적용)
            Text(
              '$nickname 님을 강퇴하시겠습니까?',
              style: AppTypography.b1.copyWith(
                color: AppColors.gray2,
                fontWeight: FontWeight.w500, // 디자인상 Medium
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            // 버튼 영역
            Row(
              children: [
                // 취소 버튼
                Expanded(
                  child: _buildActionButton(
                    text: '취소',
                    textColor: AppColors.gray2,
                    backgroundColor: AppColors.gray5,
                    onTap: () => Navigator.pop(context),
                  ),
                ),
                const SizedBox(width: 10),
                // 강제 퇴장 버튼
                Expanded(
                  child: _buildActionButton(
                    text: '강퇴',
                    textColor: AppColors.notification, // 붉은색
                    backgroundColor: AppColors.gray5,
                    onTap: () {
                      onConfirm();
                      Navigator.pop(context); // 동작 수행 후 닫기
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // 버튼 스타일 공통 위젯
  Widget _buildActionButton({
    required String text,
    required Color textColor,
    required Color backgroundColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 48, // 버튼 높이 (디자인 비율 고려)
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(10),
        ),
        alignment: Alignment.center,
        child: Text(
          text,
          style: AppTypography.b1.copyWith(
            color: textColor,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
