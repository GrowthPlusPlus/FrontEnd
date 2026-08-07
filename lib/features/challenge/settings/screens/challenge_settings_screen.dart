// 최초 작성자 : 김채영
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:haenaem/core/theme/app_colors.dart';
import 'package:haenaem/core/theme/app_typography.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:haenaem/shared/widgets/select_dialog.dart';
import '../provider/challenge_member_provider.dart';
import '../provider/challenge_delete_provider.dart';
import 'package:haenaem/shared/provider/home_provider.dart';
import 'package:haenaem/features/user/provider/my_challenge_provider.dart';

import 'challenge_members_screen.dart';

// 챌린지 설정화면
class ChallengeSettingsScreen extends ConsumerWidget {
  final int challengeId; // 삭제를 위해 ID 필요

  const ChallengeSettingsScreen({super.key, required this.challengeId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appColors = Theme.of(context).extension<AppColorsExtension>()!;

    return Scaffold(
      backgroundColor: appColors.whiteToBlack,
      appBar: AppBar(
        backgroundColor: appColors.whiteToBlack,
        elevation: 0,
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
          '챌린지 설정',
          style: AppTypography.h3.copyWith(color: appColors.blackToWhite),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- 챌린지 운영 관리 섹션 ---
              _buildSectionTitle('챌린지 운영 관리', appColors.blackToWhite),
              const SizedBox(height: 8),
              _buildManageTile(
                appColors,
                title: '챌린지 멤버 관리',
                iconPath: 'assets/images/icons/friend_icon_on.svg',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ChallengeMemberManagementScreen(
                        challengeId: challengeId,
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 30),

              // --- 위험 구역 섹션 (통합 박스 구조) ---
              _buildSectionTitle('위험구역', appColors.notification),
              const SizedBox(height: 10),
              _buildDangerZoneContainer(context, ref, appColors),
            ],
          ),
        ),
      ),
    );
  }

  // 섹션 타이틀 헬퍼
  Widget _buildSectionTitle(String title, Color color) {
    return Text(title, style: AppTypography.h3.copyWith(color: color));
  }

  // 관리 메뉴 타일
  Widget _buildManageTile(
    AppColorsExtension appColors, {
    required String title,
    required String iconPath,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: appColors.gray5,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                SvgPicture.asset(
                  iconPath,
                  width: 16,
                  height: 16,
                  colorFilter: ColorFilter.mode(
                    appColors.blackToWhite,
                    BlendMode.srcIn,
                  ),
                ),
                const SizedBox(width: 10),
                Text(title, style: AppTypography.b1),
              ],
            ),
            SvgPicture.asset(
              'assets/images/icons/right_arrow_icon.svg',
              width: 16,
              height: 16,
              colorFilter: ColorFilter.mode(
                appColors.blackToWhite,
                BlendMode.srcIn,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 위험 구역 통합 컨테이너
  Widget _buildDangerZoneContainer(
    BuildContext context,
    WidgetRef ref,
    AppColorsExtension appColors,
  ) {
    return Container(
      width: double.infinity,
      decoration: ShapeDecoration(
        color: appColors.gray5,
        shape: RoundedRectangleBorder(
          side: BorderSide(width: 1, color: appColors.gray4),
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      child: Column(
        children: [
          // 상단: 챌린지 나가기 구역
          _buildDangerItem(
            appColors,
            context: context,
            title: '챌린지 나가기',
            description: '다른 멤버에게 챌린지장을 위임한 후, 챌린지를 나갑니다.',
            buttonText: '챌린지장 위임하고 나가기',
            onTap: () {
              // 1. 다이얼로그 호출 (결과값은 int? 타입)
              showDialog(
                context: context,
                builder: (context) => SelectDialog(
                  title: '챌린지장 위임하기',
                  content: '다른 멤버에게 챌린지장을 위임하고\n정말 이 챌린지에서 나가시겠습니까?',
                  confirmText: '나가기',
                  confirmBackgroundColor: appColors.notification,
                  confirmTextColor: appColors.whiteToBlack,
                  cancelText: '취소',
                  onConfirm: () async {
                    final currentFilter = MemberFilter(
                      challengeId: challengeId,
                    );

                    // 자동 위임 함수 호출
                    final success = await ref
                        .read(challengeMembersProvider(currentFilter).notifier)
                        .delegateOwnerAuto(challengeId: challengeId);

                    if (success && context.mounted) {
                      Navigator.pop(context); // 다이얼로그 닫기
                      Navigator.pop(context); // 챌린지 화면 나가기 (이전 화면으로 돌아감)
                    }
                  },
                  onCancel: () {},
                ),
              );
            },
          ),

          // 중간 구분선
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 0),
            child: Divider(height: 1, color: appColors.gray4),
          ),

          // 하단: 챌린지 삭제 구역
          _buildDangerItem(
            appColors,
            context: context,
            title: '챌린지 삭제',
            description:
                '챌린지 방을 완전히 삭제합니다. 모든 데이터와 성취 그래프가 사라지며, 이 작업은 되돌릴 수 없습니다.',
            buttonText: '챌린지 삭제하기',
            isDelete: true,
            onTap: () {
              showDialog(
                context: context,
                builder: (context) => SelectDialog(
                  emoji: '🚨', // 간단하게 아이콘 대신 이모지로 대체할 경우
                  title: '챌린지를 삭제하시겠습니까?',
                  titleColor: AppColors.notification, // 제목 빨간색 스타일 반영
                  content:
                      '이 작업은 되돌릴 수 없습니다.\n\n삭제 시 영향:\n• 모든 멤버가 퇴장됩니다.\n• 성취 그래프와 인증 기록이 삭제됩니다.\n• 챌린지 정보가 완전히 제거됩니다.',
                  confirmText: '영구 삭제',
                  confirmBackgroundColor: appColors.notification,
                  confirmTextColor: appColors.whiteToBlack,
                  cancelText: '취소',
                  cancelTextColor: appColors.gray2,
                  onConfirm: () async {
                    // 기존 다이얼로그에 있던 삭제 로직 그대로 이식
                    final success = await ref
                        .read(challengeDeleteNotifierProvider.notifier)
                        .removeChallenge(challengeId);

                    if (success && context.mounted) {
                      // 상태 갱신
                      ref.read(homeNotifierProvider.notifier).refresh();
                      ref.invalidate(myInProgressChallengesProvider);

                      // 홈으로 이동
                      Navigator.of(context).popUntil((route) => route.isFirst);
                    }
                  },
                  onCancel: () {},
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // 위험 구역 내부 아이템 빌더
  Widget _buildDangerItem(
    AppColorsExtension appColors, {
    required BuildContext context,
    required String title,
    required String description,
    required String buttonText,
    required VoidCallback onTap,
    bool isDelete = false,
  }) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTypography.b3.copyWith(color: appColors.notification),
          ),
          const SizedBox(height: 4),
          Text(
            description,
            style: AppTypography.b2.copyWith(color: appColors.gray2),
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: onTap,
            style: ElevatedButton.styleFrom(
              backgroundColor: isDelete
                  ? appColors.notification
                  : appColors.whiteToBlack,
              elevation: 0,
              minimumSize: const Size(double.infinity, 40),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
                side: isDelete
                    ? BorderSide.none
                    : BorderSide(color: appColors.gray4),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (isDelete) ...[
                  SvgPicture.asset(
                    'assets/images/icons/small_trash_icon.svg',
                    width: 16,
                    height: 16,
                    colorFilter: ColorFilter.mode(
                      appColors.whiteToBlack,
                      BlendMode.srcIn,
                    ),
                  ),
                  const SizedBox(width: 4),
                ],
                Text(
                  buttonText,
                  style: AppTypography.b1.copyWith(
                    color: isDelete
                        ? appColors.whiteToBlack
                        : appColors.blackToWhite,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
