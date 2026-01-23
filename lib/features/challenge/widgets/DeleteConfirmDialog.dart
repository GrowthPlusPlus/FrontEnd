// 최초 작성자 : 강선욱
import 'package:flutter/material.dart';
import 'package:haenaem/core/theme/app_colors.dart';
import 'package:haenaem/core/theme/app_typography.dart';

class DeleteConfirmDialog extends StatelessWidget {
  const DeleteConfirmDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20), // 시안의 둥근 모서리 반영
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min, // 내용만큼만 높이 차지
          children: [
            // 1. 타이틀
            Text(
              '인증글 삭제',
              style: AppTypography.h3.copyWith(
                color: AppColors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            // 2. 본문 메시지
            Text(
              '정말로 이 게시물을 삭제하시겠습니까?\n삭제된 게시물은 복구할 수 없습니다.',
              textAlign: TextAlign.center,
              style: AppTypography.b1.copyWith(
                color: AppColors.gray2, // 시안의 어두운 회색 반영
                height: 1.5, // 줄간격 조절
              ),
            ),
            const SizedBox(height: 24),

            // 3. 버튼 영역
            Row(
              children: [
                // 취소 버튼
                Expanded(
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context, false),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        color: AppColors.gray4, // 시안의 연회색 배경
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '취소',
                        textAlign: TextAlign.center,
                        style: AppTypography.b1.copyWith(
                          color: AppColors.gray2,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),

                // 삭제하기 버튼
                Expanded(
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context, true),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        color: AppColors.gray4, // 버튼 배경색 동일
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '삭제하기',
                        textAlign: TextAlign.center,
                        style: AppTypography.b1.copyWith(
                          color: AppColors.notification, // 시안의 강조된 빨간색
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
