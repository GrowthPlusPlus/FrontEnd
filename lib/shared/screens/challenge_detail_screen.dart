// 최초 작성자 : 강선욱
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:haenaem/core/theme/app_colors.dart';
import 'package:haenaem/core/theme/app_typography.dart';
// import 'package:haenaem/features/challenge/provider/challenge_provider.dart';
import '../../features/feed/provider/challenge_participate_provider.dart';
import 'package:haenaem/shared/provider/challenge_detail_provider.dart';
import 'package:haenaem/shared/widgets/challenge_detail_content.dart';
// import 'package:haenaem/features/feed/widgets/enter_confirm_dialog.dart';
import 'package:haenaem/features/challenge/detail/screens/challenge_main_screen.dart';
import 'package:haenaem/shared/widgets/confirm_dialog.dart';
import 'package:haenaem/shared/widgets/bottom_action_button.dart';
import 'package:haenaem/shared/widgets/animated_toast.dart';
import 'package:haenaem/features/feed/screens/challenge_search_screen.dart';
import 'package:haenaem/features/feed/provider/challenge_search_provider.dart';

class ChallengeDetailScreen extends ConsumerStatefulWidget {
  final int challengeId;
  final String challengeTitle;
  const ChallengeDetailScreen({
    super.key,
    required this.challengeId,
    required this.challengeTitle,
  });

  @override
  ConsumerState<ChallengeDetailScreen> createState() =>
      _ChallengeDetailScreenState();
}

class _ChallengeDetailScreenState extends ConsumerState<ChallengeDetailScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appColors = Theme.of(context).extension<AppColorsExtension>()!;

    // 1. 상세 데이터 구독
    final challengeAsync = ref.watch(
      challengeDetailProvider(challengeId: widget.challengeId),
    );

    final challenge = challengeAsync.value;
    final isJoined = challenge?.join ?? false;

    // ── 버튼 상태 계산 ─────────────────────────────────────
    String buttonText = '참여하기';
    Color? buttonBgColor;
    VoidCallback? buttonOnPressed;

    if (challenge != null) {
      final now = DateTime.now();
      // 시간 계산 시 시/분/초 오차 방지를 위한 오늘 자정 기준 날짜 계산
      final today = DateTime(now.year, now.month, now.day);
      final endDate = DateTime(
        challenge.endDate.year,
        challenge.endDate.month,
        challenge.endDate.day,
      );

      // 1. 종료된 챌린지 (endDate가 오늘 이전)
      if (endDate.isBefore(today)) {
        buttonText = '종료됨';
        buttonBgColor = AppColors.disable;
        buttonOnPressed = () => displayToast(context, '이미 종료된 챌린지입니다.');
      }
      // 2. 이전에 참여/탈퇴한 챌린지 (joinedBefore == true)
      else if (challenge.joinedBefore == true && challenge.join == false) {
        buttonText = '재참여 불가'; // 또는 '탈퇴 완료'
        buttonBgColor = AppColors.disable;
        buttonOnPressed = () => displayToast(context, '이전에 탈퇴하여 재참여할 수 없습니다.');
      }
      // 3. 현재 참여 중인 챌린지 (join == true)
      else if (challenge.join == true) {
        buttonText = '참여 중';
        buttonBgColor = appColors.primaryAble; // 브랜드 초록색 유지
        buttonOnPressed = () => displayToast(context, '이미 참여 중인 챌린지입니다.');
      }
      // 4. 정상 참여 가능 (위 3가지 모두 아님)
      else {
        buttonText = '참여하기';
        buttonBgColor = null; // 기본 활성화 컬러 적용
        buttonOnPressed = () async {
          final success = await ref
              .read(challengeParticipateNotifierProvider.notifier)
              .participate(widget.challengeId);

          if (success && context.mounted) {
            ref.invalidate(searchChallengesProvider);
            // 참여 성공 시 상세 정보 리프레시
            ref.invalidate(
              challengeDetailProvider(challengeId: widget.challengeId),
            );

            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (dialogContext) => ConfirmDialog(
                icon: SizedBox(
                  width: 42,
                  height: 42,
                  child: SvgPicture.asset(
                    'assets/images/icons/round_check_icon.svg',
                    width: 42,
                    height: 42,
                  ),
                ),
                title: '챌린지 참여 완료!',
                content: '‘${widget.challengeTitle}’\n지금부터 함께 도전해요!',
                buttonText: '확인',
                onConfirm: () {
                  if (context.mounted) {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ChallengeMainScreen(
                          challengeId: widget.challengeId,
                          challengeTitle: widget.challengeTitle,
                        ),
                      ),
                      (route) =>
                          route.settings.name ==
                              ChallengeSearchScreen.routeName ||
                          route.isFirst,
                    );
                  }
                },
              ),
            );
          } else {
            final state = ref.read(challengeParticipateNotifierProvider);
            final errorMessage =
                state.error?.toString().replaceAll('Exception: ', '') ??
                '참여 처리에 실패했습니다.';

            displayToast(context, errorMessage);
          }
        };
      }
    }

    return Scaffold(
      backgroundColor: appColors.whiteToBlack,
      appBar: AppBar(
        backgroundColor: appColors.whiteToBlack,
        elevation: 0,
        surfaceTintColor: appColors.whiteToBlack,
        leading: IconButton(
          icon: SvgPicture.asset(
            'assets/images/icons/arrow_left.svg',
            width: 24,
            height: 24,
            colorFilter: ColorFilter.mode(
              appColors.blackToWhite,
              BlendMode.srcIn,
            ),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.challengeTitle,
          style: AppTypography.h3.copyWith(color: appColors.blackToWhite),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Divider(height: 1, color: appColors.gray4),
          Expanded(
            // 2. 상태별 화면 렌더링
            child: challengeAsync.when(
              loading: () => Center(
                child: CircularProgressIndicator(color: appColors.primaryAble),
              ),
              error: (err, stack) {
                // 터미널에 에러의 진짜 이유를 출력합니다.
                debugPrint('❌ 상세페이지 에러 발생: $err');
                debugPrint('❌ 스택트레이스: $stack');

                return Center(
                  child: Text(
                    '에러 내용: $err', // 화면에도 에러를 표시해서 확인
                    textAlign: TextAlign.center,
                    style: AppTypography.b2.copyWith(
                      color: appColors.notification,
                    ),
                  ),
                );
              },
              data: (challenge) => ChallengeDetailContent(
                challenge: challenge,
                scrollController: _scrollController,
                showTitle: true,
              ),
            ),
          ),
        ],
      ),
      // 하단 고정 - 참여하기 버튼
      bottomNavigationBar: BottomActionButton(
        text: buttonText,
        backgroundColor: buttonBgColor,
        onPressed: challenge == null ? null : buttonOnPressed,
      ),
    );
  }
}
