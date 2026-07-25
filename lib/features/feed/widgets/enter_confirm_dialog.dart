// 최초 작성자 : 강선욱
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:haenaem/core/theme/app_colors.dart';
import 'package:haenaem/core/theme/app_typography.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:haenaem/features/challenge/provider/challenge_provider.dart';
import '../provider/challenge_participate_provider.dart';
import 'package:haenaem/features/challenge/detail/screens/challenge_main_screen.dart';
import 'package:haenaem/features/feed/screens/challenge_search_screen.dart';

class EnterConfirmDialog extends ConsumerWidget {
  final int challengeId;
  final String? challengeTitle;

  const EnterConfirmDialog({
    super.key,
    required this.challengeId,
    required this.challengeTitle,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(challengeParticipateNotifierProvider);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: 25.0),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(15, 25, 15, 15),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 성공 체크 아이콘
            SizedBox(
              width: 42,
              height: 42,
              child: SvgPicture.asset(
                'assets/images/icons/round_check_icon.svg',
                width: 42,
                height: 42,
              ),
            ),
            const SizedBox(height: 10),
            // 제목
            Text(
              '챌린지 참여 완료!',
              style: AppTypography.h2.copyWith(color: AppColors.black),
            ),
            const SizedBox(height: 3),
            // 챌린지 명 넣기
            Text(
              '‘$challengeTitle’',
              style: AppTypography.b3.copyWith(color: AppColors.gray1),
              textAlign: TextAlign.center,
            ),
            Text(
              '지금부터 함께 도전해요!',
              style: AppTypography.b1.copyWith(color: AppColors.gray1),
            ),
            const SizedBox(height: 24),
            // 확인 버튼
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () => Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ChallengeMainScreen(
                      challengeId: challengeId,
                      challengeTitle: challengeTitle,
                    ),
                  ),
                  (route) =>
                      route.settings.name ==
                          ChallengeSearchScreen
                              .routeName || // 탐색 화면을 찾으면 거기서 멈춤
                      route.isFirst, // 못 찾으면(다른 경로로 들어온 경우) 기존처럼 맨 처음까지
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryAble,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  '확인',
                  style: AppTypography.b1.copyWith(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
