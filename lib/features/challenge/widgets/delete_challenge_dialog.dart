// 최초 작성자 : 김채영
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:haenaem/core/theme/app_colors.dart';
import 'package:haenaem/core/theme/app_typography.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../provider/challenge_provider.dart';
import 'package:haenaem/shared/provider/home_provider.dart';

// 방장용 : 챌린지 삭제 다이얼로그
class DeleteChallengeDialog extends ConsumerWidget {
  final int challengeId;
  const DeleteChallengeDialog({super.key, required this.challengeId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: ShapeDecoration(
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // --- 상단 경고 아이콘 섹션 ---
            Container(
              width: 80,
              height: 80,
              decoration: const ShapeDecoration(
                color: AppColors.warning,
                shape: CircleBorder(),
              ),
              child: Center(
                child: SvgPicture.asset(
                  'assets/images/icons/warning.svg',
                  width: 48,
                  height: 48,
                ),
              ),
            ),
            const SizedBox(height: 20),

            // --- 텍스트 섹션 ---
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 4),
                Text(
                  '챌린지를 삭제하시겠습니까?',
                  textAlign: TextAlign.center,
                  style: AppTypography.h3.copyWith(
                    color: AppColors.notification,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '이 작업은 되돌릴 수 없습니다.\n\n삭제 시 영향:\n모든 멤버가 퇴장됩니다.\n성취 그래프와 인증 기록이 삭제됩니다.\n챌린지 정보가 완전히 제거됩니다.',
                  textAlign: TextAlign.center,
                  style: AppTypography.b1.copyWith(color: AppColors.gray2),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // --- 하단 버튼 섹션 ---
            Row(
              children: [
                // 영구 삭제 버튼
                Expanded(
                  child: InkWell(
                    onTap: () async {
                      // 삭제 로직 실행
                      final success = await ref
                          .read(challengeDeleteNotifierProvider.notifier)
                          .removeChallenge(challengeId);

                      if (success && context.mounted) {
                        // 성공 시 모든 창을 닫고 홈으로 이동
                        ref.read(homeNotifierProvider.notifier).refresh();
                        // 내 페이지 진행중인 챌린지 상태 업데이트
                        ref.invalidate(myInProgressChallengesProvider);
                        Navigator.of(
                          context,
                        ).popUntil((route) => route.isFirst);
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: ShapeDecoration(
                        color: AppColors.notification,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Center(
                        child: Text(
                          '영구 삭제',
                          style: AppTypography.b1.copyWith(color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                // 취소 버튼
                Expanded(
                  child: InkWell(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: ShapeDecoration(
                        color: AppColors.gray5,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Center(
                        child: Text(
                          '취소',
                          style: AppTypography.b1.copyWith(
                            color: AppColors.gray2,
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
