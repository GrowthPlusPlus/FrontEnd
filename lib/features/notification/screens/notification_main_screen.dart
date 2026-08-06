// 최초 작성자: 정승빈
// 최상위 화면 (TabBar와 TabBarView 포함)
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:haenaem/features/notification/views/challenge_invites_view.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../views/all_notifications_view.dart';
import '../provider/notification_provider.dart';
import 'package:haenaem/shared/widgets/custom_tab_bar.dart';

class NotificationMainScreen extends ConsumerStatefulWidget {
  const NotificationMainScreen({super.key});

  @override
  ConsumerState<NotificationMainScreen> createState() =>
      _NotificationMainScreenState();
}

class _NotificationMainScreenState
    extends ConsumerState<NotificationMainScreen> {
  @override
  void initState() {
    super.initState();

    // 화면에 진입한 직후 두 탭의 데이터를 최신으로 새로고침합니다.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // 1. '모두' 탭 새로고침
      ref.read(notificationProvider.notifier).refresh();
      // 2. '챌린지 초대' 탭 새로고침
      ref.read(challengeInviteProvider.notifier).fetchInvites();
    });
  }

  @override
  Widget build(BuildContext context) {
    final appColors = Theme.of(context).extension<AppColorsExtension>()!;

    return Scaffold(
      backgroundColor: appColors.whiteToBlack,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: appColors.blackToWhite),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('알림', style: AppTypography.h3),
        centerTitle: true,
        backgroundColor: appColors.whiteToBlack,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      body: CustomTabBar(
        tabs: ['모두', '챌린지 초대'],
        children: const [
          AllNotificationsView(), // '모두' 탭
          ChallengeInvitesView(), // '챌린지 초대' 탭
        ],
      ),
    );
  }
}
