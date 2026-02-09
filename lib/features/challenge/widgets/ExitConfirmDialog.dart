// 최초 작성자 : 강선욱
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:haenaem/core/theme/app_colors.dart';
import 'package:haenaem/core/theme/app_typography.dart';

// 챌린지 나가기 다이얼로그
class ExitConfirmDialog extends StatelessWidget {
  const ExitConfirmDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24.0)),
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 이모지
            const Text('🥺', style: TextStyle(fontSize: 64)),
            // 제목
            Text(
              '챌린지를 나가시겠어요?',
              style: AppTypography.h3.copyWith(fontSize: 18),
            ),
            const SizedBox(height: 10),
            // 경고 문구
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(
                    top: 3.0,
                  ), // 텍스트 첫 줄 중앙을 위해 미세 조정
                  child: SvgPicture.asset(
                    'assets/images/icons/tri_warning_icon.svg',
                    width: 20,
                    height: 20,
                    colorFilter: const ColorFilter.mode(
                      AppColors.notification,
                      BlendMode.srcIn,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    '지금까지의 진행 상황이 모두 사라지며,\n복구할 수 없습니다.',
                    textAlign: TextAlign.center,
                    style: AppTypography.b1.copyWith(
                      color: AppColors.notification,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),
            // 버튼 영역
            Row(
              children: [
                // 나가기 버튼
                Expanded(
                  child: SizedBox(
                    height: 52,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context, true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.notification,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        '나가기',
                        style: AppTypography.b1.copyWith(color: Colors.white),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // 취소 버튼
                Expanded(
                  child: SizedBox(
                    height: 52,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context, false),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.gray5,
                        foregroundColor: AppColors.gray2,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        '취소',
                        style: AppTypography.b1.copyWith(
                          color: AppColors.gray2,
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
