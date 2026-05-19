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
import 'package:haenaem/features/feed/widgets/enter_confirm_dialog.dart';
import 'package:haenaem/shared/widgets/bottom_action_button.dart';

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
    // 1. 상세 데이터 구독
    final challengeAsync = ref.watch(
      challengeDetailProvider(challengeId: widget.challengeId),
    );

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.white,
        leading: IconButton(
          icon: SvgPicture.asset(
            'assets/images/icons/arrow_left.svg',
            width: 24,
            height: 24,
            colorFilter: const ColorFilter.mode(
              AppColors.black,
              BlendMode.srcIn,
            ),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.challengeTitle,
          style: AppTypography.h3.copyWith(color: AppColors.black),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          const Divider(height: 1, color: AppColors.gray4),
          Expanded(
            // 2. 상태별 화면 렌더링
            child: challengeAsync.when(
              loading: () => const Center(
                child: CircularProgressIndicator(color: AppColors.primaryAble),
              ),
              error: (err, stack) {
                // 터미널에 에러의 진짜 이유를 출력합니다.
                debugPrint('❌ 상세페이지 에러 발생: $err');
                debugPrint('❌ 스택트레이스: $stack');

                return Center(
                  child: Text(
                    '에러 내용: $err', // 화면에도 에러를 표시해서 확인
                    textAlign: TextAlign.center,
                    style: AppTypography.b2.copyWith(color: Colors.red),
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
        text: '챌린지 참여하기',
        onPressed: () async {
          final challenge = challengeAsync.value;

          // 데이터가 없는 상태에서 클릭 방지
          if (challenge == null) return;

          // 참여 API 호출
          final success = await ref
              .read(challengeParticipateNotifierProvider.notifier)
              .participate(widget.challengeId);

          // 성공 시 다이얼로그 노출 (챌린지 제목 전달)
          if (success && context.mounted) {
            showDialog(
              context: context,
              builder: (context) => EnterConfirmDialog(
                challengeId: widget.challengeId,
                challengeTitle: widget.challengeTitle,
              ),
            );
          } else {
            // 이미 참여중인 챌린지인 경우 토스트(스낵바) 노출
            final state = ref.read(challengeParticipateNotifierProvider);

            // Repository에서 throw한 Exception 메시지를 가져옵니다.
            final errorMessage =
                state.error?.toString().replaceAll('Exception: ', '') ??
                '이미 참여 중인 챌린지입니다.';

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(errorMessage),
                backgroundColor: AppColors.black, // 앱 테마에 맞는 색상 사용
                behavior: SnackBarBehavior.floating, // 떠 있는 스타일
                duration: const Duration(seconds: 2),
              ),
            );
          }
        },
      ),
    );
  }
}
