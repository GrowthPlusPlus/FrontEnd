// 최초 작성자 : 강선욱
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:haenaem/core/theme/app_colors.dart';
import 'package:haenaem/core/theme/app_typography.dart';
import 'package:haenaem/features/challenge/detail/widgets/challenge_detail_content.dart';
import 'package:haenaem/features/challenge/provider/challenge_provider.dart';
import 'package:haenaem/features/feed/widgets/enter_confirm_dialog.dart';

class ChallengeDetailScreen extends ConsumerStatefulWidget {
  final int challengeId;
  const ChallengeDetailScreen({super.key, required this.challengeId});

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
          challengeAsync.when(
            data: (challenge) => challenge.title,
            loading: () => '로딩 중...',
            error: (_, __) => '챌린지 상세정보',
          ),
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
                showTitle: false,
              ),
            ),
          ),
        ],
      ),
      // 하단 고정 - 참여하기 버튼
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(top: BorderSide(color: AppColors.gray4, width: 0.5)),
          ),
          child: ElevatedButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) {
                  return EnterConfirmDialog(challengeId: widget.challengeId);
                },
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryAble,
              minimumSize: const Size(double.infinity, 60),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              elevation: 0, // 깔끔한 디자인을 위해 0으로 조정 가능
            ),
            child: Text(
              '챌린지 참여하기',
              style: AppTypography.h3.copyWith(color: Colors.white),
            ),
          ),
        ),
      ),
    );
  }
}
