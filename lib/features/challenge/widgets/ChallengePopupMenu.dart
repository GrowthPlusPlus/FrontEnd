// 최초 작성자 : 강선욱
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:haenaem/core/theme/app_colors.dart';
import 'package:haenaem/core/theme/app_typography.dart';
import 'package:haenaem/features/challenge/invite/challengeInviteScreen.dart';
import 'package:haenaem/features/challenge/widgets/ExitConfirmDialog.dart';
import 'package:haenaem/features/challenge/widgets/NotificationSettingsDialog.dart';
import 'package:haenaem/features/challenge/settings/challenge_settings_screen.dart';

// 챌린지방 팝업 (방장일 경우/멤버일 경우)
class ChallengePopupMenu extends StatelessWidget {
  final bool isHost; // 방장 여부
  final int challengeId;

  const ChallengePopupMenu({
    super.key,
    required this.isHost,
    required this.challengeId,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      popUpAnimationStyle: const AnimationStyle(
        duration: Duration.zero,
        reverseDuration: Duration.zero,
      ),
      icon: SvgPicture.asset(
        'assets/images/icons/dots_vert_icon.svg',
        width: 24,
        height: 24,
      ),
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: const BorderSide(color: AppColors.gray4, width: 1),
      ),
      offset: const Offset(0, 40),

      // 아이템 빌더에서 조건부 리스트 생성
      itemBuilder: (BuildContext context) {
        return [
          _buildPopupItem(
            '알림 설정',
            'assets/images/icons/notification_icon.svg',
            'notification',
          ),
          const PopupMenuDivider(height: 1),
          _buildPopupItem(
            '챌린지 초대',
            'assets/images/icons/share_icon.svg',
            'invite',
          ),
          const PopupMenuDivider(height: 1),

          // --- 방장/참여자 구분 구간 ---
          if (isHost)
            _buildPopupItem(
              '챌린지 설정',
              'assets/images/icons/black_settings_icon.svg', // 방장용 설정 아이콘
              'settings',
            )
          else
            _buildPopupItem(
              '챌린지 나가기',
              'assets/images/icons/exit_icon.svg',
              'exit',
              isDanger: true,
            ),
        ];
      },

      onSelected: (String value) => _handleMenuSelection(context, value),
    );
  }

  // 메뉴 아이템 위젯 생성 헬퍼
  PopupMenuItem<String> _buildPopupItem(
    String title,
    String iconPath,
    String value, {
    bool isDanger = false,
  }) {
    final Color itemColor = isDanger ? AppColors.notification : AppColors.black;

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
  void _handleMenuSelection(BuildContext context, String value) {
    switch (value) {
      case 'notification':
        // 알림 설정 로직 호출
        showDialog(
          context: context,
          builder: (context) => const NotificationSettingsDialog(),
        );
        break;
      case 'invite':
        // 초대 화면 이동
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const ChallengeInviteScreen(),
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
      case 'exit':
        // 참여자 전용: 나가기 컨펌 다이얼로그
        showDialog<bool>(
          context: context,
          builder: (context) => const ExitConfirmDialog(),
        ).then((confirmed) {
          if (confirmed == true) {
            // 사용자가 '나가기'를 확정했을 때의 로직
            print("챌린지 나가기 처리됨");
          }
        });
        break;
    }
  }
}
