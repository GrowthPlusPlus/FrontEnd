// 최초 작성자 : 강선욱
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // 추가
import 'package:flutter_svg/flutter_svg.dart';
import 'package:haenaem/core/theme/app_colors.dart';
import 'package:haenaem/core/theme/app_typography.dart';
import 'package:haenaem/features/challenge/invite/screens/challenge_invite_screen.dart';
import 'package:haenaem/shared/widgets/select_dialog.dart';
import 'package:haenaem/features/challenge/detail/widgets/notification_settings_dialog.dart';
import 'package:haenaem/features/challenge/settings/screens/challenge_settings_screen.dart';
// import 'package:haenaem/features/challenge/provider/challenge_provider.dart'; // 추가
import '../provider/challenge_leave_provider.dart';
import 'package:haenaem/shared/widgets/animated_toast.dart';

// 챌린지방 팝업 (방장일 경우/멤버일 경우)
class ChallengePopupMenu extends ConsumerWidget {
  // ConsumerWidget으로 변경
  final bool isHost; // 방장 여부
  final int challengeId;

  const ChallengePopupMenu({
    super.key,
    required this.isHost,
    required this.challengeId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appColors = Theme.of(context).extension<AppColorsExtension>()!;

    // WidgetRef 추가
    return PopupMenuButton<String>(
      popUpAnimationStyle: const AnimationStyle(
        duration: Duration.zero,
        reverseDuration: Duration.zero,
      ),
      icon: SvgPicture.asset(
        'assets/images/icons/dots_vert_icon.svg',
        width: 24,
        height: 24,
        colorFilter: ColorFilter.mode(appColors.blackToWhite, BlendMode.srcIn),
      ),
      color: appColors.whiteToBlack,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(color: appColors.gray4, width: 1),
      ),
      offset: const Offset(0, 40),

      // 아이템 빌더에서 조건부 리스트 생성
      itemBuilder: (BuildContext context) {
        return [
          _buildPopupItem(
            '알림 설정',
            'assets/images/icons/notification_icon.svg',
            'notification',
            appColors,
          ),
          const PopupMenuDivider(height: 1),
          _buildPopupItem(
            '챌린지 초대',
            'assets/images/icons/share_icon.svg',
            'invite',
            appColors,
          ),
          const PopupMenuDivider(height: 1),

          // --- 방장/참여자 구분 구간 ---
          if (isHost)
            _buildPopupItem(
              '챌린지 설정',
              'assets/images/icons/black_settings_icon.svg', // 방장용 설정 아이콘
              'settings',
              appColors,
            )
          else
            _buildPopupItem(
              '챌린지 나가기',
              'assets/images/icons/exit_icon.svg',
              'leave',
              isDanger: true,
              appColors,
            ),
        ];
      },

      onSelected: (String value) =>
          _handleMenuSelection(context, ref, value, appColors), // ref 전달
    );
  }

  // 메뉴 아이템 위젯 생성 헬퍼
  PopupMenuItem<String> _buildPopupItem(
    String title,
    String iconPath,
    String value,
    AppColorsExtension appColors, {
    bool isDanger = false,
  }) {
    final Color itemColor = isDanger
        ? appColors.notification
        : appColors.blackToWhite;

    return PopupMenuItem<String>(
      value: value,
      child: Row(
        children: [
          SvgPicture.asset(
            iconPath,
            width: 20,
            height: 20,
            colorFilter: ColorFilter.mode(itemColor, BlendMode.srcIn),
          ),
          const SizedBox(width: 8),
          Text(
            title,
            style: AppTypography.b2.copyWith(
              color: itemColor, // 텍스트 색상 변경
            ),
          ),
        ],
      ),
    );
  }

  // 메뉴 선택 핸들러
  void _handleMenuSelection(
    BuildContext context,
    WidgetRef ref,
    String value,
    AppColorsExtension appColors,
  ) async {
    // async 추가
    switch (value) {
      case 'notification':
        // 알림 설정 로직 호출
        showDialog(
          context: context,
          builder: (context) =>
              NotificationSettingsDialog(challengeId: challengeId),
        );
        break;
      case 'invite':
        // 초대 화면 이동
        Navigator.push(
          context,
          MaterialPageRoute(
            // [수정 전]
            // builder: (context) => const ChallengeInviteScreen(),

            // [수정 후] 현재 위젯이 가지고 있는 challengeId를 전달해야 합니다.
            builder: (context) => ChallengeInviteScreen(
              challengeId:
                  challengeId, // 만약 변수명이 challengeId가 아니라면 해당 변수명(예: widget.challenge.id)으로 넣어주세요.
            ),
          ),
        );
        break;
      case 'settings':
        // 방장 전용: 챌린지 설정 화면 이동
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                ChallengeSettingsScreen(challengeId: challengeId),
          ),
        );
        break;
      case 'leave':
        showDialog(
          context: context,
          builder: (dialogContext) => SelectDialog(
            emoji: '🥺',
            title: '챌린지를 나가시겠어요?',
            content: '지금까지의 진행 상황이 모두 사라지며,\n복구할 수 없습니다.',
            contentColor: appColors.notification,
            confirmText: '나가기',
            cancelText: '취소',
            confirmBackgroundColor: appColors.notification,
            confirmTextColor: appColors.whiteToBlack,
            swapButtonOrder: true,
            onConfirm: () async {
              // ✅ "나가기" 버튼 로직을 onConfirm으로 이동
              debugPrint('나가기 버튼 눌림');
              final success = await ref
                  .read(challengeLeaveNotifierProvider.notifier)
                  .leaveChallenge(challengeId);

              if (success && context.mounted) {
                displayToast(context, '챌린지에서 성공적으로 나갔습니다.');
                Navigator.pop(context);
              } else if (context.mounted) {
                displayToast(context, '나가기 처리 중 오류가 발생했습니다.');
              }
            },
            onCancel: () {}, // ✅ "취소" 버튼은 아무것도 안 함
          ),
        );
        break;
    }
  }
}
