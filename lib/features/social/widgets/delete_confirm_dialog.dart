import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';

class DeleteConfirmDialog extends StatelessWidget {
  final String userNickname;
  final VoidCallback onDelete;

  const DeleteConfirmDialog({
    super.key,
    required this.userNickname,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      backgroundColor: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('친구 삭제', style: AppTypography.h2),
            const SizedBox(height: 12),
            Text(
              '$userNickname 님을 삭제하시겠습니까?',
              style: AppTypography.b2.copyWith(color: AppColors.gray2),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      height: 48,
                      decoration: BoxDecoration(
                        color: const Color(0x7FDFE1DC),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Center(
                        child: Text('취소', style: AppTypography.b1),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: GestureDetector(
                    onTap: onDelete,
                    child: Container(
                      height: 48,
                      decoration: BoxDecoration(
                        color: const Color(0x7FDFE1DC),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(
                        child: Text(
                          '삭제하기',
                          style: AppTypography.b1.copyWith(
                            color: AppColors.notification,
                            fontWeight: FontWeight.w600,
                          ),
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
