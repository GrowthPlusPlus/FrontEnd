// 최초 작성자 : 김채영
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/widgets/custom_switch.dart';
import '../../notification/provider/push_notification_provider.dart';

class PushNotificationSettingsScreen extends ConsumerWidget {
  const PushNotificationSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(pushNotificationProvider);
    final notifier = ref.read(pushNotificationProvider.notifier);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
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
          '푸시 알림 설정',
          style: AppTypography.h3.copyWith(color: AppColors.black),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            _buildSwitchRow(
              title: '전체 알림',
              subtitle: '모든 알림 받기',
              value: settings.allNotifications,
              onChanged: (val) => notifier.toggle('all', val),
              isMain: true,
            ),
            const Padding(
              padding: EdgeInsets.only(left: 20, right: 20, top: 20, bottom: 0),
              child: Divider(color: AppColors.gray4, height: 1),
            ),

            _buildSectionHeader('소셜'),
            _buildSwitchRow(
              title: '내 글 좋아요',
              subtitle: "내 게시물에 '좋아요' 반응이 올 때 알림",
              value: settings.likeNotifications,
              onChanged: (val) => notifier.toggle('like', val),
            ),
            _buildSwitchRow(
              title: '댓글',
              subtitle: '내 글에 새로운 댓글이 달릴 때 알림',
              value: settings.commentNotifications,
              onChanged: (val) => notifier.toggle('comment', val),
            ),
            _buildSwitchRow(
              title: '친구 신청',
              subtitle: '나에게 새로운 친구 요청이 도착할 때 알림',
              value: settings.friendRequestNotifications,
              onChanged: (val) => notifier.toggle('friend', val),
            ),

            _buildSectionHeader('챌린지'),
            _buildSwitchRow(
              title: '챌린지 초대',
              subtitle: '새로운 챌린지 참여 제안을 받았을 때 알림',
              value: settings.challengeInviteNotifications,
              onChanged: (val) => notifier.toggle('invite', val),
            ),
            _buildSwitchRow(
              title: '동기부여 메시지',
              subtitle: '꾸준한 챌린지 참여를 돕는 응원 푸시 알림',
              value: settings.motivationNotifications,
              onChanged: (val) => notifier.toggle('motivation', val),
            ),
            _buildSwitchRow(
              title: '일일 리마인더 (전체)',
              subtitle: '리마인더 알림 통합 관리',
              value: settings.dailyReminder, // 전용 필드로 수정
              onChanged: (val) => notifier.toggle('reminder', val),
            ),

            _buildSectionHeader('커뮤니티 활동'),
            _buildSwitchRow(
              title: '멤버 반응 소식 (전체)',
              subtitle: '멤버 반응 알림 통합 관리',
              value: settings.likeNotifications, // 좋아요/댓글 등 소식 연결
              onChanged: (val) => notifier.toggle('like', val),
            ),
            _buildSwitchRow(
              title: '멤버 인증 소식 (전체)',
              subtitle: '멤버 인증 알림 통합 관리',
              value: settings.memberAuthNotifications,
              onChanged: (val) => notifier.toggle('memberAuth', val),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  // 섹션 제목 위젯
  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 20, top: 20, bottom: 10),
      child: Text(
        title,
        style: AppTypography.b1.copyWith(color: AppColors.gray1),
      ),
    );
  }

  // 토글 타일 위젯
  Widget _buildSwitchRow({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
    bool isMain = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTypography.b1.copyWith(
                    color: AppColors.black,
                    fontWeight: isMain ? FontWeight.w600 : FontWeight.w500,
                  ),
                ),
                Text(
                  subtitle,
                  style: AppTypography.b2.copyWith(color: AppColors.gray2),
                ),
              ],
            ),
          ),
          // 2. 커스텀 스위치 적용
          CustomSwitch(value: value, onChanged: onChanged),
        ],
      ),
    );
  }
}
